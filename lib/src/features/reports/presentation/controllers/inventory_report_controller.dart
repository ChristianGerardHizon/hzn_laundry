import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/inventory_report.dart';

part 'inventory_report_controller.g.dart';

/// Fetches and provides inventory report data.
/// Note: Inventory report doesn't use date filtering - it shows current state.
@riverpod
Future<InventoryReport> inventoryReport(Ref ref) async {
  final filter = ref.watch(currentBranchFilterProvider);
  final repository = ref.read(reportsRepositoryProvider);

  final result = await repository.getInventoryReport(filter: filter);

  return result.fold(
    (failure) => throw failure,
    (report) => report,
  );
}
