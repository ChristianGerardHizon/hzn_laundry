import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/add_ons_summary.dart';
import '../../domain/loads_summary.dart';
import '../../domain/packs_summary.dart';
import '../../domain/sales_summary.dart';
import '../controllers/today_incentive_controller.dart';

/// A single line row inside a breakdown section of the dashboard PDF.
class _PdfLine {
  const _PdfLine({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.amount,
    this.amountText,
    this.machines,
    this.loads,
    this.packs,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final num amount;

  /// When set, this string is rendered in the amount column instead of the
  /// peso-formatted [amount] (e.g. a plain load count like "5 loads").
  final String? amountText;

  /// Machine name(s) used on this order (Total Sales rows only). Null when no
  /// machines were assigned.
  final String? machines;

  /// Total load count (machine cycles) for this order (Total Sales rows only).
  /// Null when not a Total Sales row; 0 means no loads.
  final int? loads;

  /// Pack count for this order (Total Sales rows only).
  /// Null when not a Total Sales row; 0 means no packs.
  final int? packs;
}

/// Aggregated footer totals for the Total Sales section.
class _SalesFooterTotals {
  const _SalesFooterTotals({
    required this.totalLoads,
    required this.totalPacks,
    required this.unpaidCount,
    required this.unpaidAmount,
    required this.partialCount,
    required this.partialAmount,
    required this.fullyPaidCount,
    required this.fullyPaidAmount,
    required this.addOnCount,
    required this.addOnAmount,
  });

  final int totalLoads;
  final int totalPacks;
  final int unpaidCount;
  final num unpaidAmount;
  final int partialCount;
  final num partialAmount;
  final int fullyPaidCount;
  final num fullyPaidAmount;
  final int addOnCount;
  final num addOnAmount;

  /// Builds the footer totals from the Total Sales breakdown items.
  factory _SalesFooterTotals.fromItems(List<SalesSummaryItem> items) {
    var totalLoads = 0;
    var totalPacks = 0;
    var unpaidCount = 0;
    num unpaidAmount = 0;
    var partialCount = 0;
    num partialAmount = 0;
    var fullyPaidCount = 0;
    num fullyPaidAmount = 0;
    var addOnCount = 0;
    num addOnAmount = 0;

    for (final item in items) {
      totalLoads += _orderLoads(item);
      totalPacks += item.packs;

      switch (item.statusLabel) {
        case 'Paid':
          fullyPaidCount++;
          fullyPaidAmount += item.totalAmount;
        case 'Partial':
          partialCount++;
          partialAmount += item.totalAmount;
        default:
          unpaidCount++;
          unpaidAmount += item.totalAmount;
      }

      for (final addOn in item.saleItems) {
        addOnCount++;
        addOnAmount += addOn.subtotal;
      }
    }

    return _SalesFooterTotals(
      totalLoads: totalLoads,
      totalPacks: totalPacks,
      unpaidCount: unpaidCount,
      unpaidAmount: unpaidAmount,
      partialCount: partialCount,
      partialAmount: partialAmount,
      fullyPaidCount: fullyPaidCount,
      fullyPaidAmount: fullyPaidAmount,
      addOnCount: addOnCount,
      addOnAmount: addOnAmount,
    );
  }
}

/// Sums the load count (machine cycles) across all service items of an order.
int _orderLoads(SalesSummaryItem item) {
  var loads = 0;
  for (final service in item.serviceItems) {
    for (final count in service.machineLoadCounts.values) {
      loads += count;
    }
  }
  return loads;
}

/// Dedup-joins the machine name snapshot(s) across an order's service items.
/// Returns null when no machine was assigned.
String? _orderMachines(SalesSummaryItem item) {
  final names = <String>{};
  for (final service in item.serviceItems) {
    final name = service.machineName;
    if (name != null && name.trim().isNotEmpty) names.add(name.trim());
  }
  return names.isEmpty ? null : names.join(', ');
}

/// Short payment-status label for Total Sales rows ("Paid" → "Full").
String _shortStatusLabel(String statusLabel) =>
    statusLabel == 'Paid' ? 'Full' : statusLabel;

/// Maps sales/payment/outstanding breakdown items to PDF lines.
List<_PdfLine> _mapSalesLines(List<SalesSummaryItem> items) {
  return items.map((item) {
    final services = item.serviceItems
        .map((e) =>
            '${e.serviceName} x${e.service?.formatQuantity(e.quantity) ?? '${e.quantity}'}')
        .join(', ');
    final addons =
        item.saleItems.map((e) => '${e.productName} x${e.quantity}').join(', ');
    final details = [
      if (services.isNotEmpty) services,
      if (addons.isNotEmpty) addons,
    ].join(' · ');

    final receipt = _shortReceipt(item.receiptNumber);
    final name = (item.customerName != null && item.customerName!.isNotEmpty)
        ? item.customerName!
        : 'Walk-in';
    final backlog = item.isBacklog ? '  [Backlog]' : '';

    return _PdfLine(
      title: '$name  ·  $receipt$backlog',
      subtitle: details,
      trailing: item.statusLabel,
      amount: item.totalAmount,
    );
  }).toList();
}

/// Maps Total Sales breakdown items to PDF lines with the extended columns
/// (short payment status, machines used, and per-order load count).
List<_PdfLine> _mapTotalSalesLines(List<SalesSummaryItem> items) {
  return items.map((item) {
    final services = item.serviceItems
        .map((e) =>
            '${e.serviceName} x${e.service?.formatQuantity(e.quantity) ?? '${e.quantity}'}')
        .join(', ');
    final addons =
        item.saleItems.map((e) => '${e.productName} x${e.quantity}').join(', ');
    final details = [
      if (services.isNotEmpty) services,
      if (addons.isNotEmpty) addons,
    ].join(' · ');

    final receipt = _shortReceipt(item.receiptNumber);
    final name = (item.customerName != null && item.customerName!.isNotEmpty)
        ? item.customerName!
        : 'Walk-in';
    final backlog = item.isBacklog ? '  [Backlog]' : '';

    return _PdfLine(
      title: '$name  ·  $receipt$backlog',
      subtitle: details,
      trailing: _shortStatusLabel(item.statusLabel),
      amount: item.totalAmount,
      machines: _orderMachines(item),
      loads: _orderLoads(item),
      packs: item.packs,
    );
  }).toList();
}

/// Maps incentive order entries to PDF lines.
List<_PdfLine> _mapIncentiveLines(List<TodayOrderIncentiveEntry> orders) {
  return orders.map((order) {
    final receipt = _shortReceipt(order.receiptNumber);
    final name = order.customerName ?? 'Walk-in';
    final backlog = order.isBacklog ? '  [Backlog]' : '';
    return _PdfLine(
      title: '$name  ·  $receipt$backlog',
      subtitle: 'Service: ${_pesoPdf.format(order.servicePrice)}',
      trailing: _statusLabel(order.orderStatus),
      amount: order.incentive,
    );
  }).toList();
}

/// Maps add-on breakdown items (aggregated per product) to PDF lines.
List<_PdfLine> _mapAddOnLines(List<AddOnBreakdownItem> items) {
  return items.map((item) {
    final name = item.productName.isNotEmpty ? item.productName : 'Unnamed';
    return _PdfLine(
      title: name,
      subtitle: 'in ${item.orderCount} order${item.orderCount == 1 ? '' : 's'}',
      trailing: 'x${_qtyPdf.format(item.quantity)}',
      amount: item.revenue,
    );
  }).toList();
}

/// Maps per-order packs entries to PDF lines (pack count, not currency).
List<_PdfLine> _mapPacksLines(List<PacksOrderEntry> orders) {
  return orders.map((order) {
    final name = (order.customerName != null && order.customerName!.isNotEmpty)
        ? order.customerName!
        : 'Walk-in';
    return _PdfLine(
      title: '$name  ·  ${_shortReceipt(order.receiptNumber)}',
      subtitle: '',
      trailing: _statusLabel(order.orderStatus),
      amount: order.packs,
      amountText: '${_qtyPdf.format(order.packs)} '
          'pack${order.packs == 1 ? '' : 's'}',
    );
  }).toList();
}

/// Maps per-order load entries to PDF lines (load count, not currency).
List<_PdfLine> _mapLoadsLines(List<LoadsOrderEntry> orders) {
  return orders.map((order) {
    final name = (order.customerName != null && order.customerName!.isNotEmpty)
        ? order.customerName!
        : 'Walk-in';
    return _PdfLine(
      title: '$name  ·  ${_shortReceipt(order.receiptNumber)}',
      subtitle: '',
      trailing: '',
      amount: order.loads,
      amountText: '${_qtyPdf.format(order.loads)} '
          'load${order.loads == 1 ? '' : 's'}',
    );
  }).toList();
}

/// Serializable payload for a single-section breakdown PDF (e.g. just
/// "Total Sales" or just "Today's Incentive").
class DashboardSectionPdfPayload {
  DashboardSectionPdfPayload({
    required this.sectionTitle,
    required this.businessName,
    required this.reportDate,
    required this.generatedAt,
    required this.isDateOverridden,
    required this.total,
    required this.lines,
    required this.emptyText,
    this.totalText,
    this.salesFooter,
  });

  final String sectionTitle;
  final String? businessName;
  final DateTime reportDate;
  final DateTime generatedAt;
  final bool isDateOverridden;
  final num total;
  final List<_PdfLine> lines;
  final String emptyText;

  /// When set, rendered as the section total instead of the peso-formatted
  /// [total] (e.g. a plain load count).
  final String? totalText;

  /// When set, this section renders as the extended Total Sales table (with
  /// machines/loads columns) followed by this footer totals block.
  final _SalesFooterTotals? salesFooter;

  /// Builds the payload for a sales/payment/outstanding breakdown section.
  factory DashboardSectionPdfPayload.fromSales({
    required String sectionTitle,
    required List<SalesSummaryItem> items,
    required num total,
    required String? businessName,
    required DateTime reportDate,
    required DateTime generatedAt,
    required bool isDateOverridden,
    String emptyText = 'No orders for this day.',
  }) {
    return DashboardSectionPdfPayload(
      sectionTitle: sectionTitle,
      businessName: businessName,
      reportDate: reportDate,
      generatedAt: generatedAt,
      isDateOverridden: isDateOverridden,
      total: total,
      lines: _mapSalesLines(items),
      emptyText: emptyText,
    );
  }

  /// Builds the payload for the extended Total Sales section, which adds
  /// machines/loads columns per order and a totals footer.
  factory DashboardSectionPdfPayload.fromTotalSales({
    required List<SalesSummaryItem> items,
    required num total,
    required String? businessName,
    required DateTime reportDate,
    required DateTime generatedAt,
    required bool isDateOverridden,
    String emptyText = 'No orders for this day.',
  }) {
    return DashboardSectionPdfPayload(
      sectionTitle: 'Total Sales',
      businessName: businessName,
      reportDate: reportDate,
      generatedAt: generatedAt,
      isDateOverridden: isDateOverridden,
      total: total,
      lines: _mapTotalSalesLines(items),
      emptyText: emptyText,
      salesFooter: _SalesFooterTotals.fromItems(items),
    );
  }

  /// Builds the payload for the incentive breakdown section.
  factory DashboardSectionPdfPayload.fromIncentive({
    required TodayIncentiveSummary incentive,
    required String? businessName,
    required DateTime reportDate,
    required DateTime generatedAt,
    required bool isDateOverridden,
  }) {
    return DashboardSectionPdfPayload(
      sectionTitle: "Today's Incentive",
      businessName: businessName,
      reportDate: reportDate,
      generatedAt: generatedAt,
      isDateOverridden: isDateOverridden,
      total: incentive.totalIncentive,
      lines: _mapIncentiveLines(incentive.orders),
      emptyText: 'No qualifying orders.',
    );
  }

  /// Builds the payload for the add-ons breakdown section.
  factory DashboardSectionPdfPayload.fromAddOns({
    required AddOnsSummaryData summary,
    required String? businessName,
    required DateTime reportDate,
    required DateTime generatedAt,
    required bool isDateOverridden,
  }) {
    return DashboardSectionPdfPayload(
      sectionTitle: 'Add-ons Sold',
      businessName: businessName,
      reportDate: reportDate,
      generatedAt: generatedAt,
      isDateOverridden: isDateOverridden,
      total: summary.totalRevenue,
      lines: _mapAddOnLines(summary.items),
      emptyText: 'No add-ons sold this day.',
    );
  }

  /// Builds the payload for the total packs breakdown section.
  factory DashboardSectionPdfPayload.fromPacks({
    required TotalPacksSummary summary,
    required String? businessName,
    required DateTime reportDate,
    required DateTime generatedAt,
    required bool isDateOverridden,
  }) {
    return DashboardSectionPdfPayload(
      sectionTitle: 'Total Packs',
      businessName: businessName,
      reportDate: reportDate,
      generatedAt: generatedAt,
      isDateOverridden: isDateOverridden,
      total: summary.totalPacks,
      totalText: '${_qtyPdf.format(summary.totalPacks)} '
          'pack${summary.totalPacks == 1 ? '' : 's'}',
      lines: _mapPacksLines(summary.orders),
      emptyText: 'No packs recorded this day.',
    );
  }

  /// Builds the payload for the loads (machine cycles) breakdown section.
  factory DashboardSectionPdfPayload.fromLoads({
    required LoadsSummaryData summary,
    required String? businessName,
    required DateTime reportDate,
    required DateTime generatedAt,
    required bool isDateOverridden,
  }) {
    return DashboardSectionPdfPayload(
      sectionTitle: 'Loads',
      businessName: businessName,
      reportDate: reportDate,
      generatedAt: generatedAt,
      isDateOverridden: isDateOverridden,
      total: summary.totalLoads,
      totalText: '${_qtyPdf.format(summary.totalLoads)} '
          'load${summary.totalLoads == 1 ? '' : 's'}',
      lines: _mapLoadsLines(summary.orders),
      emptyText: 'No loads recorded this day.',
    );
  }
}

/// Builds the PDF bytes for a single breakdown section.
Future<Uint8List> buildDashboardSectionPdf(
  DashboardSectionPdfPayload payload,
) async {
  final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
  final generatedFormat = DateFormat('MMM dd, yyyy hh:mm a');

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox.shrink()
          : pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Text(
                '${payload.sectionTitle} - ${dateFormat.format(payload.reportDate)}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 12),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ),
      build: (context) => [
        _buildSectionTitle(payload, dateFormat, generatedFormat),
        pw.SizedBox(height: 16),
        if (payload.salesFooter != null)
          _buildSalesSection(
            payload.sectionTitle,
            payload.lines,
            payload.total,
            payload.emptyText,
            payload.salesFooter!,
          )
        else
          _buildSection(payload.sectionTitle, payload.lines, payload.total,
              payload.emptyText, totalText: payload.totalText),
      ],
    ),
  );

  return pdf.save();
}

pw.Widget _buildSectionTitle(
  DashboardSectionPdfPayload payload,
  DateFormat dateFormat,
  DateFormat generatedFormat,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (payload.businessName != null && payload.businessName!.isNotEmpty)
        pw.Text(
          payload.businessName!,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      pw.SizedBox(height: 2),
      pw.Text(
        '${payload.sectionTitle} Report',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${payload.isDateOverridden ? 'Date' : 'Today'}: '
            '${dateFormat.format(payload.reportDate)}',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'Generated: ${generatedFormat.format(payload.generatedAt)}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Divider(thickness: 1.2),
    ],
  );
}

/// Serializable payload for the dashboard summary PDF.
///
/// Everything is pre-resolved to plain values so the build function does not
/// touch Riverpod or BuildContext (mirrors the receipt PDF pattern).
class DashboardSummaryPdfPayload {
  DashboardSummaryPdfPayload({
    required this.businessName,
    required this.reportDate,
    required this.generatedAt,
    required this.isDateOverridden,
    required this.includeIncentive,
    required this.totalSales,
    required this.totalPaymentsReceived,
    required this.totalOutstanding,
    required this.totalIncentive,
    required this.salesLines,
    required this.paymentLines,
    required this.outstandingLines,
    required this.incentiveLines,
  });

