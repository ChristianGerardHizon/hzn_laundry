import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/orders_report_summary.dart';
import 'sales_detail_date_range_controller.dart';

part 'sales_detail_summary_controller.g.dart';

/// Lightweight KPIs for the Orders report tab (view + count queries).
@riverpod
Future<OrdersReportSummary> salesDetailSummary(Ref ref) async {
  final dateRange = ref.watch(salesDetailDateRangeControllerProvider);
  final branchScope = PBFilters.forBranchOrOrganization(
    branchId: ref.watch(currentBranchIdProvider),
    organizationId: ref.watch(currentOrganizationIdProvider),
  );
  final repository = ref.read(salesRepositoryProvider);

  final result = await repository.getOrdersReportSummary(
    startDate: dateRange.start,
    endDate: dateRange.end,
    branchScope: branchScope,
  );

  return result.fold((failure) => throw failure, (summary) => summary);
}
