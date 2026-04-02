import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/domain/sale.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'sales_detail_date_range_controller.dart';

part 'sales_detail_controller.g.dart';

/// Fetches all sales within the selected date range for the Orders report tab.
@riverpod
Future<List<Sale>> salesDetail(Ref ref) async {
  final dateRange = ref.watch(salesDetailDateRangeControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(salesRepositoryProvider);

  final result = await repository.getSalesForDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
    branchId: branchId,
  );

  return result.fold(
    (failure) => throw failure,
    (sales) => sales,
  );
}