  final String? businessName;
  final DateTime reportDate;
  final DateTime generatedAt;
  final bool isDateOverridden;
  final bool includeIncentive;

  final num totalSales;
  final num totalPaymentsReceived;
  final num totalOutstanding;
  final num totalIncentive;

  final List<_PdfLine> salesLines;
  final List<_PdfLine> paymentLines;
  final List<_PdfLine> outstandingLines;
  final List<_PdfLine> incentiveLines;

  /// Builds the payload from the dashboard summary models.
  factory DashboardSummaryPdfPayload.fromData({
    required SalesSummaryData summary,
    required TodayIncentiveSummary incentive,
    required String? businessName,
    required DateTime reportDate,
    required DateTime generatedAt,
    required bool isDateOverridden,
    required bool includeIncentive,
  }) {
    return DashboardSummaryPdfPayload(
      businessName: businessName,
      reportDate: reportDate,
      generatedAt: generatedAt,
      isDateOverridden: isDateOverridden,
      includeIncentive: includeIncentive,
      totalSales: summary.totalSales,
      totalPaymentsReceived: summary.totalPaymentsReceived,
      totalOutstanding: summary.totalOutstanding,
      totalIncentive: incentive.totalIncentive,
      salesLines: _mapSalesLines(summary.salesItems),
      paymentLines: _mapSalesLines(summary.paymentItems),
      outstandingLines: _mapSalesLines(summary.outstandingItems),
      incentiveLines:
          includeIncentive ? _mapIncentiveLines(incentive.orders) : const [],
    );
  }
}

// Use 'P' instead of '₱' — the default Helvetica font in the pdf package does
// not include the peso glyph.
final NumberFormat _pesoPdf = NumberFormat.currency(symbol: 'P', decimalDigits: 2);
final NumberFormat _qtyPdf = NumberFormat('#,##0.##');

String _shortReceipt(String receipt) {
  final parts = receipt.split('-');
  if (parts.length >= 3) return '#${parts.last}';
  if (receipt.length > 4) return '#${receipt.substring(receipt.length - 4)}';
  return receipt;
}

String _statusLabel(String status) => switch (status) {
      'ready' => 'Ready',
      'pickedUp' => 'Picked Up',
      'processing' => 'Processing',
      'pending' => 'Pending',
      _ => status,
    };

/// Top-level function that builds the dashboard summary PDF bytes.
Future<Uint8List> buildDashboardSummaryPdf(
  DashboardSummaryPdfPayload payload,
) async {
  final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
  final generatedFormat = DateFormat('MMM dd, yyyy hh:mm a');

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox.shrink()
          : pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Text(
                'Sales Summary - ${dateFormat.format(payload.reportDate)}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 12),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ),
      build: (context) => [
        _buildTitle(payload, dateFormat, generatedFormat),
        pw.SizedBox(height: 16),
        _buildTotalsGrid(payload),
        pw.SizedBox(height: 24),
        _buildSection('Total Sales', payload.salesLines, payload.totalSales,
            'No orders for this day.'),
        _buildSection('Payments Received', payload.paymentLines,
            payload.totalPaymentsReceived, 'No payments for this day.'),
        _buildSection('Outstanding', payload.outstandingLines,
            payload.totalOutstanding, 'No outstanding balances.'),
        if (payload.includeIncentive)
          _buildSection('Today\'s Incentive', payload.incentiveLines,
              payload.totalIncentive, 'No qualifying orders.'),
      ],
    ),
  );

