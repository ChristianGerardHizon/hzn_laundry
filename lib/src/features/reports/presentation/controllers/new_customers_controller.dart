import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../customers/data/repositories/customer_repository.dart';
import '../../../customers/domain/customer.dart';
import 'new_customers_date_range_controller.dart';

part 'new_customers_controller.g.dart';

/// Fetches all customers created within the selected date range.
@riverpod
Future<List<Customer>> newCustomersReport(Ref ref) async {
  final dateRange = ref.watch(newCustomersDateRangeControllerProvider);
  final repository = ref.read(customerRepositoryProvider);

  final result = await repository.fetchForDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
  );

  return result.fold(
    (failure) => throw failure,
    (customers) => customers,
  );
}
