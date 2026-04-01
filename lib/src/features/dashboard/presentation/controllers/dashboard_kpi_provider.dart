import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'inventory_alerts_controller.dart';

part 'dashboard_kpi_provider.g.dart';

/// Count of products that are near expiration (within 30 days).
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.
@riverpod
Future<int> productsNearExpirationCount(Ref ref) async {
  return ref.watch(nearExpirationAlertsCountProvider.future);
}

/// Count of products that are expired.
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.
@riverpod
Future<int> productsExpiredCount(Ref ref) async {
  return ref.watch(expiredAlertsCountProvider.future);
}

/// Count of products with low stock.
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.
@riverpod
Future<int> lowStockProductsCount(Ref ref) async {
  return ref.watch(lowStockAlertsCountProvider.future);
}
