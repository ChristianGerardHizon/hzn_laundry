import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/packs_summary.dart';
import 'dashboard_date_override_provider.dart';

part 'total_packs_summary_controller.g.dart';

/// Provider that aggregates total packs for the effective dashboard date.
///
/// Fetches non-voided orders for the day and sums the `packs` field.
/// Only orders with packs > 0 appear in the breakdown list.
@Riverpod(keepAlive: true)
Future<TotalPacksSummary> totalPacksSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final startUtc = dayStart.toPocketBaseUtc();
  final endUtc = dayEnd.toPocketBaseUtc();

  final branchFilter = branchId != null ? ' && branch = "$branchId"' : '';
  final filter =
      "status != 'voided' && postedDate >= '$startUtc' && postedDate < '$endUtc'$branchFilter";

  final records = await pb
      .collection(PocketBaseCollections.sales)
      .getFullList(filter: filter, sort: '-postedDate');

  var totalPacks = 0;
  final orders = <PacksOrderEntry>[];

  for (final record in records) {
    final packs = record.getIntValue('packs');
    if (packs <= 0) continue;
    totalPacks += packs;
    final customerName = record.getStringValue('customerName');
    orders.add(PacksOrderEntry(
      saleId: record.id,
      receiptNumber: record.getStringValue('receiptNumber'),
      customerName: customerName.isEmpty ? null : customerName,
      packs: packs,
      orderStatus: record.getStringValue('orderStatus'),
    ));
  }

  orders.sort((a, b) => b.packs.compareTo(a.packs));

  return TotalPacksSummary(totalPacks: totalPacks, orders: orders);
}
