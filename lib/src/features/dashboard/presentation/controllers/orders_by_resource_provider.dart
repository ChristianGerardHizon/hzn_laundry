import 'package:riverpod_annotation/riverpod_annotation.dart';

// ignore_for_file: deprecated_member_use

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/domain/sale.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'dashboard_date_override_provider.dart';

part 'orders_by_resource_provider.g.dart';

/// How to group orders in the "Orders by Resource" view.
enum ResourceGroupMode {
  storage,
  machine;

  String get displayName => switch (this) {
        ResourceGroupMode.machine => 'Machine',
        ResourceGroupMode.storage => 'Storage',
      };
}

/// Date filter mode for orders by resource.
enum ResourceDateMode {
  todayAndBacklogs,
  todayOnly,
  backlogsOnly;

  String get displayName => switch (this) {
        ResourceDateMode.todayAndBacklogs => 'Today + Backlogs',
        ResourceDateMode.todayOnly => 'Today Only',
        ResourceDateMode.backlogsOnly => 'Backlogs Only',
      };
}

/// Filter parameters for the orders-by-resource query.
class OrdersByResourceFilter {
  const OrdersByResourceFilter({
    this.groupMode = ResourceGroupMode.machine,
    this.machineId,
    this.storageId,
    this.dateMode = ResourceDateMode.todayAndBacklogs,
  });

  final ResourceGroupMode groupMode;
  final String? machineId;
  final String? storageId;
  final ResourceDateMode dateMode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdersByResourceFilter &&
          groupMode == other.groupMode &&
          machineId == other.machineId &&
          storageId == other.storageId &&
          dateMode == other.dateMode;

  @override
  int get hashCode => Object.hash(groupMode, machineId, storageId, dateMode);
}

/// A group of orders assigned to a specific resource (machine or storage).
class ResourceOrderGroup {
  const ResourceOrderGroup({
    required this.resourceId,
    required this.resourceName,
    required this.serviceItems,
    required this.sales,
  });

  final String resourceId;
  final String resourceName;
  final List<SaleServiceItem> serviceItems;

  /// Deduplicated sales referenced by the service items.
  final List<Sale> sales;
}

/// Result data for the orders-by-resource query.
class OrdersByResourceData {
  const OrdersByResourceData({
    required this.groups,
    required this.unassigned,
  });

  final List<ResourceOrderGroup> groups;

  /// Service items with no machine/storage assigned.
  final ResourceOrderGroup unassigned;

  int get totalServiceItems =>
      groups.fold(0, (sum, g) => sum + g.serviceItems.length) +
      unassigned.serviceItems.length;
}

/// Fetches sale service items filtered by date/branch and groups them
/// by machine or storage location.
@riverpod
Future<OrdersByResourceData> ordersByResource(
  Ref ref,
  OrdersByResourceFilter filter,
) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  final startUtc = todayStart.toPocketBaseUtc();
  final endUtc = todayEnd.toPocketBaseUtc();

  // Build date filter
  final todayFilter =
      "sale.postedDate >= '$startUtc' && sale.postedDate < '$endUtc'";
  final backlogFilter =
      "sale.postedDate < '$startUtc' && sale.orderStatus != 'pickedUp'";

  String dateFilter;
  switch (filter.dateMode) {
    case ResourceDateMode.todayAndBacklogs:
      dateFilter = '($todayFilter || $backlogFilter)';
    case ResourceDateMode.todayOnly:
      dateFilter = '($todayFilter)';
    case ResourceDateMode.backlogsOnly:
      dateFilter = '($backlogFilter)';
  }

  var pbFilter = "sale.status != 'voided' && $dateFilter";

  // Branch filter
  if (branchId != null) {
    pbFilter += ' && sale.branch = "$branchId"';
  }

  // Machine/storage filter
  if (filter.machineId != null) {
    pbFilter += ' && machine ~ "${filter.machineId}"';
  }
  if (filter.storageId != null) {
    pbFilter += ' && storage ~ "${filter.storageId}"';
  }

  final records =
      await pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
            filter: pbFilter,
            expand: 'sale,service,machine,storage',
            sort: '-sale.postedDate',
          );

  // Parse records into entities
  final items = <SaleServiceItem>[];
  final salesMap = <String, Sale>{};

  for (final record in records) {
    // Access expanded relations through the expand map.
    // List relations (machine, storage) return List<RecordModel>.
    // Single relations (service, sale) return List<RecordModel> with one element.
    final expandMap = record.expand;

    final serviceExpanded = expandMap['service']?.firstOrNull;
    final machineExpanded = expandMap['machine']?.firstOrNull;
    final storageExpanded = expandMap['storage'];

    final item = SaleServiceItemDto.fromRecord(record).toEntity(
      serviceExpanded: serviceExpanded,
      machineExpanded: machineExpanded,
      storageExpanded: storageExpanded,
    );
    items.add(item);

    // Parse sale from expansion if not already seen
    if (!salesMap.containsKey(item.saleId)) {
      final saleExpanded = expandMap['sale']?.firstOrNull;
      if (saleExpanded != null) {
        salesMap[item.saleId] = SaleDto.fromRecord(saleExpanded).toEntity();
      }
    }
  }

  // Group by resource
  if (filter.groupMode == ResourceGroupMode.machine) {
    return _groupByMachine(items, salesMap);
  } else {
    return _groupByStorage(items, salesMap);
  }
}

