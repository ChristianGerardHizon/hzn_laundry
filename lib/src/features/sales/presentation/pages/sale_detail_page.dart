import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../pos/domain/order_status_history.dart';
import '../../../pos/domain/payment_type.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/presentation/payments_controller.dart';
import '../../../pos/presentation/services/thermal_print_service.dart';
import '../../../services/domain/service_item_status.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/printer_config_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/order_status_history_provider.dart';
import '../controllers/sale_items_provider.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_service_items_provider.dart';
import '../widgets/assign_machines_dialog.dart';
import '../widgets/assign_storages_dialog.dart';
import '../widgets/record_payment_sheet.dart';
import '../widgets/sale_detail_content.dart';
import '../widgets/sale_highlight_banner.dart';
import '../widgets/sale_status_chip.dart';

/// Sale detail page showing sale information and items.
class SaleDetailPage extends ConsumerWidget {
  const SaleDetailPage({
    super.key,
    required this.saleId,
  });

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleProvider(saleId));
    final isTablet = Breakpoints.isTabletOrLarger(context);

    return saleAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: isTablet
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => const SalesHistoryRoute().go(context),
                ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error loading sale: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(saleProvider(saleId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (sale) {
        if (sale == null) {
          return Scaffold(
            appBar: AppBar(
              leading: isTablet
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => const SalesHistoryRoute().go(context),
                    ),
            ),
            body: const Center(
              child: Text('Sale not found'),
            ),
          );
        }

        return _SaleDetailContent(
          sale: sale,
          isTablet: isTablet,
        );
      },
    );
  }
}

class _SaleDetailContent extends HookConsumerWidget {
  const _SaleDetailContent({
    required this.sale,
    required this.isTablet,
  });

