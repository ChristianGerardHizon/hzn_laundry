import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'kanban_sales_controller.g.dart';

/// Filter mode for the kanban board.
enum KanbanFilterMode {
  /// Show only orders created today (all statuses).
  today,

  /// Show orders not yet picked up (pending, processing, ready).
  notPickedUp,
}

/// Sales grouped by order status for the kanban board.
class KanbanSalesData {
  const KanbanSalesData({
    required this.pending,
    required this.processing,
    required this.ready,
    required this.pickedUp,
    this.serviceItemsBySale = const {},
  });

  final List<Sale> pending;
  final List<Sale> processing;
  final List<Sale> ready;
  final List<Sale> pickedUp;

  /// Map of sale ID to its service items (for displaying machine/storage info).
  final Map<String, List<SaleServiceItem>> serviceItemsBySale;

  /// Returns the sales list for a given status.
  List<Sale> salesForStatus(OrderStatus status) => switch (status) {
        OrderStatus.pending => pending,
        OrderStatus.processing => processing,
        OrderStatus.ready => ready,
        OrderStatus.pickedUp => pickedUp,
      };

  /// Returns service items for a given sale.
  List<SaleServiceItem> serviceItemsForSale(String saleId) =>
      serviceItemsBySale[saleId] ?? [];

  /// Total count of all sales.
  int get totalCount =>
      pending.length + processing.length + ready.length + pickedUp.length;
}

/// Holds the current kanban filter mode.
@riverpod
class KanbanFilter extends _$KanbanFilter {
  @override
  KanbanFilterMode build() => KanbanFilterMode.today;

  void setFilter(KanbanFilterMode mode) {
    state = mode;
  }
}

/// Fetches active sales grouped by order status based on the selected filter.
/// - [KanbanFilterMode.today]: All orders created today.
/// - [KanbanFilterMode.notPickedUp]: All orders not yet picked up (any date).
/// Filtered by current branch, sorted by most recent first.
/// Also fetches service items for processing/ready sales to display machine/storage.
@riverpod
Future<KanbanSalesData> kanbanSales(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final filterMode = ref.watch(kanbanFilterProvider);
  final pb = ref.read(pocketbaseProvider);

  var filter = "status != 'voided'";
  if (branchId != null) {
    filter = '$filter && branch = "$branchId"';
  }

  switch (filterMode) {
    case KanbanFilterMode.today:
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final startUtc = todayStart.toUtc().toIso8601String();
      final endUtc = todayEnd.toUtc().toIso8601String();
      filter = '$filter && created >= "$startUtc" && created < "$endUtc"';
    case KanbanFilterMode.notPickedUp:
      filter = '$filter && orderStatus != "pickedUp"';
  }

  final records =
      await pb.collection(PocketBaseCollections.sales).getFullList(
            filter: filter,
            sort: '-created',
          );

  final sales =
      records.map((record) => SaleDto.fromRecord(record).toEntity()).toList();

  final pending =
      sales.where((s) => s.orderStatus == OrderStatus.pending).toList();
  final processing =
      sales.where((s) => s.orderStatus == OrderStatus.processing).toList();
  final ready = sales.where((s) => s.orderStatus == OrderStatus.ready).toList();
  final pickedUp =
      sales.where((s) => s.orderStatus == OrderStatus.pickedUp).toList();

  // Fetch service items for processing and ready sales to show machine/storage
  final saleIdsNeedingServiceItems = [
    ...processing.map((s) => s.id),
    ...ready.map((s) => s.id),
  ];

  final Map<String, List<SaleServiceItem>> serviceItemsBySale = {};

  if (saleIdsNeedingServiceItems.isNotEmpty) {
    // Build filter for all relevant sale IDs
    final saleIdFilters =
        saleIdsNeedingServiceItems.map((id) => 'sale = "$id"').join(' || ');
    final serviceItemRecords = await pb
        .collection(PocketBaseCollections.saleServiceItems)
        .getFullList(filter: '($saleIdFilters)');

    for (final record in serviceItemRecords) {
      final item = SaleServiceItemDto.fromRecord(record).toEntity();
      serviceItemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }
  }

  return KanbanSalesData(
    pending: pending,
    processing: processing,
    ready: ready,
    pickedUp: pickedUp,
    serviceItemsBySale: serviceItemsBySale,
  );
}
