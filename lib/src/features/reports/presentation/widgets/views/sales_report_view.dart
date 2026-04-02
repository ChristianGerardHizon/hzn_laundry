import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../../../pos/domain/payment_method.dart';
import '../../../../pos/domain/payment_type.dart';
import '../../../domain/payment_report_entry.dart';
import '../../../domain/payments_summary.dart';
import '../../controllers/payments_date_range_controller.dart';
import '../../controllers/payments_report_controller.dart';
import '../../controllers/payments_summary_controller.dart';
import '../charts/line_chart_widget.dart';

/// View displaying payments received within the selected report period.
///
/// Adapts layout between mobile (card list) and tablet/desktop (DataTable).
class SalesReportView extends ConsumerWidget {
  const SalesReportView({super.key});

  static final _currencyFormat =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(paymentsSummaryProvider);
    final detailAsync = ref.watch(paymentsReportProvider);
    final dateRange = ref.watch(paymentsDateRangeControllerProvider);

    // Wait for summary first (lightweight); detail may still be loading
    return summaryAsync.when(
      data: (summary) => _buildContent(
        context,
        ref,
        summary,
        detailAsync.when(
                data: (entries) =>
                    entries.where((e) => !e.isVoided).toList(),
                loading: () => <PaymentReportEntry>[],
                error: (_, __) => <PaymentReportEntry>[],
              ),
        detailAsync.isLoading,
        dateRange,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading payments: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<PaymentsDailySummaryEntry> summary,
    List<PaymentReportEntry> detailEntries,
    bool detailLoading,
    DateTimeRange dateRange,
  ) {
    final isMobile = Breakpoints.isMobile(context);

    // Aggregate KPIs from the view summary
    num totalCollected = 0;
    num totalRefunded = 0;
    int paymentCount = 0;
    final methodTotals = <PaymentMethod, num>{};
    final dailyTotals = <DateTime, num>{};

    for (final s in summary) {
      if (s.paymentType == PaymentType.refund) {
        totalRefunded += s.totalAmount;
      } else {
        totalCollected += s.totalAmount;
      }
      paymentCount += s.paymentCount;
      methodTotals[s.paymentMethod] =
          (methodTotals[s.paymentMethod] ?? 0) + s.totalAmount;

      // For chart: net per day
      final day = DateTime(s.date.year, s.date.month, s.date.day);
      final amount = s.paymentType == PaymentType.refund
          ? -s.totalAmount
          : s.totalAmount;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + amount;
    }

    final netCollected = totalCollected - totalRefunded;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeRow(context, ref, dateRange),
          const SizedBox(height: 12),
          _buildKpiSection(
            context,
            netCollected: netCollected,
            totalCollected: totalCollected,
            totalRefunded: totalRefunded,
            paymentCount: paymentCount,
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          _buildRevenueByDayChart(context, dailyTotals),
          const SizedBox(height: 16),
          if (methodTotals.isNotEmpty) ...[
            _buildMethodBreakdown(context, methodTotals),
            const SizedBox(height: 16),
          ],
          if (detailLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (isMobile)
            _buildMobilePaymentsList(context, detailEntries)
          else
            _buildDesktopPaymentsTable(context, detailEntries),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Date range picker
  // ---------------------------------------------------------------------------

  Widget _buildDateRangeRow(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange dateRange,
  ) {
    final theme = Theme.of(context);
    final startStr = _dateFormat.format(dateRange.start);
    final endStr = _dateFormat.format(dateRange.end);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _pickDateRange(context, ref, dateRange),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '$startStr – $endStr',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange dateRange,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: dateRange,
    );
    if (picked != null) {
      final adjustedEnd = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
        999,
      );
      ref
          .read(paymentsDateRangeControllerProvider.notifier)
          .setRange(DateTimeRange(start: picked.start, end: adjustedEnd));
    }
  }

  // ---------------------------------------------------------------------------
  // Revenue by day chart
  // ---------------------------------------------------------------------------

  Widget _buildRevenueByDayChart(
    BuildContext context,
    Map<DateTime, num> dailyTotals,
  ) {
    if (dailyTotals.isEmpty) return const SizedBox.shrink();

    final sortedDays = dailyTotals.keys.toList()..sort();
    final spots = sortedDays.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        dailyTotals[entry.value]!.toDouble(),
      );
    }).toList();
    final xLabels =
        sortedDays.map((d) => DateFormat('MMM d').format(d)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChartWidget(
          title: 'Payments Received per Day',
          spots: spots,
          xLabels: xLabels,
          lineColor: Colors.green,
          yAxisFormatter: (value) =>
              _currencyFormat.format(value).replaceAll('.00', ''),
          height: 220,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI cards
  // ---------------------------------------------------------------------------

  Widget _buildKpiSection(
    BuildContext context, {
    required num netCollected,
    required num totalCollected,
    required num totalRefunded,
    required int paymentCount,
    required bool isMobile,
  }) {
    final cards = [
      _KpiData('Net Collected', _currencyFormat.format(netCollected),
          Icons.account_balance_wallet, Colors.green),
      _KpiData('Total Received', _currencyFormat.format(totalCollected),
          Icons.arrow_downward, Colors.blue),
      _KpiData('Refunded', _currencyFormat.format(totalRefunded),
          Icons.arrow_upward, Colors.red),
      _KpiData(
          'Payments', '$paymentCount', Icons.receipt_long, Colors.orange),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[0].title,
                    value: cards[0].value,
                    icon: cards[0].icon,
                    color: cards[0].color)),
            const SizedBox(width: 8),
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[1].title,
                    value: cards[1].value,
                    icon: cards[1].icon,
                    color: cards[1].color)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[2].title,
                    value: cards[2].value,
                    icon: cards[2].icon,
                    color: cards[2].color)),
            const SizedBox(width: 8),
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[3].title,
                    value: cards[3].value,
                    icon: cards[3].icon,
                    color: cards[3].color)),
          ]),
        ],
      );
    }

    return Row(
      children: cards
          .expand((c) => [
                Expanded(
                    child: KpiCard(
                        compact: true,
                        title: c.title,
                        value: c.value,
                        icon: c.icon,
                        color: c.color)),
                const SizedBox(width: 12),
              ])
          .toList()
        ..removeLast(),
    );
  }

  // ---------------------------------------------------------------------------
  // Payment method breakdown
  // ---------------------------------------------------------------------------

  Widget _buildMethodBreakdown(
    BuildContext context,
    Map<PaymentMethod, num> methodTotals,
  ) {
    final theme = Theme.of(context);
    final sorted = methodTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By Payment Method',
                style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: sorted.map((entry) {
                final (IconData icon, Color color) =
                    _methodStyle(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(entry.key.displayName,
                        style: theme.textTheme.bodySmall),
                    const SizedBox(width: 4),
                    Text(_currencyFormat.format(entry.value),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _methodStyle(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => (Icons.payments, Colors.green),
      PaymentMethod.card => (Icons.credit_card, Colors.blue),
      PaymentMethod.bankTransfer => (Icons.account_balance, Colors.purple),
      PaymentMethod.check => (Icons.description, Colors.brown),
    };
  }

  // ---------------------------------------------------------------------------
  // Desktop: DataTable
  // ---------------------------------------------------------------------------

  Widget _buildDesktopPaymentsTable(
    BuildContext context,
    List<PaymentReportEntry> entries,
  ) {
    if (entries.isEmpty) return _buildEmptyState(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              '${entries.length} payments',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowHeight: 44,
                    dataRowMinHeight: 40,
                    dataRowMaxHeight: 48,
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Receipt #')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Amount'), numeric: true),
                      DataColumn(label: Text('Method')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Reference')),
                      DataColumn(label: Text('')),
                    ],
                    rows: entries
                        .map((e) => _buildDataRow(context, e))
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, PaymentReportEntry entry) {
    final p = entry.payment;
    final isRefund = p.type == PaymentType.refund;
    final theme = Theme.of(context);

    return DataRow(
      cells: [
        DataCell(Text(
          p.created != null ? _dateTimeFormat.format(p.created!) : '—',
        )),
        DataCell(Text(entry.receiptNumber)),
        DataCell(Text(entry.customerName ?? '—')),
        DataCell(Text(
          '${isRefund ? '-' : ''}${_currencyFormat.format(p.amount)}',
          style: TextStyle(
            color: isRefund ? Colors.red : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        )),
        DataCell(Text(p.paymentMethod.displayName)),
        DataCell(_buildTypeChip(context, p.type)),
        DataCell(Text(p.paymentRef ?? '—',
            style: theme.textTheme.bodySmall)),
        DataCell(
          IconButton(
            icon: Icon(Icons.open_in_new,
                size: 16, color: theme.colorScheme.primary),
            tooltip: 'View order',
            onPressed: () =>
                SaleDetailRoute(id: entry.saleId).go(context),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile: card list
  // ---------------------------------------------------------------------------

  Widget _buildMobilePaymentsList(
    BuildContext context,
    List<PaymentReportEntry> entries,
  ) {
    if (entries.isEmpty) return _buildEmptyState(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${entries.length} payments',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        ...entries.map((e) => _buildMobilePaymentCard(context, e)),
      ],
    );
  }

  Widget _buildMobilePaymentCard(
    BuildContext context,
    PaymentReportEntry entry,
  ) {
    final theme = Theme.of(context);
    final p = entry.payment;
    final isRefund = p.type == PaymentType.refund;
    final (IconData methodIcon, Color methodColor) =
        _methodStyle(p.paymentMethod);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => SaleDetailRoute(id: entry.saleId).go(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: amount + type chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${isRefund ? '-' : ''}${_currencyFormat.format(p.amount)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isRefund ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  _buildTypeChip(context, p.type),
                ],
              ),
              const SizedBox(height: 4),
              // Receipt + customer
              Row(
                children: [
                  if (entry.receiptNumber.isNotEmpty) ...[
                    Text(entry.receiptNumber,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500)),
                    if (entry.customerName != null &&
                        entry.customerName!.isNotEmpty) ...[
                      Text(' · ',
                          style: TextStyle(
                              color: theme.colorScheme.outline)),
                      Expanded(
                        child: Text(
                          entry.customerName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Bottom row: method + date
              Row(
                children: [
                  Icon(methodIcon, size: 14, color: methodColor),
                  const SizedBox(width: 4),
                  Text(p.paymentMethod.displayName,
                      style: theme.textTheme.labelSmall),
                  if (p.paymentRef != null &&
                      p.paymentRef!.isNotEmpty) ...[
                    Text(' · ',
                        style:
                            TextStyle(color: theme.colorScheme.outline)),
                    Flexible(
                      child: Text(p.paymentRef!,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.access_time,
                      size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    p.created != null
                        ? _dateTimeFormat.format(p.created!)
                        : '—',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.payments_outlined,
                  size: 48, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No payments found for this period.',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, PaymentType type) {
    final (Color color, String label) = switch (type) {
      PaymentType.payment => (Colors.green, 'Payment'),
      PaymentType.deposit => (Colors.blue, 'GCash/Bank'),
      PaymentType.refund => (Colors.red, 'Refund'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}

class _KpiData {
  const _KpiData(this.title, this.value, this.icon, this.color);
  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
