import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/data/dto/sale_item_dto.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'dashboard_date_override_provider.dart';

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
    this.saleItemsBySale = const {},
  });

  final List<Sale> pending;
  final List<Sale> processing;
  final List<Sale> ready;
  final List<Sale> pickedUp;

  /// Map of sale ID to its service items (for displaying machine/storage info).
  final Map<String, List<SaleServiceItem>> serviceItemsBySale;

  /// Map of sale ID to its sale items / addons.
  final Map<String, List<SaleItem>> saleItemsBySale;

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

  /// Returns sale items (addons) for a given sale.
  List<SaleItem> saleItemsForSale(String saleId) =>
      saleItemsBySale[saleId] ?? [];

  /// Total count of all sales.
  int get totalCount =>
      pending.length + processing.length + ready.length + pickedUp.length;

  /// Returns a new [KanbanSalesData] with sales filtered by search query.
  /// Matches against customer name and receipt number (case-insensitive).
  KanbanSalesData filterByQuery(String query) {
    if (query.isEmpty) return this;
    final q = query.toLowerCase();
    bool matches(Sale s) {
      final name = s.customerDisplay?.toLowerCase() ?? '';
      final receipt = s.receiptNumber.toLowerCase();
      return name.contains(q) || receipt.contains(q);
    }

    return KanbanSalesData(
      pending: pending.where(matches).toList(),
      processing: processing.where(matches).toList(),
      ready: ready.where(matches).toList(),
      pickedUp: pickedUp.where(matches).toList(),
      serviceItemsBySale: serviceItemsBySale,
      saleItemsBySale: saleItemsBySale,
    );
  }
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

/// Count of backlog orders (not yet picked up, created before today).
/// Used to display a badge on the "Backlogs" filter chip.
@riverpod
Future<int> notPickedUpCount(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final todayStart = DateTime(now.year, now.month, now.day);
  final startUtc = todayStart.toPocketBaseUtc();

  var filter =
      "status != 'voided' && postedDate < '$startUtc' && (orderStatus != 'pickedUp' || pickedUpAt >= '$startUtc')";
  if (branchId != null) {
    filter = '$filter && branch = "$branchId"';
  }

  final result = await pb.collection(PocketBaseCollections.sales).getList(
        page: 1,
        perPage: 1,
        filter: filter,
      );

  return result.totalItems;
}

/// Count of backlog orders still in 'pending' status (not yet started).
/// Used to surface an at-a-glance warning on the Backlogs filter chip
/// regardless of which filter is currently active.
@riverpod
Future<int> backlogPendingCount(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final todayStart = DateTime(now.year, now.month, now.day);
  final startUtc = todayStart.toPocketBaseUtc();

  var filter =
      "status != 'voided' && postedDate < '$startUtc' && orderStatus = 'pending'";
  if (branchId != null) {
    filter = '$filter && branch = "$branchId"';
  }

  final result = await pb.collection(PocketBaseCollections.sales).getList(
        page: 1,
        perPage: 1,
        filter: filter,
      );

  return result.totalItems;
}

/// Count of orders created today.
/// Used to display a badge on the "Today's Orders" filter chip.
@riverpod
Future<int> todayCount(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  final startUtc = todayStart.toPocketBaseUtc();
  final endUtc = todayEnd.toPocketBaseUtc();

  var filter =
      "status != 'voided' && postedDate >= '$startUtc' && postedDate < '$endUtc'";
  if (branchId != null) {
    filter = '$filter && branch = "$branchId"';
  }

  final result = await pb.collection(PocketBaseCollections.sales).getList(
        page: 1,
        perPage: 1,
        filter: filter,
      );

  return result.totalItems;
}

/// Counts orders in the opposite tab that match the given search query.
/// When on "Today's Orders", counts matching backlog orders, and vice versa.
/// Returns 0 when query is empty.
@riverpod
Future<int> crossTabSearchCount(Ref ref, String query) async {
  if (query.isEmpty) return 0;

  final branchId = ref.watch(currentBranchIdProvider);
  final filterMode = ref.watch(kanbanFilterProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final todayStart = DateTime(now.year, now.month, now.day);
  final startUtc = todayStart.toPocketBaseUtc();

  // Build the opposite filter
  var filter = "status != 'voided'";
  if (branchId != null) {
    filter = '$filter && branch = "$branchId"';
  }

  switch (filterMode) {
    case KanbanFilterMode.today:
      // We're on today — search in backlogs
      filter =
          '$filter && postedDate < "$startUtc" && (orderStatus != "pickedUp" || pickedUpAt >= "$startUtc")';
    case KanbanFilterMode.notPickedUp:
      // We're on backlogs — search in today
      final todayEnd = todayStart.add(const Duration(days: 1));
      final endUtc = todayEnd.toPocketBaseUtc();
      filter =
          '$filter && postedDate >= "$startUtc" && postedDate < "$endUtc"';
  }

  // Add search filter
  final q = query.replaceAll("'", "\\'");
  filter =
      '$filter && (customerName ~ "$q" || receiptNumber ~ "$q")';

  final result = await pb.collection(PocketBaseCollections.sales).getList(
        page: 1,
        perPage: 1,
        filter: filter,
      );

  return result.totalItems;
}

/// Fetches active sales grouped by order status based on the selected filter.
/// - [KanbanFilterMode.today]: All orders created today (any status).
/// - [KanbanFilterMode.notPickedUp]: Orders created before today that haven't been picked up.
/// The two filters are mutually exclusive — no order appears in both.
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

  final now = ref.watch(dashboardEffectiveDateProvider);

  switch (filterMode) {
    case KanbanFilterMode.today:
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final startUtc = todayStart.toPocketBaseUtc();
      final endUtc = todayEnd.toPocketBaseUtc();
      filter = '$filter && postedDate >= "$startUtc" && postedDate < "$endUtc"';
    case KanbanFilterMode.notPickedUp:
      // Show only orders created before the effective date that haven't been picked up
      final todayStart = DateTime(now.year, now.month, now.day);
      final startUtc = todayStart.toPocketBaseUtc();
      filter =
          '$filter && postedDate < "$startUtc" && (orderStatus != "pickedUp" || pickedUpAt >= "$startUtc")';
  }

  final records =
      await pb.collection(PocketBaseCollections.sales).getFullList(
            filter: filter,
            sort: '-postedDate',
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

  // Fetch service items and sale items for all sales
  final allSaleIds = sales.map((s) => s.id).toList();

  final Map<String, List<SaleServiceItem>> serviceItemsBySale = {};
  final Map<String, List<SaleItem>> saleItemsBySale = {};

  if (allSaleIds.isNotEmpty) {
    final saleIdFilters =
        allSaleIds.map((id) => 'sale = "$id"').join(' || ');

    // Fetch service items and sale items in parallel
    final results = await Future.wait([
      pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
            filter: '($saleIdFilters)',
            expand: 'service',
          ),
      pb
          .collection(PocketBaseCollections.saleItems)
          .getFullList(filter: '($saleIdFilters)'),
    ]);

    for (final record in results[0]) {
      final serviceExpanded = record.get<RecordModel?>('expand.service');
      final item = SaleServiceItemDto.fromRecord(record).toEntity(
            serviceExpanded: serviceExpanded,
          );
      serviceItemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }

    for (final record in results[1]) {
      final item = SaleItemDto.fromRecord(record).toEntity();
      saleItemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }
  }

  return KanbanSalesData(
    pending: pending,
    processing: processing,
    ready: ready,
    pickedUp: pickedUp,
    serviceItemsBySale: serviceItemsBySale,
    saleItemsBySale: saleItemsBySale,
  );
}
