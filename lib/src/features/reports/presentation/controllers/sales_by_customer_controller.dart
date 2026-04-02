import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/customer_sales_entry.dart';
import 'sales_by_customer_date_range_controller.dart';

part 'sales_by_customer_controller.g.dart';

/// Fetches sales by customer from the [vw_sales_by_customer] view.
///
/// Uses branch filter on the query, then filters by date range in Dart
/// (view date fields are JSON type, not filterable via PB date operators).
@riverpod
Future<List<CustomerSalesEntry>> salesByCustomer(Ref ref) async {
  final dateRange = ref.watch(salesByCustomerDateRangeControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final branchFilter =
      branchId != null ? 'branch = "$branchId"' : null;

  final records = await pb
      .collection(PocketBaseCollections.vwSalesByCustomer)
      .getFullList(filter: branchFilter);

  // Filter by date range in Dart
  final startDay = DateTime(
      dateRange.start.year, dateRange.start.month, dateRange.start.day);
  final endDay =
      DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);

  // The view is grouped per customer per day — filter then re-aggregate
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
