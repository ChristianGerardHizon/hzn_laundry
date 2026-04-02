import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/payment_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/payment_report_entry.dart';
import 'payments_date_range_controller.dart';

part 'payments_report_controller.g.dart';

/// Fetches all payments within the selected date range with sale context.
@riverpod
Future<List<PaymentReportEntry>> paymentsReport(Ref ref) async {
  final dateRange = ref.watch(paymentsDateRangeControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(paymentRepositoryProvider);

  final result = await repository.getForDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
    branchId: branchId,
  );

  return result.fold(
    (failure) => throw failure,
    (entries) => entries,
  );
}
