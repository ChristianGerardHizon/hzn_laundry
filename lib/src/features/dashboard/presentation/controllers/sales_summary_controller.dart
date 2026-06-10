import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pos/data/dto/payment_dto.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/data/dto/sale_item_dto.dart';
import '../../../pos/domain/payment.dart';
import '../../../pos/domain/payment_status.dart';
import '../../../pos/domain/payment_type.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/sales_summary.dart';
import 'dashboard_date_override_provider.dart';

part 'sales_summary_controller.g.dart';

/// Sales summary for the effective dashboard date.
///
/// Totals are intentionally separated:
/// - Total Sales: all orders created on the effective date
/// - Payments Received: all money posted on the effective date
/// - Outstanding: remaining balance for orders created on the effective date
@Riverpod(keepAlive: true)
Future<SalesSummaryData> salesSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final startUtc = dayStart.toPocketBaseUtc();
  final endUtc = dayEnd.toPocketBaseUtc();

  final salesBranchFilter = branchId != null ? ' && branch = "$branchId"' : '';
  final paymentBranchFilter =
      branchId != null ? ' && sale.branch = "$branchId"' : '';

  final todaySalesFilter =
      "status != 'voided' && postedDate >= '$startUtc' && postedDate < '$endUtc'$salesBranchFilter";
  final todayPaymentsFilter =
      "postedDate >= '$startUtc' && postedDate < '$endUtc' && sale.status != 'voided' && isVoided = false$paymentBranchFilter";

  final results = await Future.wait([
    pb.collection(PocketBaseCollections.sales).getFullList(
          filter: todaySalesFilter,
          sort: '-postedDate',
        ),
    pb.collection(PocketBaseCollections.payments).getFullList(
          filter: todayPaymentsFilter,
          sort: '-postedDate',
          expand: 'sale',
        ),
  ]);

  final todaySales = results[0]
      .map((record) => SaleDto.fromRecord(record).toEntity())
      .toList();
  final todaySaleIds = todaySales.map((sale) => sale.id).toSet();

  final paymentsBySaleId = <String, num>{};
  final paymentSales = <String, Sale>{};
  final paymentPostedDateBySaleId = <String, DateTime?>{};

  for (final paymentRecord in results[1]) {
    if (paymentRecord.getBoolValue('isVoided')) continue;
    final saleRecord = paymentRecord.get<RecordModel?>('expand.sale');
    if (saleRecord == null) continue;

    final sale = SaleDto.fromRecord(saleRecord).toEntity();
    final payment = PaymentDto.fromRecord(paymentRecord).toEntity();
    final signedAmount = _signedPaymentAmount(payment);

    paymentsBySaleId[sale.id] = (paymentsBySaleId[sale.id] ?? 0) + signedAmount;
    paymentSales[sale.id] = sale;
    paymentPostedDateBySaleId[sale.id] = payment.postedDate;
  }

  final allSaleIds = [
    ...todaySaleIds,
    ...paymentSales.keys,
  ];

  final serviceItemsBySale = <String, List<SaleServiceItem>>{};
  final saleItemsBySale = <String, List<SaleItem>>{};

  // Outstanding needs the all-time paid amount for today's sales (not just
  // today's payments), so it requires its own payments query scoped to those
  // sale ids. It is independent of the item fetches below, so run it in the
  // same parallel batch instead of a per-sale loop (was an N+1).
  final todaySaleIdsList = todaySaleIds.toList();
  final outstandingPaymentsFilter = todaySaleIdsList.isEmpty
      ? null
      : '(${todaySaleIdsList.map((id) => 'sale = "$id"').join(' || ')}) '
          '&& isVoided = false';

  var outstandingPaymentRecords = const <RecordModel>[];

  if (allSaleIds.isNotEmpty) {
    final saleIdFilters = allSaleIds.map((id) => 'sale = "$id"').join(' || ');

    final itemResults = await Future.wait([
      pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
            filter: '($saleIdFilters)',
            expand: 'service',
          ),
      pb.collection(PocketBaseCollections.saleItems).getFullList(
            filter: '($saleIdFilters)',
          ),
      if (outstandingPaymentsFilter != null)
        pb.collection(PocketBaseCollections.payments).getFullList(
              filter: outstandingPaymentsFilter,
            )
      else
        Future.value(<RecordModel>[]),
    ]);

    for (final record in itemResults[0]) {
      final serviceExpanded = record.get<RecordModel?>('expand.service');
      final item = SaleServiceItemDto.fromRecord(record).toEntity(
        serviceExpanded: serviceExpanded,
      );
      serviceItemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }

    for (final record in itemResults[1]) {
      final item = SaleItemDto.fromRecord(record).toEntity();
      saleItemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }

    outstandingPaymentRecords = itemResults[2];
  }

  final salesItems = [
    for (final sale in todaySales)
      SalesSummaryItem(
        saleId: sale.id,
        receiptNumber: sale.receiptNumber,
        totalAmount: sale.totalAmount,
        isPaid: sale.isPaid,
        isBacklog: false,
        statusLabel: _paymentStatusLabel(sale.paymentStatus),
        customerName: sale.customerName,
        postedDate: sale.postedDate,
        serviceItems: serviceItemsBySale[sale.id] ?? const [],
        saleItems: saleItemsBySale[sale.id] ?? const [],
      ),
  ];

  final outstandingBySaleId = _calculateOutstandingBySaleId(
    sales: todaySales,
    paymentRecords: outstandingPaymentRecords,
  );

  final paymentItems = paymentSales.values
      .map(
        (sale) => SalesSummaryItem(
          saleId: sale.id,
          receiptNumber: sale.receiptNumber,
          totalAmount: paymentsBySaleId[sale.id] ?? 0,
          isPaid: sale.isPaid,
          isBacklog: !todaySaleIds.contains(sale.id),
          statusLabel: _paymentReceivedStatusLabel(sale.paymentStatus),
          customerName: sale.customerName,
          postedDate: paymentPostedDateBySaleId[sale.id],
          serviceItems: serviceItemsBySale[sale.id] ?? const [],
          saleItems: saleItemsBySale[sale.id] ?? const [],
        ),
      )
      .where((item) => item.totalAmount != 0)
      .toList();

  final outstandingItems = [
    for (final sale in todaySales)
      if ((outstandingBySaleId[sale.id] ?? 0) > 0)
        SalesSummaryItem(
          saleId: sale.id,
          receiptNumber: sale.receiptNumber,
          totalAmount: outstandingBySaleId[sale.id] ?? 0,
          isPaid: false,
          isBacklog: false,
          statusLabel: _paymentStatusLabel(sale.paymentStatus),
          customerName: sale.customerName,
          postedDate: sale.postedDate,
          serviceItems: serviceItemsBySale[sale.id] ?? const [],
          saleItems: saleItemsBySale[sale.id] ?? const [],
        ),
  ];

  final totalSales =
      todaySales.fold<num>(0, (sum, sale) => sum + sale.totalAmount);
  final totalPaymentsReceived =
      paymentsBySaleId.values.fold<num>(0, (sum, amount) => sum + amount);
  final totalOutstanding =
      outstandingBySaleId.values.fold<num>(0, (sum, amount) => sum + amount);

  return SalesSummaryData(
    totalSales: totalSales,
    totalPaymentsReceived: totalPaymentsReceived,
    totalOutstanding: totalOutstanding,
    salesItems: salesItems,
    paymentItems: paymentItems,
    outstandingItems: outstandingItems,
  );
}

