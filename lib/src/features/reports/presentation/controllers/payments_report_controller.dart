import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../pos/data/repositories/payment_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/payment_report_entry.dart';
import 'payments_date_range_controller.dart';

part 'payments_report_controller.g.dart';

/// Fetches all payments within the selected date range with sale context.
@riverpod
Future<List<PaymentReportEntry>> paymentsReport(Ref ref) async {
  final dateRange = ref.watch(paymentsDateRangeControllerProvider);
  final branchScope = PBFilters.forBranchOrOrganization(
    branchId: ref.watch(currentBranchIdProvider),
    organizationId: ref.watch(currentOrganizationIdProvider),
    branchField: 'sale.branch',
  );
  final repository = ref.read(paymentRepositoryProvider);

  final result = await repository.getForDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
    branchScope: branchScope,
  );

  return result.fold(
    (failure) => throw failure,
    (entries) => entries,
  );
}
