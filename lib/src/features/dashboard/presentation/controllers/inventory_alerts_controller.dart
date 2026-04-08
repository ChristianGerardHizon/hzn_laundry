import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/inventory_alert.dart';
import 'dashboard_date_override_provider.dart';

part 'inventory_alerts_controller.g.dart';

/// Provides comprehensive inventory alerts using optimized SQL views.
///
/// This provider queries 4 separate views in parallel:
/// - vw_low_stock_products (non-lot-tracked)
/// - vw_low_stock_lot_products (lot-tracked)
/// - vw_expired_lots
/// - vw_near_expiration_lots
@riverpod
Future<InventoryAlertsSummary> inventoryAlertsSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);
  final effectiveDate = ref.watch(dashboardEffectiveDateProvider);
  final branchFilter =
      branchId != null ? 'branch = "$branchId"' : null;

  // Query all 4 views in parallel for best performance
  final results = await Future.wait([
    pb
        .collection(PocketBaseCollections.vwLowStockProducts)
        .getFullList(filter: branchFilter),
    pb
        .collection(PocketBaseCollections.vwLowStockLotProducts)
        .getFullList(filter: branchFilter),
    pb
        .collection(PocketBaseCollections.vwExpiredLots)
        .getFullList(filter: branchFilter),
    pb
        .collection(PocketBaseCollections.vwNearExpirationLots)
        .getFullList(filter: branchFilter),
  ]);

  final lowStockRecords = results[0];
  final lowStockLotRecords = results[1];
  final expiredLotRecords = results[2];
  final nearExpirationLotRecords = results[3];

  final lowStockAlerts = <InventoryAlert>[];
  final nearExpirationAlerts = <InventoryAlert>[];
  final expiredAlerts = <InventoryAlert>[];

  // Process non-lot-tracked low stock products
  for (final record in lowStockRecords) {
    lowStockAlerts.add(InventoryAlert(
      productId: record.id,
      productName: record.getStringValue('name'),
      alertType: InventoryAlertType.lowStock,
      isLotTracked: false,
      currentQuantity: record.getDoubleValue('quantity'),
      threshold: record.getDoubleValue('stockThreshold'),
    ));
  }

  // Process lot-tracked low stock products
  for (final record in lowStockLotRecords) {
    lowStockAlerts.add(InventoryAlert(
      productId: record.id,
      productName: record.getStringValue('name'),
      alertType: InventoryAlertType.lowStock,
      isLotTracked: true,
      currentQuantity: record.getDoubleValue('total_quantity'),
      threshold: record.getDoubleValue('stockThreshold'),
    ));
  }

  // Process expired lots
  for (final record in expiredLotRecords) {
    final expirationStr = record.getStringValue('expiration');
    final expiration = DateTime.tryParse(expirationStr);
    final daysUntil = expiration != null
        ? expiration.difference(effectiveDate).inDays
        : null;

    expiredAlerts.add(InventoryAlert(
      productId: record.getStringValue('product_id'),
      productName: record.getStringValue('product_name'),
      alertType: InventoryAlertType.expired,
      isLotTracked: true,
      lotId: record.id,
      lotNumber: record.getStringValue('lotNumber'),
      currentQuantity: record.getDoubleValue('quantity'),
      expirationDate: expiration,
      daysUntilExpiration: daysUntil,
    ));
  }

  // Process near expiration lots
  for (final record in nearExpirationLotRecords) {
    final expirationStr = record.getStringValue('expiration');
    final expiration = DateTime.tryParse(expirationStr);
    final daysUntil = expiration != null
        ? expiration.difference(effectiveDate).inDays
        : null;

    nearExpirationAlerts.add(InventoryAlert(
      productId: record.getStringValue('product_id'),
      productName: record.getStringValue('product_name'),
      alertType: InventoryAlertType.nearExpiration,
      isLotTracked: true,
      lotId: record.id,
      lotNumber: record.getStringValue('lotNumber'),
      currentQuantity: record.getDoubleValue('quantity'),
      expirationDate: expiration,
      daysUntilExpiration: daysUntil,
    ));
  }

  // Sort alerts by severity/urgency
  lowStockAlerts.sort(
      (a, b) => (a.currentQuantity ?? 0).compareTo(b.currentQuantity ?? 0));
  nearExpirationAlerts.sort((a, b) =>
      (a.daysUntilExpiration ?? 999).compareTo(b.daysUntilExpiration ?? 999));
  expiredAlerts.sort((a, b) =>
      (a.daysUntilExpiration ?? 0).compareTo(b.daysUntilExpiration ?? 0));

  return InventoryAlertsSummary(
    lowStockAlerts: lowStockAlerts,
    nearExpirationAlerts: nearExpirationAlerts,
    expiredAlerts: expiredAlerts,
  );
}

/// Count of low stock products (including lot-tracked).
@riverpod
Future<int> lowStockAlertsCount(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.lowStockCount;
}

/// Count of products/lots near expiration.
@riverpod
Future<int> nearExpirationAlertsCount(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.nearExpirationCount;
}

/// Count of expired products/lots.
@riverpod
Future<int> expiredAlertsCount(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.expiredCount;
}

/// List of low stock alerts for display.
@riverpod
Future<List<InventoryAlert>> lowStockAlerts(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.lowStockAlerts;
}

/// List of near expiration alerts for display.
@riverpod
Future<List<InventoryAlert>> nearExpirationAlerts(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.nearExpirationAlerts;
}

/// List of expired alerts for display.
@riverpod
Future<List<InventoryAlert>> expiredAlerts(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.expiredAlerts;
}
