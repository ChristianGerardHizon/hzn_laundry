import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/sales_report.dart';
import 'report_period_controller.dart';

part 'sales_report_controller.g.dart';

/// Fetches and provides sales report data.
@riverpod
Future<SalesReport> salesReport(Ref ref) async {
  final period = ref.watch(reportPeriodControllerProvider);
  final branchFilter = ref.watch(currentBranchIdsFilterProvider);
  final repository = ref.read(reportsRepositoryProvider);

  final result = await repository.getSalesReport(
    startDate: period.startDate,
    endDate: period.endDate,
    branchFilter: branchFilter,
  );

  return result.fold(
    (failure) => throw failure,
    (report) => report,
  );
}