  return pdf.save();
}

pw.Widget _buildTitle(
  DashboardSummaryPdfPayload payload,
  DateFormat dateFormat,
  DateFormat generatedFormat,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (payload.businessName != null && payload.businessName!.isNotEmpty)
        pw.Text(
          payload.businessName!,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      pw.SizedBox(height: 2),
      pw.Text(
        'Sales Summary Report',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${payload.isDateOverridden ? 'Date' : 'Today'}: '
            '${dateFormat.format(payload.reportDate)}',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'Generated: ${generatedFormat.format(payload.generatedAt)}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Divider(thickness: 1.2),
    ],
  );
}

pw.Widget _buildTotalsGrid(DashboardSummaryPdfPayload payload) {
  final cards = <pw.Widget>[
    _totalCard('Total Sales', payload.totalSales,
        '${payload.salesLines.length} orders'),
    _totalCard('Payments Received', payload.totalPaymentsReceived,
        '${payload.paymentLines.length} entries'),
    _totalCard('Outstanding', payload.totalOutstanding,
        '${payload.outstandingLines.length} pending'),
    if (payload.includeIncentive)
      _totalCard('Today\'s Incentive', payload.totalIncentive,
          '${payload.incentiveLines.length} qualifying'),
  ];

  return pw.Row(
    children: [
      for (var i = 0; i < cards.length; i++) ...[
        pw.Expanded(child: cards[i]),
        if (i != cards.length - 1) pw.SizedBox(width: 10),
      ],
    ],
  );
}