OrdersByResourceData _groupByMachine(
  List<SaleServiceItem> items,
  Map<String, Sale> salesMap,
) {
  final grouped = <String, List<SaleServiceItem>>{};
  final unassignedItems = <SaleServiceItem>[];

  for (final item in items) {
    if (item.machineId != null && item.machineId!.isNotEmpty) {
      grouped.putIfAbsent(item.machineId!, () => []).add(item);
    } else {
      unassignedItems.add(item);
    }
  }

  final groups = grouped.entries.map((entry) {
    final groupItems = entry.value;
    final saleIds = groupItems.map((i) => i.saleId).toSet();
    final sales =
        saleIds.map((id) => salesMap[id]).whereType<Sale>().toList();

    // Use machine name from first item that has it
    final machineName = groupItems
            .where((i) => i.machine != null)
            .map((i) => i.machine!.name)
            .firstOrNull ??
        groupItems
            .map((i) => i.machineName)
            .firstWhere((n) => n != null && n.isNotEmpty, orElse: () => null) ??
        'Unknown Machine';

    return ResourceOrderGroup(
      resourceId: entry.key,
      resourceName: machineName,
      serviceItems: groupItems,
      sales: sales,
    );
  }).toList()
    ..sort((a, b) => a.resourceName.compareTo(b.resourceName));

  final unassignedSaleIds = unassignedItems.map((i) => i.saleId).toSet();
  final unassignedSales =
      unassignedSaleIds.map((id) => salesMap[id]).whereType<Sale>().toList();

  return OrdersByResourceData(
    groups: groups,
    unassigned: ResourceOrderGroup(
      resourceId: '',
      resourceName: 'Unassigned',
      serviceItems: unassignedItems,
      sales: unassignedSales,
    ),
  );
}

OrdersByResourceData _groupByStorage(
  List<SaleServiceItem> items,
  Map<String, Sale> salesMap,
) {
  final grouped = <String, List<SaleServiceItem>>{};
  final unassignedItems = <SaleServiceItem>[];
  final storageNames = <String, String>{};

  for (final item in items) {
    if (item.storageIds.isNotEmpty) {
      for (final storageId in item.storageIds) {
        grouped.putIfAbsent(storageId, () => []).add(item);

        // Track storage name from expanded data
        if (!storageNames.containsKey(storageId)) {
          final loc = item.storageLocations
              .where((s) => s.id == storageId)
              .firstOrNull;
          if (loc != null) {
            storageNames[storageId] = loc.name;
          }
        }
      }
    } else {
      unassignedItems.add(item);
    }
  }

  final groups = grouped.entries.map((entry) {
    final groupItems = entry.value;
    final saleIds = groupItems.map((i) => i.saleId).toSet();
    final sales =
        saleIds.map((id) => salesMap[id]).whereType<Sale>().toList();

    return ResourceOrderGroup(
      resourceId: entry.key,
      resourceName: storageNames[entry.key] ?? 'Unknown Storage',
      serviceItems: groupItems,
      sales: sales,
    );
  }).toList()
    ..sort((a, b) => a.resourceName.compareTo(b.resourceName));

  final unassignedSaleIds = unassignedItems.map((i) => i.saleId).toSet();
  final unassignedSales =
      unassignedSaleIds.map((id) => salesMap[id]).whereType<Sale>().toList();

  return OrdersByResourceData(
    groups: groups,
    unassigned: ResourceOrderGroup(
      resourceId: '',
      resourceName: 'Unassigned',
      serviceItems: unassignedItems,
      sales: unassignedSales,
    ),
  );
}
