import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/domain/sale.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/loads_summary.dart';
import 'dashboard_date_override_provider.dart';

part 'loads_summary_controller.g.dart';

/// Summary of machine loads for the effective dashboard date, broken down per
/// order.
///
/// A load is a machine cycle assigned to a sale's service items
/// (`saleServiceItems.machineLoadCounts`). Loads are summed across every
/// assigned machine of every service item in an order. Voided sales are
/// excluded.
@riverpod
Future<LoadsSummaryData> loadsSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final startUtc = dayStart.toPocketBaseUtc();
  final endUtc = dayEnd.toPocketBaseUtc();

  final salesBranchFilter = branchId != null ? ' && branch = "$branchId"' : '';
  final todaySalesFilter =
      "status != 'voided' && postedDate >= '$startUtc' && postedDate < '$endUtc'$salesBranchFilter";

  final saleRecords =
      await pb.collection(PocketBaseCollections.sales).getFullList(
            filter: todaySalesFilter,
            sort: '-postedDate',
          );

  final sales = <String, Sale>{};
  for (final record in saleRecords) {
    final sale = SaleDto.fromRecord(record).toEntity();
    sales[sale.id] = sale;
  }

  if (sales.isEmpty) {
    return const LoadsSummaryData(totalLoads: 0, orders: []);
  }

  final saleIdFilters = sales.keys.map((id) => 'sale = "$id"').join(' || ');

  final itemRecords =
      await pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
            filter: '($saleIdFilters)',
          );

  // Sum the per-machine load counts for each sale.
  final loadsBySale = <String, int>{};
  for (final record in itemRecords) {
    final item = SaleServiceItemDto.fromRecord(record).toEntity();
    final itemLoads = item.machineLoadCounts.values
        .fold<int>(0, (sum, count) => sum + count);
    loadsBySale[item.saleId] = (loadsBySale[item.saleId] ?? 0) + itemLoads;
  }

  var totalLoads = 0;
  final orders = <LoadsOrderEntry>[];
  for (final entry in loadsBySale.entries) {
    final loads = entry.value;
    if (loads <= 0) continue;
    final sale = sales[entry.key];
    if (sale == null) continue;
    totalLoads += loads;
    orders.add(
      LoadsOrderEntry(
        saleId: sale.id,
        receiptNumber: sale.receiptNumber,
        loads: loads,
        customerName: sale.customerName,
      ),
    );
  }

  orders.sort((a, b) => b.loads.compareTo(a.loads));

  return LoadsSummaryData(totalLoads: totalLoads, orders: orders);
}
