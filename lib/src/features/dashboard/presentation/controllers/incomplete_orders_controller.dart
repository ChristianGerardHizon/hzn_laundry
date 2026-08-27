import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/incomplete_orders.dart';
import 'dashboard_date_override_provider.dart';

part 'incomplete_orders_controller.g.dart';

bool _isOnDashboardDay(DateTime? date, DateTime dayStart, DateTime dayEnd) {
  if (date == null) return false;
  return !date.isBefore(dayStart) && date.isBefore(dayEnd);
}

/// Open processing orders plus Ready / same-day Picked Up orders missing
/// machines or packs.
@Riverpod(keepAlive: true)
Future<IncompleteOrdersData> incompleteOrders(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);
  final now = ref.watch(dashboardEffectiveDateProvider);
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final startUtc = dayStart.toPocketBaseUtc();
  final endUtc = dayEnd.toPocketBaseUtc();

  final branchFilter = branchId != null ? ' && branch = "$branchId"' : '';
  final openFilter =
      "status != 'voided' && (orderStatus = 'processing' || orderStatus = 'ready')$branchFilter";
  final pickedUpFilter =
      "status != 'voided' && orderStatus = 'pickedUp'$branchFilter && "
      '((pickedUpAt >= "$startUtc" && pickedUpAt < "$endUtc") || '
      '(postedDate >= "$startUtc" && postedDate < "$endUtc"))';

  final results = await Future.wait([
    pb.collection(PocketBaseCollections.sales).getFullList(
          filter: openFilter,
          sort: '-postedDate',
        ),
    pb.collection(PocketBaseCollections.sales).getFullList(
          filter: pickedUpFilter,
          sort: '-postedDate',
        ),
  ]);

  final byId = <String, Sale>{};
  for (final record in [...results[0], ...results[1]]) {
    final sale = SaleDto.fromRecord(record).toEntity();
    byId[sale.id] = sale;
  }
  final sales = byId.values.toList();

  final serviceItemsBySale = <String, List<SaleServiceItem>>{};
  if (sales.isNotEmpty) {
    final saleIdFilters = sales.map((s) => 'sale = "${s.id}"').join(' || ');
    final serviceRecords =
        await pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
              filter: '($saleIdFilters)',
              expand: 'service',
            );
    for (final record in serviceRecords) {
      final serviceExpanded = record.get<RecordModel?>('expand.service');
      final item = SaleServiceItemDto.fromRecord(record).toEntity(
        serviceExpanded: serviceExpanded,
      );
      serviceItemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }
  }

  final orders = <IncompleteOrderEntry>[];
  for (final sale in sales) {
    if (sale.orderStatus == OrderStatus.pickedUp) {
      final pickupDay = sale.pickedUpAt ?? sale.postedDate;
      if (!_isOnDashboardDay(pickupDay, dayStart, dayEnd)) continue;
    }

    final items = serviceItemsBySale[sale.id] ?? const <SaleServiceItem>[];
    final issues = issuesForSale(sale: sale, serviceItems: items);

    if (sale.orderStatus == OrderStatus.processing) {
      orders.add(IncompleteOrderEntry(sale: sale, issues: issues));
      continue;
    }

    final missingData = issues.contains(OrderDataIssue.missingMachines) ||
        issues.contains(OrderDataIssue.missingPacks);
    if (missingData) {
      orders.add(IncompleteOrderEntry(sale: sale, issues: issues));
    }
  }

  orders.sort((a, b) {
    final aDate = a.sale.postedDate ?? a.sale.created ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.sale.postedDate ?? b.sale.created ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  });

  return IncompleteOrdersData(orders: orders);
}
