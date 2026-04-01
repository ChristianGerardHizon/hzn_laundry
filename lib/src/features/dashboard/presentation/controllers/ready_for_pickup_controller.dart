import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'ready_for_pickup_controller.g.dart';

/// Summary of ready-for-pickup sales.
class ReadyForPickupSummary {
  const ReadyForPickupSummary({
    required this.sales,
    required this.paidCount,
    required this.unpaidCount,
  });

  final List<Sale> sales;
  final int paidCount;
  final int unpaidCount;

  int get totalCount => sales.length;
  bool get hasReadySales => sales.isNotEmpty;
}

/// Fetches all sales with orderStatus = 'ready' for the current branch.
/// Sorted by most recent first.
@riverpod
Future<List<Sale>> readyForPickupSales(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  var filter = "orderStatus = '${OrderStatus.ready.name}'";
  if (branchId != null) {
    filter = '$filter && branch = "$branchId"';
  }

  final records = await pb.collection(PocketBaseCollections.sales).getFullList(
        filter: filter,
        sort: '-created',
      );

  return records.map((record) => SaleDto.fromRecord(record).toEntity()).toList();
}

/// Summary of ready-for-pickup sales with paid/unpaid counts.
@riverpod
Future<ReadyForPickupSummary> readyForPickupSummary(Ref ref) async {
  final sales = await ref.watch(readyForPickupSalesProvider.future);

  final paidCount = sales.where((sale) => sale.isPaid).length;
  final unpaidCount = sales.where((sale) => !sale.isPaid).length;

  return ReadyForPickupSummary(
    sales: sales,
    paidCount: paidCount,
    unpaidCount: unpaidCount,
  );
}
