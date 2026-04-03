import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/data/dto/sale_item_dto.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/sales_summary.dart';

part 'sales_summary_controller.g.dart';

/// Today's sales summary including backlog sales paid today.
///
/// Runs two parallel queries:
/// 1. All sales created today (not voided)
/// 2. Payments made today on backlog sales (created before today), with
///    expanded sale records
///
/// Also fetches service items and sale items for all sales to display
/// in the breakdown.
@riverpod
Future<SalesSummaryData> salesSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  final startUtc = todayStart.toPocketBaseUtc();
  final endUtc = todayEnd.toPocketBaseUtc();

  // Branch filter fragments
  final salesBranchFilter =
      branchId != null ? ' && branch = "$branchId"' : '';
  final paymentBranchFilter =
      branchId != null ? ' && sale.branch = "$branchId"' : '';

  // Query 1: Today's sales
  final todaySalesFilter =
      "status != 'voided' && postedDate >= '$startUtc' && postedDate < '$endUtc'$salesBranchFilter";

  // Query 2: Payments made today on backlog sales (sale created before today)
  final backlogPaymentsFilter =
      "postedDate >= '$startUtc' && postedDate < '$endUtc' && sale.postedDate < '$startUtc' && sale.status != 'voided'$paymentBranchFilter";

  final results = await Future.wait([
    pb.collection(PocketBaseCollections.sales).getFullList(
          filter: todaySalesFilter,
          sort: '-postedDate',
        ),
    pb.collection(PocketBaseCollections.payments).getFullList(
          filter: backlogPaymentsFilter,
          expand: 'sale',
        ),
  ]);

  // Parse today's sales
  final todaySales = results[0]
      .map((record) => SaleDto.fromRecord(record).toEntity())
      .toList();
  final todaySaleIds = todaySales.map((s) => s.id).toSet();

  // Parse backlog sales from expanded payment records (deduplicate by sale ID)
  final backlogSalesMap = <String, Sale>{};
  for (final paymentRecord in results[1]) {
    final saleRecord = paymentRecord.get<RecordModel?>('expand.sale');
    if (saleRecord == null) continue;

    final sale = SaleDto.fromRecord(saleRecord).toEntity();
    // Skip if already in today's sales (shouldn't happen, but safety check)
    if (todaySaleIds.contains(sale.id)) continue;
    backlogSalesMap[sale.id] = sale;
  }
  final backlogSales = backlogSalesMap.values.toList();

  // Fetch service items and sale items for all sales
  final allSaleIds = [
    ...todaySaleIds,
    ...backlogSalesMap.keys,
  ];

  final Map<String, List<SaleServiceItem>> serviceItemsBySale = {};
  final Map<String, List<SaleItem>> saleItemsBySale = {};

  if (allSaleIds.isNotEmpty) {
    final saleIdFilters =
        allSaleIds.map((id) => 'sale = "$id"').join(' || ');

    final itemResults = await Future.wait([
      pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
            filter: '($saleIdFilters)',
            expand: 'service',
          ),
      pb
          .collection(PocketBaseCollections.saleItems)
          .getFullList(filter: '($saleIdFilters)'),
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
  }

  // Build summary items
  final items = <SalesSummaryItem>[
    for (final sale in todaySales)
      SalesSummaryItem(
        saleId: sale.id,
        receiptNumber: sale.receiptNumber,
        totalAmount: sale.totalAmount,
        isPaid: sale.isPaid,
        isBacklog: false,
        customerName: sale.customerName,
        postedDate: sale.postedDate,
        serviceItems: serviceItemsBySale[sale.id] ?? [],
        saleItems: saleItemsBySale[sale.id] ?? [],
      ),
    for (final sale in backlogSales)
      SalesSummaryItem(
        saleId: sale.id,
        receiptNumber: sale.receiptNumber,
        totalAmount: sale.totalAmount,
        isPaid: sale.isPaid,
        isBacklog: true,
        customerName: sale.customerName,
        postedDate: sale.postedDate,
        serviceItems: serviceItemsBySale[sale.id] ?? [],
        saleItems: saleItemsBySale[sale.id] ?? [],
      ),
  ];

  // Compute totals
  final allSales = [...todaySales, ...backlogSales];
  final totalSales =
      allSales.fold<num>(0, (sum, s) => sum + s.totalAmount);
  final totalPaid = allSales
      .where((s) => s.isPaid)
      .fold<num>(0, (sum, s) => sum + s.totalAmount);
  final totalUnpaid = allSales
      .where((s) => !s.isPaid)
      .fold<num>(0, (sum, s) => sum + s.totalAmount);

  return SalesSummaryData(
    totalSales: totalSales,
    totalPaid: totalPaid,
    totalUnpaid: totalUnpaid,
    items: items,
  );
}
