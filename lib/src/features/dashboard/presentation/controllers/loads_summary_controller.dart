import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/loads_summary.dart';
import 'dashboard_date_override_provider.dart';

part 'loads_summary_controller.g.dart';

/// Summary of machine loads for the effective dashboard date, broken down per
/// order.
///
/// A load is a machine cycle assigned to a sale's service items
/// (`saleServiceItems.machineLoadCounts`). The per-sale totals are
/// pre-aggregated server-side by the `vw_loads_summary` view (which unrolls
/// the machine-load JSON map and sums it), so this provider only fetches one
/// row per order. Voided sales are excluded by the view.
@Riverpod(keepAlive: true)
Future<LoadsSummaryData> loadsSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final startUtc = dayStart.toPocketBaseUtc();
  final endUtc = dayEnd.toPocketBaseUtc();

  final branchFilter = branchId != null ? ' && branch = "$branchId"' : '';
  final filter =
      "postedDate >= '$startUtc' && postedDate < '$endUtc'$branchFilter";

  final records = await pb
      .collection(PocketBaseCollections.vwLoadsSummary)
      .getFullList(filter: filter, sort: '-postedDate');

  var totalLoads = 0;
  final orders = <LoadsOrderEntry>[];
  for (final record in records) {
    final loads = record.getIntValue('loads');
    if (loads <= 0) continue;
    totalLoads += loads;
    final customerName = record.getStringValue('customerName');
    orders.add(
      LoadsOrderEntry(
        saleId: record.id,
        receiptNumber: record.getStringValue('receiptNumber'),
        loads: loads,
        customerName: customerName.isEmpty ? null : customerName,
      ),
    );
  }

  orders.sort((a, b) => b.loads.compareTo(a.loads));

  return LoadsSummaryData(totalLoads: totalLoads, orders: orders);
}
