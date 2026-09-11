import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../dashboard/domain/consumables_usage_summary.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../pos/data/repositories/sale_consumable_usage_repository.dart';
import '../../../pos/data/repositories/sales_repository.dart';
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
  );
  final salesResult =
      await ref.read(salesRepositoryProvider).getSalesForDateRange(
            startDate: dateRange.start,
            endDate: dateRange.end,
            branchScope: branchScope,
          );

  final sales = salesResult.fold((failure) => throw failure, (list) => list);
  final included = sales
      .where((sale) => sale.status != 'voided' && sale.status != 'refunded')
      .toList();
  final saleIds = included.map((s) => s.id).toList();

  final usagesResult = await ref
      .read(saleConsumableUsageRepositoryProvider)
      .fetchForSales(saleIds);
  final usages = usagesResult.fold((failure) => throw failure, (list) => list);

  return ConsumablesUsageSummaryData.fromUsages(
    usages: usages,
    orderCount: saleIds.length,
  );
}
