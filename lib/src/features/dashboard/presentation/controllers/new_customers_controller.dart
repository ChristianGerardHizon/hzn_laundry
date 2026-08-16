import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'dashboard_date_override_provider.dart';

part 'new_customers_controller.g.dart';

/// Count of new customers registered on the effective dashboard date.
///
/// Queries the customers collection with a date filter on `created`,
/// scoped to the current branch when one is selected.
@riverpod
Future<int> todaysNewCustomersCount(Ref ref) async {
  final pb = ref.read(pocketbaseProvider);
  final now = ref.watch(dashboardEffectiveDateProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  var filter =
      'created >= "${startOfDay.toUtc().toIso8601String()}" && created < "${endOfDay.toUtc().toIso8601String()}"';
  if (branchId != null) {
    filter = '$filter && branch = "$branchId"';
  }

  final result = await pb.collection(PocketBaseCollections.customers).getList(
        page: 1,
        perPage: 1,
        filter: filter,
      );

  return result.totalItems;
}
