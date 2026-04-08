import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import 'dashboard_date_override_provider.dart';

part 'new_customers_controller.g.dart';

/// Count of new customers registered on the effective dashboard date.
///
/// Queries the customers collection with a date filter on `created`.
/// Customers are global (no branch filter).
@riverpod
Future<int> todaysNewCustomersCount(Ref ref) async {
  final pb = ref.read(pocketbaseProvider);
  final now = ref.watch(dashboardEffectiveDateProvider);
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final result = await pb
      .collection(PocketBaseCollections.customers)
      .getList(
        page: 1,
        perPage: 1,
        filter:
            'created >= "${startOfDay.toUtc().toIso8601String()}" && created < "${endOfDay.toUtc().toIso8601String()}"',
      );

  return result.totalItems;
}
