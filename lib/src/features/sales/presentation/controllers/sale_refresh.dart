import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderOrFamily;

import '../../../dashboard/presentation/controllers/incomplete_orders_controller.dart';
import '../../../dashboard/presentation/controllers/kanban_sales_controller.dart';
import '../../../dashboard/presentation/controllers/ready_for_pickup_controller.dart';
import '../../../dashboard/presentation/controllers/sales_summary_controller.dart';
import 'paginated_sales_controller.dart';
import 'sale_items_provider.dart';
import 'sale_provider.dart';
import 'sale_service_items_provider.dart';

typedef _Invalidate = void Function(ProviderOrFamily provider);

/// Core invalidations after a sale or payment mutation.
void invalidateSaleRelatedProviders(
  _Invalidate invalidate, {
  required String saleId,
}) {
  invalidate(saleProvider(saleId));
  invalidate(saleItemsProvider(saleId));
  invalidate(saleServiceItemsProvider(saleId));
  invalidate(kanbanSalesProvider);
  invalidate(todayCountProvider);
  invalidate(notPickedUpCountProvider);
  invalidate(backlogPendingCountProvider);
  invalidate(incompleteOrdersProvider);
  invalidate(readyForPickupSalesProvider);
  invalidate(salesSummaryProvider);
}

/// Refreshes sale detail, orders board, dashboard counts, and sales list.
void refreshSaleRelatedProviders(
  WidgetRef ref, {
  required String saleId,
  bool refreshSalesList = true,
}) {
  invalidateSaleRelatedProviders(ref.invalidate, saleId: saleId);
  if (refreshSalesList) {
    ref.read(paginatedSalesControllerProvider.notifier).refreshQuietly();
  }
}

/// Same as [refreshSaleRelatedProviders] for notifiers using [Ref].
void refreshSaleRelatedProvidersFromRef(
  Ref ref, {
  required String saleId,
  bool refreshSalesList = true,
}) {
  invalidateSaleRelatedProviders(ref.invalidate, saleId: saleId);
  if (refreshSalesList) {
    ref.read(paginatedSalesControllerProvider.notifier).refreshQuietly();
  }
}
