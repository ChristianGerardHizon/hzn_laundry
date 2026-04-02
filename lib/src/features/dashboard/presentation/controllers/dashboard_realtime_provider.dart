import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import 'inventory_alerts_controller.dart';
import 'kanban_sales_controller.dart';
import 'dashboard_kpi_provider.dart';
import 'new_customers_controller.dart';
import 'sales_summary_controller.dart';
import 'todays_sales_controller.dart';
import 'top_selling_controller.dart';

part 'dashboard_realtime_provider.g.dart';

/// Subscribes to PocketBase realtime events for collections that affect the
/// dashboard, and invalidates the relevant providers when changes occur.
///
/// Uses PocketBase's built-in `PB_CONNECT` event to detect reconnections and
/// refresh all dashboard data, ensuring the UI stays in sync even after
/// network interruptions (common on web/mobile).
///
/// Usage: Simply `ref.watch(dashboardRealtimeProvider)` from the dashboard
/// page to activate subscriptions. They are automatically cleaned up when
/// the provider is disposed (i.e. when navigating away from the dashboard).
@riverpod
Raw<void> dashboardRealtime(Ref ref) {
  final pb = ref.read(pocketbaseProvider);

  // Debounce rapid-fire events (e.g. bulk updates) into a single refresh.
  Timer? salesDebounce;
  Timer? inventoryDebounce;
  Timer? customerDebounce;

  void invalidateSalesProviders() {
    salesDebounce?.cancel();
    salesDebounce = Timer(const Duration(milliseconds: 500), () {
      ref.invalidate(kanbanSalesProvider);
      ref.invalidate(todayCountProvider);
      ref.invalidate(notPickedUpCountProvider);
      ref.invalidate(salesSummaryProvider);
      ref.invalidate(todaySalesSummaryProvider);
      ref.invalidate(topSellingProductsProvider);
      ref.invalidate(topSellingServicesProvider);
    });
  }

  void invalidateInventoryProviders() {
    inventoryDebounce?.cancel();
    inventoryDebounce = Timer(const Duration(milliseconds: 500), () {
      ref.invalidate(inventoryAlertsSummaryProvider);
      ref.invalidate(productsNearExpirationCountProvider);
      ref.invalidate(productsExpiredCountProvider);
      ref.invalidate(lowStockProductsCountProvider);
    });
  }

  void invalidateCustomerProviders() {
    customerDebounce?.cancel();
    customerDebounce = Timer(const Duration(milliseconds: 500), () {
      ref.invalidate(todaysNewCustomersCountProvider);
    });
  }

  void invalidateAllProviders() {
    invalidateSalesProviders();
    invalidateInventoryProviders();
    invalidateCustomerProviders();
  }

  // Track whether this is the initial connection (skip refresh on first connect).
  var isFirstConnect = true;

  // Listen for PB_CONNECT events — fired on initial connection and every
  // reconnect. On reconnect we refresh all data since we may have missed
  // events while disconnected.
  pb.realtime.subscribe('PB_CONNECT', (_) {
    if (isFirstConnect) {
      isFirstConnect = false;
      debugPrint('[DASHBOARD_REALTIME] Connected (clientId: ${pb.realtime.clientId})');
      return;
    }
    debugPrint('[DASHBOARD_REALTIME] Reconnected — refreshing all dashboard data');
    invalidateAllProviders();
  });

  // Log disconnections for debugging.
  final previousOnDisconnect = pb.realtime.onDisconnect;
  pb.realtime.onDisconnect = (subscriptions) {
    debugPrint(
      '[DASHBOARD_REALTIME] Disconnected. '
      '${subscriptions.length} subscription topic(s) will auto-reconnect.',
    );
    previousOnDisconnect?.call(subscriptions);
  };

  // Collections to subscribe to and their handlers.
  final collectionSubscriptions = <String, void Function(RecordSubscriptionEvent)>{
    PocketBaseCollections.sales: (_) => invalidateSalesProviders(),
    PocketBaseCollections.payments: (_) => invalidateSalesProviders(),
    PocketBaseCollections.saleServiceItems: (_) => invalidateSalesProviders(),
    PocketBaseCollections.saleItems: (_) => invalidateSalesProviders(),
    PocketBaseCollections.productStocks: (_) => invalidateInventoryProviders(),
    PocketBaseCollections.productLots: (_) => invalidateInventoryProviders(),
    PocketBaseCollections.customers: (_) => invalidateCustomerProviders(),
  };

  // Subscribe to all collections.
  for (final entry in collectionSubscriptions.entries) {
    _safeSubscribe(pb, entry.key, entry.value);
  }

  // Cleanup: unsubscribe when leaving the dashboard.
  ref.onDispose(() {
    salesDebounce?.cancel();
    inventoryDebounce?.cancel();
    customerDebounce?.cancel();

    // Restore previous onDisconnect handler.
    pb.realtime.onDisconnect = previousOnDisconnect;

    // Unsubscribe from PB_CONNECT and all collection subscriptions.
    pb.realtime.unsubscribe('PB_CONNECT');
    for (final collection in collectionSubscriptions.keys) {
      _safeUnsubscribe(pb, collection);
    }
  });
}

Future<void> _safeSubscribe(
  PocketBase pb,
  String collection,
  void Function(RecordSubscriptionEvent) handler,
) async {
  try {
    await pb.collection(collection).subscribe('*', handler);
  } catch (e) {
    debugPrint('[DASHBOARD_REALTIME] Failed to subscribe to $collection: $e');
  }
}

Future<void> _safeUnsubscribe(PocketBase pb, String collection) async {
  try {
    await pb.collection(collection).unsubscribe('*');
  } catch (e) {
    debugPrint(
        '[DASHBOARD_REALTIME] Failed to unsubscribe from $collection: $e');
  }
}
