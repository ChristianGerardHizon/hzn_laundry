import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/customer_sales_entry.dart';
import 'sales_by_customer_date_range_controller.dart';

part 'sales_by_customer_controller.g.dart';

/// Raw daily rows from [vw_sales_by_customer] for the current branch scope.
///
/// Kept alive so changing the date range does not re-download the full view.
@Riverpod(keepAlive: true)
Future<List<RecordModel>> salesByCustomerRaw(Ref ref) async {
  final branchFilter = ref.watch(currentBranchIdsFilterProvider);
  final pb = ref.read(pocketbaseProvider);

  return pb
      .collection(PocketBaseCollections.vwSalesByCustomer)
      .getFullList(filter: branchFilter);
}

/// Aggregates cached view rows into per-customer totals for the selected range.
@riverpod
Future<List<CustomerSalesEntry>> salesByCustomer(Ref ref) async {
  final dateRange = ref.watch(salesByCustomerDateRangeControllerProvider);
  final records = await ref.watch(salesByCustomerRawProvider.future);

  final startDay = DateTime(
      dateRange.start.year, dateRange.start.month, dateRange.start.day);
  final endDay =
      DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);

  final map =
      <String, ({String name, int count, num total, num paid, int paidCount})>{};

  for (final record in records) {
    final dateStr = record.get<dynamic>('saleDate')?.toString() ?? '';
    final date = DateTime.tryParse(dateStr);
    if (date == null || date.isBefore(startDay) || date.isAfter(endDay)) {
      continue;
    }

    final customerId = record.getStringValue('customer');
    final key = customerId.isEmpty ? '_walk_in' : customerId;
    final name = record.getStringValue('customerName');
    final orderCount = record.getIntValue('orderCount');
    final totalSpent = record.getDoubleValue('totalSpent');
    final totalPaid = record.getDoubleValue('totalPaid');
    final paidOrderCount = record.getIntValue('paidOrderCount');

    final existing = map[key];
    if (existing != null) {
      map[key] = (
        name: existing.name,
        count: existing.count + orderCount,
        total: existing.total + totalSpent,
        paid: existing.paid + totalPaid,
        paidCount: existing.paidCount + paidOrderCount,
      );
    } else {
      map[key] = (
        name: name.isEmpty ? 'Walk-in' : name,
        count: orderCount,
        total: totalSpent,
        paid: totalPaid,
        paidCount: paidOrderCount,
      );
    }
  }

  final entries = map.entries
      .map((e) => CustomerSalesEntry(
            customerId: e.key == '_walk_in' ? null : e.key,
            customerName: e.value.name,
            orderCount: e.value.count,
            totalSpent: e.value.total,
            totalPaid: e.value.paid,
            paidOrderCount: e.value.paidCount,
          ))
      .toList()
    ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

  return entries;
}
