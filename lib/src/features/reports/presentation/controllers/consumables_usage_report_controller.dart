import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../dashboard/domain/consumables_usage_summary.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../pos/data/repositories/sale_consumable_usage_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'consumables_usage_date_range_controller.dart';

part 'consumables_usage_report_controller.g.dart';

/// Consumable usage for the selected report period (non-voided, non-refunded).
@riverpod
Future<ConsumablesUsageSummaryData> consumablesUsageReport(Ref ref) async {
  final dateRange = ref.watch(consumablesUsageDateRangeControllerProvider);
  final branchScope = PBFilters.forBranchOrOrganization(
    branchId: ref.watch(currentBranchIdProvider),
    organizationId: ref.watch(currentOrganizationIdProvider),
    branchField: 'sale.branch',
  );

  final usagesResult = await ref
      .read(saleConsumableUsageRepositoryProvider)
      .fetchForDateRange(
        startDate: dateRange.start,
        endDate: dateRange.end,
        branchScope: branchScope,
      );
  final usages = usagesResult.fold((failure) => throw failure, (list) => list);

  final orderIds = usages.map((u) => u.saleId).toSet();

  return ConsumablesUsageSummaryData.fromUsages(
    usages: usages,
    orderCount: orderIds.length,
  );
}
