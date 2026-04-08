import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'dashboard_date_override_provider.dart';

part 'todays_sales_controller.g.dart';

/// Record class for today's sales summary.
class TodaySalesSummary {
  const TodaySalesSummary({
    required this.count,
    required this.total,
  });

  final int count;
  final num total;
}

/// Sales data for the effective dashboard date.
/// Filtered by the current branch.
@riverpod
Future<List<Sale>> todaySales(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final effectiveDate = ref.watch(dashboardEffectiveDateProvider);
  final result = await ref.read(salesRepositoryProvider).getSales(
    branchId: branchId,
    date: effectiveDate,
  );
  return result.fold(
    (failure) => [],
    (sales) => sales,
  );
}

/// Sales summary (count and total amount) for the effective dashboard date.
/// When viewing today, uses vw_todays_sales view for optimized query.
/// When viewing a different date, queries the sales collection directly.
/// Filtered by the current branch.
@riverpod
Future<TodaySalesSummary> todaySalesSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);
  final isOverridden = ref.watch(isDashboardDateOverriddenProvider);

  if (!isOverridden) {
    // Use the optimized view for today
    final records = await pb
        .collection(PocketBaseCollections.vwTodaysSales)
        .getFullList(
          filter: branchId != null ? 'branch = "$branchId"' : null,
        );

    if (records.isEmpty) {
      return const TodaySalesSummary(count: 0, total: 0);
    }

    final record = records.first;
    return TodaySalesSummary(
      count: record.getIntValue('transaction_count'),
      total: record.getDoubleValue('total_revenue'),
    );
  }

  // Query sales collection directly for the overridden date
  final effectiveDate = ref.watch(dashboardEffectiveDateProvider);
  final dayStart = DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final startUtc = dayStart.toPocketBaseUtc();
  final endUtc = dayEnd.toPocketBaseUtc();

  var filter =
      "status != 'voided' && postedDate >= '$startUtc' && postedDate < '$endUtc'";
  if (branchId != null) {
    filter = '$filter && branch = "$branchId"';
  }

  final records = await pb
      .collection(PocketBaseCollections.sales)
      .getFullList(filter: filter);

  int count = records.length;
  num total = 0;
  for (final record in records) {
    total += record.getDoubleValue('totalAmount');
  }

  return TodaySalesSummary(count: count, total: total);
}
