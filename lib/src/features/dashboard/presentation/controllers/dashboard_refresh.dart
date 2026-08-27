import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderOrFamily;

import '../../../employees/presentation/controllers/attendance_controller.dart';
import '../../../employees/presentation/controllers/employees_controller.dart';
import 'add_ons_summary_controller.dart';
import 'dashboard_kpi_provider.dart';
import 'inventory_alerts_controller.dart';
import 'kanban_sales_controller.dart';
import 'loads_summary_controller.dart';
import 'incomplete_orders_controller.dart';
import 'new_customers_controller.dart';
import 'orders_by_resource_provider.dart';
import 'ready_for_pickup_controller.dart';
import 'sales_summary_controller.dart';
import 'today_incentive_controller.dart';
import 'todays_sales_controller.dart';
import 'top_selling_controller.dart';
import 'total_packs_summary_controller.dart';

/// Invalidates every provider that feeds the dashboard UI.
///
/// Used by the manual refresh button, pull-to-refresh, and realtime reconnect
/// so all sections stay in sync — not just the KPI cards.
void invalidateAllDashboardProviders(
  void Function(ProviderOrFamily provider) invalidate,
) {
  // Sales / KPIs
  invalidate(salesSummaryProvider);
  invalidate(totalPacksSummaryProvider);
  invalidate(addOnsSummaryProvider);
  invalidate(loadsSummaryProvider);
  invalidate(incompleteOrdersProvider);
  invalidate(todaySalesProvider);
  invalidate(todaySalesSummaryProvider);
  invalidate(todayIncentiveSummaryProvider);
  invalidate(topSellingProductsProvider);
  invalidate(topSellingServicesProvider);
  invalidate(todaysNewCustomersCountProvider);

  // Kanban / orders
  invalidate(kanbanSalesProvider);
  invalidate(todayCountProvider);
  invalidate(notPickedUpCountProvider);
  invalidate(backlogPendingCountProvider);
  invalidate(readyForPickupSalesProvider);
  invalidate(readyForPickupSummaryProvider);
  invalidate(ordersByResourceProvider);

  // Inventory alerts
  invalidate(inventoryAlertsSummaryProvider);
  invalidate(productsNearExpirationCountProvider);
  invalidate(productsExpiredCountProvider);
  invalidate(lowStockProductsCountProvider);

  // Attendance alert
  invalidate(employeesControllerProvider);
  invalidate(attendanceControllerProvider);
}

/// Invalidates all dashboard providers and waits for key sections to settle.
Future<void> refreshAllDashboardData(WidgetRef ref) async {
  invalidateAllDashboardProviders(ref.invalidate);

  Future<void> settle(Future<Object?> future) async {
    try {
      await future;
    } catch (_) {}
  }

  await Future.wait([
    settle(ref.read(salesSummaryProvider.future)),
    settle(ref.read(kanbanSalesProvider.future)),
    settle(ref.read(inventoryAlertsSummaryProvider.future)),
  ]);
}
