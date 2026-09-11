import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../customers/data/repositories/customer_repository.dart';
import '../../../customers/domain/customer.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'new_customers_date_range_controller.dart';

part 'new_customers_controller.g.dart';

/// Fetches customers created within the selected date range,
/// scoped to the current branch / organization.
@riverpod
Future<List<Customer>> newCustomersReport(Ref ref) async {
  final dateRange = ref.watch(newCustomersDateRangeControllerProvider);
  final branchScope = PBFilters.forBranchOrOrganization(
    branchId: ref.watch(currentBranchIdProvider),
    organizationId: ref.watch(currentOrganizationIdProvider),
  );
  final repository = ref.read(customerRepositoryProvider);

  final result = await repository.fetchForDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
    branchScope: branchScope,
  );

  return result.fold(
    (failure) => throw failure,
    (customers) => customers,
  );
}
