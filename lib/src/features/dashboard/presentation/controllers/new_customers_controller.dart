import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';

part 'new_customers_controller.g.dart';

/// Count of new customers registered today.
///
/// Queries the customers collection with a date filter on `created`.
/// Customers are global (no branch filter).
@riverpod
Future<int> todaysNewCustomersCount(Ref ref) async {
  final pb = ref.read(pocketbaseProvider);
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);

  final result = await pb
      .collection(PocketBaseCollections.customers)
      .getList(
        page: 1,
        perPage: 1,
        filter: 'created >= "${startOfToday.toUtc().toIso8601String()}"',
      );

  return result.totalItems;
}