/// Computes the remaining balance per sale from a single batch of payment
/// records (all-time, non-voided, scoped to the given sales). Payments are
/// grouped by sale id in-memory, avoiding a per-sale query (was an N+1).
Map<String, num> _calculateOutstandingBySaleId({
  required List<Sale> sales,
  required List<RecordModel> paymentRecords,
}) {
  final paidBySaleId = <String, num>{};
  for (final record in paymentRecords) {
    if (record.getBoolValue('isVoided')) continue;
    final saleId = record.getStringValue('sale');
    if (saleId.isEmpty) continue;
    final payment = PaymentDto.fromRecord(record).toEntity();
    paidBySaleId[saleId] =
        (paidBySaleId[saleId] ?? 0) + _signedPaymentAmount(payment);
  }

  final outstandingBySaleId = <String, num>{};
  for (final sale in sales) {
    final outstanding = sale.totalAmount - (paidBySaleId[sale.id] ?? 0);
    outstandingBySaleId[sale.id] = outstanding > 0 ? outstanding : 0;
  }

  return outstandingBySaleId;
}

num _signedPaymentAmount(Payment payment) {
  return payment.type == PaymentType.refund ? -payment.amount : payment.amount;
}

String _paymentStatusLabel(PaymentStatus status) {
  return switch (status) {
    PaymentStatus.paid => 'Paid',
    PaymentStatus.partial => 'Partial',
    PaymentStatus.unpaid => 'Unpaid',
  };
}

String _paymentReceivedStatusLabel(PaymentStatus status) {
  return switch (status) {
    PaymentStatus.paid => 'Full Payment',
    PaymentStatus.partial => 'Partial Payment',
    PaymentStatus.unpaid => 'Unpaid',
  };
}
