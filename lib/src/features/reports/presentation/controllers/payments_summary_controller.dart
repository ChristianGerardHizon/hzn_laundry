import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../pos/data/repositories/payment_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/payments_summary.dart';
import 'payments_date_range_controller.dart';

part 'payments_summary_controller.g.dart';

/// Fetches aggregated payment summary from [vw_payments_daily_summary].
@riverpod
Future<List<PaymentsDailySummaryEntry>> paymentsSummary(Ref ref) async {
  final dateRange = ref.watch(paymentsDateRangeControllerProvider);
  final branchScope = PBFilters.forBranchOrOrganization(
    branchId: ref.watch(currentBranchIdProvider),
    organizationId: ref.watch(currentOrganizationIdProvider),
  );
  final repository = ref.read(paymentRepositoryProvider);

  final result = await repository.getDailySummaryForDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
    branchScope: branchScope,
  );

  return result.fold(
    (failure) => throw failure,
    (entries) => entries,
  );
}