pw.Widget _totalCard(String label, num amount, String subtitle) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          _pesoPdf.format(amount),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          subtitle,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    ),
  );
}

pw.Widget _buildSection(
  String title,
  List<_PdfLine> lines,
  num total,
  String emptyText, {
  String? totalText,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 6),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              totalText ?? _pesoPdf.format(total),
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
      pw.Divider(height: 6, thickness: 0.8),
      if (lines.isEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Text(
            emptyText,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        )
      else
        ...lines.asMap().entries.map(
              (entry) => _buildLine(entry.value, entry.key + 1),
            ),
      pw.SizedBox(height: 16),
    ],
  );
}

pw.Widget _buildLine(_PdfLine line, int number) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Row number (left column), mirrors the on-screen badge.
        pw.SizedBox(
          width: 24,
          child: pw.Text(
            '$number.',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 6,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(line.title, style: const pw.TextStyle(fontSize: 10)),
              if (line.subtitle.isNotEmpty)
                pw.Text(
                  line.subtitle,
                  style:
                      const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
            ],
          ),
        ),
        pw.SizedBox(
          width: 70,
          child: pw.Text(
            line.trailing,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            line.amountText ?? _pesoPdf.format(line.amount),
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

// Fixed column widths (pt) for the extended Total Sales table. Description
// takes the remaining space via Expanded.
const double _salesNumWidth = 18;
const double _salesStatusWidth = 48;
const double _salesMachinesWidth = 80;
const double _salesLoadsWidth = 34;
const double _salesPacksWidth = 34;
const double _salesTotalWidth = 70;

/// Builds the extended Total Sales section: a column header, per-order rows with
/// machines/loads columns, and a totals footer block.
pw.Widget _buildSalesSection(
  String title,
  List<_PdfLine> lines,
  num total,
  String emptyText,
  _SalesFooterTotals footer,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 6),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              _pesoPdf.format(total),
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
      pw.Divider(height: 6, thickness: 0.8),
      if (lines.isEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Text(
            emptyText,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        )
      else ...[
        _buildSalesHeaderRow(),
        pw.Divider(height: 4, thickness: 0.4, color: PdfColors.grey400),
        ...lines.asMap().entries.map(
              (entry) => _buildSalesLine(entry.value, entry.key + 1),
            ),
      ],
      pw.SizedBox(height: 12),
      _buildSalesFooter(footer),
      pw.SizedBox(height: 16),
    ],
  );
}