  final Sale sale;
  final bool isTablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saleItemsAsync = ref.watch(saleItemsProvider(sale.id));
    final serviceItemsAsync = ref.watch(saleServiceItemsProvider(sale.id));
    final paymentsAsync = ref.watch(salePaymentsProvider(sale.id));
    final statusHistoryAsync =
        ref.watch(orderStatusHistoryProvider(sale.id));
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: '₱');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isTablet,
        leading: isTablet
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => const SalesHistoryRoute().go(context),
              ),
        title: Text(sale.receiptNumber),
        actions: [
          _PrintMenuButton(
            sale: sale,
            saleItemsAsync: saleItemsAsync,
            serviceItemsAsync: serviceItemsAsync,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(saleProvider(sale.id));
          ref.invalidate(saleItemsProvider(sale.id));
          ref.invalidate(saleServiceItemsProvider(sale.id));
          ref.invalidate(salePaymentsProvider(sale.id));
          ref.invalidate(orderStatusHistoryProvider(sale.id));
          await Future.wait([
            ref.read(saleProvider(sale.id).future),
            ref.read(saleItemsProvider(sale.id).future),
            ref.read(saleServiceItemsProvider(sale.id).future),
            ref.read(salePaymentsProvider(sale.id).future),
            ref.read(orderStatusHistoryProvider(sale.id).future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sale.receiptNumber,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sale.created != null
                                      ? dateFormat.format(sale.created!)
                                      : 'Unknown date',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SaleStatusChip(status: sale.status),
                        ],
                      ),
                      const Divider(height: 24),
                      if (sale.customerName != null &&
                          sale.customerName!.isNotEmpty)
                        SaleCustomerInfoRow(
                          customerName: sale.customerName!,
                          customerId: sale.customerId,
                        ),
                      if (sale.notes != null && sale.notes!.isNotEmpty)
                        SaleInfoRow(
                          icon: Icons.note,
                          label: 'Notes',
                          value: sale.notes!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Highlight Banner - shows most important status
              SaleHighlightBanner(
                orderStatus: sale.orderStatus,
                isPaid: sale.isPaid,
                saleStatus: sale.status,
              ),
              const SizedBox(height: 16),

              // Sale Status Actions (Refund/Unrefund)
              _buildSaleStatusActions(context, ref),
              const SizedBox(height: 16),

              // Order Status Card
              _buildOrderStatusCard(context, ref),
              const SizedBox(height: 16),

              // Status History Timeline
              _buildStatusHistoryCard(
                  context, statusHistoryAsync, dateFormat),
              const SizedBox(height: 16),

              // Items Section
              Text(
                'Items',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: saleItemsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading items: $error'),
                  ),
                  data: (items) => items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No items'),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                '${currencyFormat.format(item.unitPrice)} × ${item.quantity.toInt()}',
                              ),
                              trailing: Text(
                                currencyFormat.format(item.subtotal),
                                style: theme.textTheme.titleSmall,
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Service Items Section
              serviceItemsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (serviceItems) {
                  if (serviceItems.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Items',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: serviceItems.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = serviceItems[index];
                            final hasMachine = item.machineName != null &&
                                item.machineName!.isNotEmpty;
                            final hasStorage = item.storageName != null &&
                                item.storageName!.isNotEmpty;
                            final isCompleted =
                                item.status == ServiceItemStatus.completed;
                            final isProcessing =
                                sale.orderStatus == OrderStatus.processing;
                            final canMarkDone =
                                isProcessing && hasMachine && !isCompleted;

                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Service name + price row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                if (isCompleted) ...[
                                                  const Icon(
                                                    Icons.check_circle,
                                                    size: 16,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                                Expanded(
                                                  child: Text(
                                                    item.serviceName,
                                                    style: theme
                                                        .textTheme.titleSmall
                                                        ?.copyWith(
                                                      color: isCompleted
                                                          ? theme.colorScheme
                                                              .onSurfaceVariant
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${currencyFormat.format(item.unitPrice)} x ${item.service?.formatQuantity(item.quantity) ?? '${item.quantity}'}',
                                              style: theme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        currencyFormat
                                            .format(item.subtotal),
                                        style:
                                            theme.textTheme.titleSmall,
                                      ),
                                    ],
                                  ),

                                  // Machine & Storage assignment section
                                  if (hasMachine || hasStorage) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if (hasMachine)
                                          Expanded(
                                            child:
                                                SaleAssignmentInfoCard(
                                              icon: Icons
                                                  .local_laundry_service,
                                              label: 'Machine',
                                              name:
                                                  item.machineName!,
                                              color: isCompleted
                                                  ? Colors.grey
                                                  : Colors.blue,
                                            ),
                                          ),
                                        if (hasMachine && hasStorage)
                                          const SizedBox(width: 12),
                                        if (hasStorage)
                                          Expanded(
                                            child:
                                                SaleAssignmentInfoCard(
                                              icon: Icons.inventory_2,
                                              label: 'Storage',
                                              name:
                                                  item.storageName!,
                                              color: Colors.teal,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],

                                  // Mark Done button
                                  if (canMarkDone) ...[
                                    const SizedBox(height: 12),
                                    _ServiceItemMarkDoneButton(
                                      itemId: item.id,
                                      saleId: sale.id,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),

              // Total Card
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        currencyFormat.format(sale.totalAmount),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Status & History Card
              _buildPaymentCard(context, ref, paymentsAsync, currencyFormat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaleStatusActions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUpdating = useState(false);
    final isRefunded = sale.status.toLowerCase() == 'refunded';
    final isVoided = sale.status.toLowerCase() == 'voided';
    final isPending = sale.status.toLowerCase() == 'pending';

    // Don't show actions for voided sales
    if (isVoided) {
      return const SizedBox.shrink();
    }

    Future<void> updateSaleStatus(String newStatus) async {
      final isVoidAction = newStatus == 'voided';
      final isRefundAction = newStatus == 'refunded';

      String dialogTitle;
      String dialogContent;
      String confirmLabel;
      Color confirmColor;
      String successMessage;

      if (isVoidAction) {
        dialogTitle = 'Void Sale?';
        dialogContent =
            'Are you sure you want to void this sale? This action cannot be undone.';
        confirmLabel = 'Void Sale';
        confirmColor = Colors.red;
        successMessage = 'Sale has been voided';
      } else if (isRefundAction) {
        dialogTitle = 'Refund Sale?';
        dialogContent =
            'Are you sure you want to mark this sale as refunded? This will update the sale status.';
        confirmLabel = 'Refund';
        confirmColor = Colors.orange;
        successMessage = 'Sale marked as refunded';
      } else {
        dialogTitle = 'Remove Refund?';
        dialogContent =
            'Are you sure you want to remove the refund status and mark this sale as $newStatus?';
        confirmLabel = 'Remove Refund';
        confirmColor = Colors.green;
        successMessage = 'Refund status removed';
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: confirmColor,
              ),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;

      isUpdating.value = true;
      final repo = ref.read(salesRepositoryProvider);
      final result = await repo.updateSaleStatus(sale.id, newStatus);
      isUpdating.value = false;

      if (!context.mounted) return;

      result.fold(
        (failure) {
          showErrorSnackBar(context, message: failure.messageString);
        },
        (_) {
          showSuccessSnackBar(context, message: successMessage);
          ref.invalidate(saleProvider(sale.id));
        },
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.receipt_long,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sale Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Current status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isRefunded
                    ? Colors.orange.withValues(alpha: 0.1)
                    : isPending
                        ? Colors.amber.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isRefunded
                    ? 'Refunded'
                    : isPending
                        ? 'Pending'
                        : 'Completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isRefunded
                      ? Colors.orange
                      : isPending
                          ? Colors.amber.shade700
                          : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Popup menu for actions
            PopupMenuButton<String>(
              icon: isUpdating.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.more_vert),
              enabled: !isUpdating.value,
              onSelected: (value) {
                if (value == 'refund') {
                  updateSaleStatus('refunded');
                } else if (value == 'unrefund') {
                  final revertStatus =
                      sale.orderStatus == OrderStatus.pickedUp
                          ? 'completed'
                          : 'pending';
                  updateSaleStatus(revertStatus);
                } else if (value == 'void') {
                  updateSaleStatus('voided');
                }
              },
              itemBuilder: (context) => [
                if (isRefunded)
                  const PopupMenuItem<String>(
                    value: 'unrefund',
                    child: ListTile(
                      leading: Icon(Icons.undo, color: Colors.green),
                      title: Text('Remove Refund'),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                else
                  const PopupMenuItem<String>(
                    value: 'refund',
                    child: ListTile(
                      leading: Icon(Icons.replay, color: Colors.orange),
                      title: Text('Mark as Refunded'),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                const PopupMenuItem<String>(
                  value: 'void',
                  child: ListTile(
                    leading: Icon(Icons.block, color: Colors.red),
                    title: Text('Void Sale'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUpdating = useState(false);

    Future<void> updateOrderStatus(OrderStatus status) async {
      // Show assignment dialogs for processing/ready transitions
      if (status == OrderStatus.processing) {
        final serviceItems =
            ref.read(saleServiceItemsProvider(sale.id)).value ?? [];
        if (serviceItems.isNotEmpty) {
          final result = await showAssignMachinesDialog(
            context,
            serviceItems: serviceItems,
          );
          if (result == null || !context.mounted) return;
        }
      } else if (status == OrderStatus.ready) {
        final serviceItems =
            ref.read(saleServiceItemsProvider(sale.id)).value ?? [];
        if (serviceItems.isNotEmpty) {
          final result = await showAssignStoragesDialog(
            context,
            serviceItems: serviceItems,
          );
          if (result == null || !context.mounted) return;
        }
      }

      isUpdating.value = true;
      final repo = ref.read(salesRepositoryProvider);
      final result = await repo.updateOrderStatus(sale.id, status);
      isUpdating.value = false;

      if (!context.mounted) return;

      result.fold(
        (failure) {
          showErrorSnackBar(context, message: failure.messageString);
        },
        (_) {
          ref.invalidate(saleProvider(sale.id));
          ref.invalidate(saleServiceItemsProvider(sale.id));
        },
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order status - responsive grid layout
            LayoutBuilder(
              builder: (context, constraints) {
                // Use 2x2 grid for narrow screens, single row for wider screens
                final useGrid = constraints.maxWidth < 400;

                if (useGrid) {
                  // 2x2 Grid layout for mobile
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: OrderStatus.values.map((status) {
                      final isSelected = sale.orderStatus == status;
                      return SizedBox(
                        width: (constraints.maxWidth - 8) / 2,
                        child: _OrderStatusButton(
                          status: status,
                          isSelected: isSelected,
                          isUpdating: isUpdating.value,
                          icon: _getOrderStatusIcon(status),
                          onTap: () => updateOrderStatus(status),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  // Single row for tablet/wider screens
                  return Row(
                    children: OrderStatus.values.map((status) {
                      final isSelected = sale.orderStatus == status;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: status != OrderStatus.values.last ? 8 : 0,
                          ),
                          child: _OrderStatusButton(
                            status: status,
                            isSelected: isSelected,
                            isUpdating: isUpdating.value,
                            icon: _getOrderStatusIcon(status),
                            onTap: () => updateOrderStatus(status),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),

            // Picked up timestamp
            if (sale.orderStatus == OrderStatus.pickedUp &&
                sale.pickedUpAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Picked up on ${DateFormat('MMM dd, yyyy hh:mm a').format(sale.pickedUpAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getOrderStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.ready:
        return Icons.check_circle_outline;
      case OrderStatus.pickedUp:
        return Icons.local_shipping;
    }
  }

  Widget _buildStatusHistoryCard(
    BuildContext context,
    AsyncValue<List<OrderStatusHistory>> historyAsync,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (history) {
        if (history.isEmpty) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status History',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    final isOrderStatus =
                        entry.statusType == StatusType.orderStatus;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isOrderStatus
                                ? Colors.blue.withValues(alpha: 0.1)
                                : Colors.purple.withValues(alpha: 0.1),
                            child: Icon(
                              isOrderStatus
                                  ? Icons.local_shipping
                                  : Icons.receipt_long,
                              size: 16,
                              color: isOrderStatus
                                  ? Colors.blue
                                  : Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.description ?? '',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry.created != null
                                      ? dateFormat.format(entry.created!)
                                      : '',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme
                                        .colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<dynamic>> paymentsAsync,
    NumberFormat currencyFormat,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Payment status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: sale.isPaid
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sale.isPaid ? Icons.check_circle : Icons.pending,
                        size: 16,
                        color: sale.isPaid ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sale.isPaid ? 'Paid' : 'Unpaid',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: sale.isPaid ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Payment summary
            paymentsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Error loading payments: $error'),
              ),
              data: (payments) {
                // Calculate totals
                num totalPaid = 0;
                for (final payment in payments) {
                  if (payment.type == PaymentType.refund) {
                    totalPaid -= payment.amount;
                  } else {
                    totalPaid += payment.amount;
                  }
                }
                final balanceDue = sale.totalAmount - totalPaid;

                return Column(
                  children: [
                    // Summary row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              currencyFormat.format(sale.totalAmount),
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Paid',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              currencyFormat.format(totalPaid),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Balance Due',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              currencyFormat.format(balanceDue),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: balanceDue > 0
                                    ? Colors.red
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Payment history
                    if (payments.isNotEmpty) ...[
                      const Divider(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Payment History',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final payment = payments[index];
                          final isRefund = payment.type == PaymentType.refund;
                          final isGcashBank =
                              payment.type == PaymentType.deposit;
                          final hasProof = payment.paymentProofUrl != null &&
                              payment.paymentProofUrl!.isNotEmpty;

                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isRefund
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                                  child: Icon(
                                    isRefund ? Icons.remove : Icons.add,
                                    size: 18,
                                    color: isRefund ? Colors.red : Colors.green,
                                  ),
                                ),
                                title: Text(
                                  '${payment.type.displayName} - ${payment.paymentMethod.displayName}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.created != null
                                          ? DateFormat('MMM dd, yyyy hh:mm a')
                                              .format(payment.created!)
                                          : '',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    // Show reference for GCash/Bank payments
                                    if (isGcashBank &&
                                        payment.paymentRef != null &&
                                        payment.paymentRef!.isNotEmpty)
                                      Text(
                                        'Ref: ${payment.paymentRef}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  '${isRefund ? '-' : '+'}${currencyFormat.format(payment.amount)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: isRefund ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Show proof of payment button if available
                              if (hasProof)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 56, bottom: 8),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        _showPaymentProofDialog(
                                          context,
                                          payment.paymentProofUrl!,
                                        );
                                      },
                                      icon: const Icon(Icons.receipt_long,
                                          size: 16),
                                      label: const Text('View Proof'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],

                    // Record payment button
                    if (balanceDue > 0) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            final result = await showRecordPaymentDialog(
                              context,
                              sale: sale,
                              balanceDue: balanceDue,
                            );
                            if (result == true) {
                              ref.invalidate(saleProvider(sale.id));
                              ref.invalidate(salePaymentsProvider(sale.id));
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Record Payment'),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentProofDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Proof of Payment'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 48),
                        SizedBox(height: 8),
                        Text('Failed to load image'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom button for order status selection.
class _OrderStatusButton extends StatelessWidget {
  const _OrderStatusButton({
    required this.status,
    required this.isSelected,
    required this.isUpdating,
    required this.icon,
    required this.onTap,
  });

  final OrderStatus status;
  final bool isSelected;
  final bool isUpdating;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color statusColor;
    switch (status) {
      case OrderStatus.pending:
        statusColor = Colors.amber.shade700;
      case OrderStatus.processing:
        statusColor = Colors.blue;
      case OrderStatus.ready:
        statusColor = Colors.green;
      case OrderStatus.pickedUp:
        statusColor = Colors.grey;
    }

    return Material(
      color: isSelected
          ? statusColor.withValues(alpha: 0.15)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isUpdating ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? statusColor
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? statusColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                status.displayName,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? statusColor
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Button to mark a service item as completed.
class _ServiceItemMarkDoneButton extends HookConsumerWidget {
  const _ServiceItemMarkDoneButton({
    required this.itemId,
    required this.saleId,
  });

  final String itemId;
  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMarking = useState(false);

    Future<void> markDone() async {
      isMarking.value = true;
      final repo = ref.read(salesRepositoryProvider);
      final result = await repo.markServiceItemCompleted(itemId);
      isMarking.value = false;

      if (!context.mounted) return;

      await result.fold(
        (failure) async {
          showErrorSnackBar(context, message: failure.messageString);
        },
        (allCompleted) async {
          // Refresh the service items
          ref.invalidate(saleServiceItemsProvider(saleId));

          if (allCompleted) {
            // All service items completed - auto-advance to ready status
            showSuccessSnackBar(
              context,
              message: 'All services completed! Assigning storage...',
            );

            // Show storage assignment dialog
            final serviceItems =
                await ref.read(saleServiceItemsProvider(saleId).future);
            if (serviceItems.isNotEmpty && context.mounted) {
              final storageResult = await showAssignStoragesDialog(
                context,
                serviceItems: serviceItems,
              );
              if (storageResult != null && context.mounted) {
                // Update order status to ready
                final statusResult =
                    await repo.updateOrderStatus(saleId, OrderStatus.ready);
                statusResult.fold(
                  (failure) {
                    if (context.mounted) {
                      showErrorSnackBar(context, message: failure.messageString);
                    }
                  },
                  (_) {
                    ref.invalidate(saleProvider(saleId));
                  },
                );
              }
            }
          } else {
            showSuccessSnackBar(
              context,
              message: 'Service marked as done. Machine released.',
            );
          }
        },
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isMarking.value ? null : markDone,
        icon: isMarking.value
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check_circle_outline, size: 18),
        label: Text(isMarking.value ? 'Marking...' : 'Mark Done'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}

// ── Print menu button ────────────────────────────────────────────────────────

class _PrintMenuButton extends HookConsumerWidget {
  const _PrintMenuButton({
    required this.sale,
    required this.saleItemsAsync,
    required this.serviceItemsAsync,
  });

  final Sale sale;
  final AsyncValue<dynamic> saleItemsAsync;
  final AsyncValue<dynamic> serviceItemsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrinting = useState(false);
    final defaultPrinterAsync = ref.watch(defaultPrinterProvider);
    final currentAuth = ref.watch(currentAuthProvider);
    final branchId = ref.watch(currentBranchIdProvider);
    final branchAsync = ref.watch(branchProvider(branchId ?? ''));

    Future<void> printCopy(OrderReceiptCopy copyType) async {
      final printer = defaultPrinterAsync.value;
      if (printer == null) {
        showErrorSnackBar(context, message: 'No default printer configured');
        return;
      }

      // Get service item info for the receipt
      final serviceItems =
          (serviceItemsAsync.value as List<SaleServiceItem>?) ?? [];
      final firstService = serviceItems.isNotEmpty ? serviceItems.first : null;
      final addOnItems = (saleItemsAsync.value as List<SaleItem>?) ?? [];

      // Derive unit label from service's quantity unit or weightBased flag
      final service = firstService?.service;
      final unitLabel = service?.quantityUnit?.shortPlural ??
          (service?.weightBased == true ? 'KG' : 'PCS');

      isPrinting.value = true;
      final printService = ref.read(thermalPrintServiceProvider.notifier);
      final currentBranch = branchAsync.value;

      final result = await printService.printOrderReceipt(
        printer: printer,
        customerName: sale.customerName ?? 'Walk-in',
        serviceName: firstService?.serviceName ?? 'Laundry',
        quantity: firstService?.quantity.toDouble() ?? 1.0,
        unitLabel: unitLabel,
        totalAmount: sale.totalAmount.toDouble(),
        copyType: copyType,
        businessName: currentBranch?.name,
        branchAddress: currentBranch?.address,
        contactNumber: currentBranch?.contactNumber,
        cashierName: currentAuth?.user.name,
        specialInstructions: sale.notes,
        addOnItems: addOnItems,
      );

      isPrinting.value = false;
      if (!context.mounted) return;

      if (result is PrintFailure) {
        showErrorSnackBar(context, message: result.message);
      } else {
        final label = copyType == OrderReceiptCopy.customer
            ? 'Customer copy'
            : 'Store copy';
        showSuccessSnackBar(context, message: '$label printed');
      }
    }

    return PopupMenuButton<String>(
      icon: isPrinting.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.print),
      tooltip: 'Print',
      enabled: !isPrinting.value,
      onSelected: (value) {
        switch (value) {
          case 'customer':
            printCopy(OrderReceiptCopy.customer);
          case 'store':
            printCopy(OrderReceiptCopy.store);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'customer',
          child: ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('Print Customer Copy'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'store',
          child: ListTile(
            leading: Icon(Icons.local_laundry_service),
            title: Text('Print Store Copy'),
            subtitle: Text('Machine tag'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}