pw.Widget _buildSalesHeaderRow() {
  pw.Widget cell(String text, double width, pw.TextAlign align) => pw.SizedBox(
        width: width,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 7.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
          textAlign: align,
        ),
      );

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      children: [
        cell('#', _salesNumWidth, pw.TextAlign.left),
        pw.Expanded(
          child: pw.Text(
            'Order',
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        cell('Status', _salesStatusWidth, pw.TextAlign.center),
        cell('Machines', _salesMachinesWidth, pw.TextAlign.left),
        cell('Loads', _salesLoadsWidth, pw.TextAlign.right),
        cell('Packs', _salesPacksWidth, pw.TextAlign.right),
        cell('Total', _salesTotalWidth, pw.TextAlign.right),
      ],
    ),
  );
}

pw.Widget _buildSalesLine(_PdfLine line, int number) {
  final loadsText = (line.loads == null || line.loads == 0)
      ? '-'
      : _qtyPdf.format(line.loads);
  final packsText = (line.packs == null || line.packs == 0)
      ? '-'
      : _qtyPdf.format(line.packs);
  final machinesText =
      (line.machines == null || line.machines!.isEmpty) ? '-' : line.machines!;

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: _salesNumWidth,
          child: pw.Text(
            '$number.',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(line.title, style: const pw.TextStyle(fontSize: 9)),
              if (line.subtitle.isNotEmpty)
                pw.Text(
                  line.subtitle,
                  style: const pw.TextStyle(
                      fontSize: 7.5, color: PdfColors.grey600),
                ),
            ],
          ),
        ),
        pw.SizedBox(
          width: _salesStatusWidth,
          child: pw.Text(
            line.trailing,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(
          width: _salesMachinesWidth,
          child: pw.Text(
            machinesText,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
        pw.SizedBox(
          width: _salesLoadsWidth,
          child: pw.Text(
            loadsText,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.SizedBox(
          width: _salesPacksWidth,
          child: pw.Text(
            packsText,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.SizedBox(
          width: _salesTotalWidth,
          child: pw.Text(
            line.amountText ?? _pesoPdf.format(line.amount),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

/// Renders the Total Sales totals footer (loads, payment-status breakdown,
/// add-ons), each row showing the order count and peso amount where relevant.
pw.Widget _buildSalesFooter(_SalesFooterTotals footer) {
  pw.Widget row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );

  String orders(int count, num amount) =>
      '$count order${count == 1 ? '' : 's'}  -  ${_pesoPdf.format(amount)}';

  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Totals',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        row('Total Loads',
            '${_qtyPdf.format(footer.totalLoads)} load${footer.totalLoads == 1 ? '' : 's'}'),
        row('Total Packs',
            '${_qtyPdf.format(footer.totalPacks)} pack${footer.totalPacks == 1 ? '' : 's'}'),
        row('Total Fully Paid',
            orders(footer.fullyPaidCount, footer.fullyPaidAmount)),
        row('Total Partial', orders(footer.partialCount, footer.partialAmount)),
        row('Total Unpaid', orders(footer.unpaidCount, footer.unpaidAmount)),
        row('Total Add-ons',
            '${footer.addOnCount} item${footer.addOnCount == 1 ? '' : 's'}  -  ${_pesoPdf.format(footer.addOnAmount)}'),
      ],
    ),
  );
}
