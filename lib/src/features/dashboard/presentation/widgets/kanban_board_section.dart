import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../sales/presentation/controllers/sale_service_items_provider.dart';
import '../../../sales/presentation/widgets/assign_machines_dialog.dart';
import '../../../sales/presentation/widgets/assign_storages_dialog.dart';
import '../../../sales/presentation/widgets/sale_detail_dialog.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../services/domain/service_item_status.dart';
import '../controllers/kanban_sales_controller.dart';

/// Kanban-style board showing all sales grouped by order status.
///
/// On tablet/desktop: Shows columns side-by-side in a horizontal scrollable row.
/// On mobile: Shows columns in a vertical scrollable list.
class KanbanBoardSection extends HookConsumerWidget {
  const KanbanBoardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kanbanAsync = ref.watch(kanbanSalesProvider);
    final filterMode = ref.watch(kanbanFilterProvider);
    final isRefreshing = kanbanAsync.isLoading && kanbanAsync.hasValue;

    // Spinning animation for the refresh icon
    final animController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    useEffect(() {
      if (isRefreshing) {
        animController.repeat();
      } else {
        animController.stop();
        animController.reset();
      }
      return null;
    }, [isRefreshing]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                Icons.view_kanban_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Board',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              RotationTransition(
                turns: animController,
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh orders',
                  onPressed: isRefreshing
                      ? null
                      : () {
                          ref.invalidate(kanbanSalesProvider);
                          ref.invalidate(notPickedUpCountProvider);
                          ref.invalidate(todayCountProvider);
                        },
                ),
              ),
              TextButton(
                onPressed: () => const SalesHistoryRoute().go(context),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Filter chips
          _KanbanFilterChips(currentFilter: filterMode),
          const SizedBox(height: 12),
          // Board content — keep showing previous data during refresh
          AnimatedOpacity(
            opacity: isRefreshing ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: kanbanAsync.when(
              skipLoadingOnRefresh: true,
              data: (data) =>
                  _KanbanBoard(data: data, filterMode: filterMode),
              loading: () => const _LoadingState(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanFilterChips extends ConsumerWidget {
  const _KanbanFilterChips({required this.currentFilter});

  final KanbanFilterMode currentFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _FilterChip(
          label: "Today's Orders",
          icon: Icons.today,
          isSelected: currentFilter == KanbanFilterMode.today,
          onSelected: () => ref
              .read(kanbanFilterProvider.notifier)
              .setFilter(KanbanFilterMode.today),
          count: ref.watch(todayCountProvider).asData?.value,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Backlogs',
          icon: Icons.pending_actions,
          isSelected: currentFilter == KanbanFilterMode.notPickedUp,
          onSelected: () => ref
              .read(kanbanFilterProvider.notifier)
              .setFilter(KanbanFilterMode.notPickedUp),
          count: ref.watch(notPickedUpCountProvider).asData?.value,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
    this.count,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  const _KanbanBoard({required this.data, required this.filterMode});

  final KanbanSalesData data;
  final KanbanFilterMode filterMode;

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTabletOrLarger(context);

    // Show all columns in both modes (backlogs includes Picked Up so users can drag orders there)
    final statuses = OrderStatus.values;

    if (isTablet) {
      return _TabletKanbanLayout(
        data: data,
        statuses: statuses,
        filterMode: filterMode,
      );
    }
    return _MobileKanbanLayout(
      data: data,
      statuses: statuses,
      filterMode: filterMode,
    );
  }
}

/// Tablet: Horizontal row of columns, each taking equal width.
class _TabletKanbanLayout extends StatelessWidget {
  const _TabletKanbanLayout({
    required this.data,
    required this.statuses,
    required this.filterMode,
  });

  final KanbanSalesData data;
  final List<OrderStatus> statuses;
  final KanbanFilterMode filterMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < statuses.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _KanbanColumn(
                status: statuses[i],
                sales: data.salesForStatus(statuses[i]),
                kanbanData: data,
                isScrollable: true,
                filterMode: filterMode,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mobile: Vertical stack of collapsed columns.
class _MobileKanbanLayout extends StatelessWidget {
  const _MobileKanbanLayout({
    required this.data,
    required this.statuses,
    required this.filterMode,
  });

  final KanbanSalesData data;
  final List<OrderStatus> statuses;
  final KanbanFilterMode filterMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < statuses.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _KanbanColumn(
            status: statuses[i],
            sales: data.salesForStatus(statuses[i]),
            kanbanData: data,
            isScrollable: false,
            maxItems: 5,
            filterMode: filterMode,
          ),
        ],
      ],
    );
  }
}

/// A single kanban column for one order status.
class _KanbanColumn extends ConsumerWidget {
  const _KanbanColumn({
    required this.status,
    required this.sales,
    required this.kanbanData,
    required this.isScrollable,
    required this.filterMode,
    this.maxItems,
  });

  final OrderStatus status;
  final List<Sale> sales;
  final KanbanSalesData kanbanData;
  final bool isScrollable;
  final KanbanFilterMode filterMode;
  final int? maxItems;

  Color _statusColor() => switch (status) {
        OrderStatus.pending => Colors.orange,
        OrderStatus.processing => Colors.blue,
        OrderStatus.ready => Colors.green,
        OrderStatus.pickedUp => Colors.grey,
      };

  IconData _statusIcon() => switch (status) {
        OrderStatus.pending => Icons.schedule,
        OrderStatus.processing => Icons.autorenew,
        OrderStatus.ready => Icons.check_circle_outline,
        OrderStatus.pickedUp => Icons.local_shipping_outlined,
      };

  Future<void> _handleDrop(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    // Handle assignment dialogs for specific transitions
    if (status == OrderStatus.processing) {
      final serviceItems =
          await ref.read(saleServiceItemsProvider(sale.id).future);
      if (serviceItems.isNotEmpty && context.mounted) {
        final result = await showAssignMachinesDialog(
          context,
          serviceItems: serviceItems,
        );
        if (result == null) {
          // User cancelled - refresh to revert
          ref.invalidate(kanbanSalesProvider);
          return;
        }
      }
    } else if (status == OrderStatus.ready) {
      final serviceItems =
          await ref.read(saleServiceItemsProvider(sale.id).future);
      if (serviceItems.isNotEmpty && context.mounted) {
        final result = await showAssignStoragesDialog(
          context,
          serviceItems: serviceItems,
        );
        if (result == null) {
          // User cancelled - refresh to revert
          ref.invalidate(kanbanSalesProvider);
          return;
        }
      }
    }

    if (!context.mounted) return;

    // Update order status
    final repo = ref.read(salesRepositoryProvider);
    final result = await repo.updateOrderStatus(sale.id, status);

    if (!context.mounted) return;

    result.fold(
      (failure) {
        showErrorSnackBar(context, message: failure.messageString);
        ref.invalidate(kanbanSalesProvider);
        ref.invalidate(notPickedUpCountProvider);
        ref.invalidate(todayCountProvider);
      },
      (_) {
        ref.invalidate(kanbanSalesProvider);
        ref.invalidate(notPickedUpCountProvider);
        ref.invalidate(todayCountProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _statusColor();
    final displayedSales =
        maxItems != null ? sales.take(maxItems!).toList() : sales;
    final remainingCount = sales.length - displayedSales.length;

    return DragTarget<Sale>(
      onWillAcceptWithDetails: (details) {
        // Accept if sale is not already in this status
        return details.data.orderStatus != status;
      },
      onAcceptWithDetails: (details) {
        _handleDrop(context, ref, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isHovering
                ? color.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering
                  ? color
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Column header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(_statusIcon(), color: color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status.displayName,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${sales.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cards list
              if (sales.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No orders',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else if (isScrollable)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: displayedSales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final sale = displayedSales[index];
                      return _SaleCard(
                        sale: sale,
                        serviceItems: kanbanData.serviceItemsForSale(sale.id),
                        saleItems: kanbanData.saleItemsForSale(sale.id),
                        showOverdue: filterMode == KanbanFilterMode.notPickedUp,
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      for (int i = 0; i < displayedSales.length; i++) ...[
                        if (i > 0) const SizedBox(height: 6),
                        _SaleCard(
                          sale: displayedSales[i],
                          serviceItems: kanbanData
                              .serviceItemsForSale(displayedSales[i].id),
                          saleItems: kanbanData
                              .saleItemsForSale(displayedSales[i].id),
                          showOverdue: filterMode == KanbanFilterMode.notPickedUp,
                        ),
                      ],
                      if (remainingCount > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          '+ $remainingCount more',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual sale card within a kanban column.
class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    this.serviceItems = const [],
    this.saleItems = const [],
    this.showOverdue = false,
  });

  final Sale sale;
  final List<SaleServiceItem> serviceItems;
  final List<SaleItem> saleItems;
  final bool showOverdue;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Sale>(
      data: sale,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: 0.9,
          child: SizedBox(
            width: 180,
            child: _SaleCardContent(
              sale: sale,
              serviceItems: serviceItems,
              saleItems: saleItems,
              showOverdue: showOverdue,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _SaleCardContent(
          sale: sale,
          serviceItems: serviceItems,
          saleItems: saleItems,
          showOverdue: showOverdue,
        ),
      ),
      child: _SaleCardContent(
        sale: sale,
        serviceItems: serviceItems,
        saleItems: saleItems,
        showOverdue: showOverdue,
      ),
    );
  }
}

/// The visual content of a sale card.
class _SaleCardContent extends StatelessWidget {
  const _SaleCardContent({
    required this.sale,
    this.serviceItems = const [],
    this.saleItems = const [],
    this.showOverdue = false,
  });

  final Sale sale;
  final List<SaleServiceItem> serviceItems;
  final List<SaleItem> saleItems;
  final bool showOverdue;

  /// Whether this order is overdue (created before today and not picked up).
  bool get _isOverdue {
    if (!showOverdue || sale.created == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdLocal = sale.created!.toLocal();
    final createdDate =
        DateTime(createdLocal.year, createdLocal.month, createdLocal.day);
    return createdDate.isBefore(today);
  }

  /// Gets the display text for machine or storage based on order status.
  String? _getAssignmentInfo() {
    if (serviceItems.isEmpty) return null;

    if (sale.orderStatus == OrderStatus.processing) {
      // Show machine names for processing orders with completion status
      final machineInfos = serviceItems
          .where((item) => item.machineName != null && item.machineName!.isNotEmpty)
          .map((item) {
            final isCompleted = item.status == ServiceItemStatus.completed;
            return isCompleted ? '${item.machineName!} ✓' : item.machineName!;
          })
          .toSet()
          .toList();
      if (machineInfos.isEmpty) return null;
      return machineInfos.join(', ');
    } else if (sale.orderStatus == OrderStatus.ready) {
      // Show storage names for ready orders
      final storageNames = serviceItems
          .where((item) => item.storageName != null && item.storageName!.isNotEmpty)
          .map((item) => item.storageName!)
          .toSet()
          .toList();
      if (storageNames.isEmpty) return null;
      return storageNames.join(', ');
    }

    return null;
  }

  /// Checks if all service items with machines are completed.
  bool get _allServicesCompleted {
    final itemsWithMachines = serviceItems
        .where((item) => item.machineName != null && item.machineName!.isNotEmpty);
    if (itemsWithMachines.isEmpty) return false;
    return itemsWithMachines.every((item) => item.status == ServiceItemStatus.completed);
  }

  /// Checks if some (but not all) service items are completed.
  bool get _someServicesCompleted {
    final itemsWithMachines = serviceItems
        .where((item) => item.machineName != null && item.machineName!.isNotEmpty);
    if (itemsWithMachines.isEmpty) return false;
    final completed = itemsWithMachines.where((item) => item.status == ServiceItemStatus.completed);
    return completed.isNotEmpty && completed.length < itemsWithMachines.length;
  }

  /// Extracts a short display order number from the full receipt number.
  /// e.g. "S-260401-X7KP" → "#X7KP"
  String _shortOrderNumber(String receiptNumber) {
    final parts = receiptNumber.split('-');
    if (parts.length >= 3) {
      return '#${parts.last}';
    }
    // Fallback: show last 4 characters
    if (receiptNumber.length > 4) {
      return '#${receiptNumber.substring(receiptNumber.length - 4)}';
    }
    return receiptNumber;
  }

  IconData? _getAssignmentIcon() {
    if (sale.orderStatus == OrderStatus.processing) {
      return Icons.local_laundry_service;
    } else if (sale.orderStatus == OrderStatus.ready) {
      return Icons.inventory_2;
    }
    return null;
  }

  Color _getAssignmentColor() {
    if (sale.orderStatus == OrderStatus.processing) {
      // Show green if all services completed (ready to advance)
      if (_allServicesCompleted) return Colors.green;
      // Show orange if some services completed
      if (_someServicesCompleted) return Colors.orange;
      return Colors.blue;
    } else if (sale.orderStatus == OrderStatus.ready) {
      return Colors.teal;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat =
        NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final assignmentInfo = _getAssignmentInfo();
    final assignmentIcon = _getAssignmentIcon();
    final assignmentColor = _getAssignmentColor();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => showSaleDetailDialog(context, saleId: sale.id),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer name (highlighted)
              if (sale.customerDisplay != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sale.customerDisplay!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              // Short order number & payment badge
              Row(
                children: [
                  Text(
                    _shortOrderNumber(sale.receiptNumber),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  if (_isOverdue) ...[
                    const _OverdueBadge(),
                    const SizedBox(width: 4),
                  ],
                  _PaymentBadge(isPaid: sale.isPaid),
                ],
              ),
              // Services & Addons summary
              if (serviceItems.isNotEmpty || saleItems.isNotEmpty) ...[
                const SizedBox(height: 6),
                if (serviceItems.isNotEmpty)
                  _ItemSummaryRow(
                    icon: Icons.local_laundry_service,
                    label: serviceItems
                        .map((e) {
                          final qty = e.service?.formatQuantity(e.quantity) ??
                              '${e.quantity}';
                          return '${e.serviceName} x$qty';
                        })
                        .join(', '),
                    color: theme.colorScheme.primary,
                  ),
                if (saleItems.isNotEmpty) ...[
                  if (serviceItems.isNotEmpty) const SizedBox(height: 2),
                  _ItemSummaryRow(
                    icon: Icons.add_circle_outline,
                    label: saleItems
                        .map((e) => '${e.productName} x${e.quantity}')
                        .join(', '),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
              // Machine or Storage assignment info
              if (assignmentInfo != null && assignmentIcon != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: assignmentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        assignmentIcon,
                        size: 12,
                        color: assignmentColor,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          assignmentInfo,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: assignmentColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 6),
              // Amount & time
              Row(
                children: [
                  Text(
                    currencyFormat.format(sale.totalAmount),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (sale.created != null)
                    Text(
                      _formatTime(sale.created!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(local.year, local.month, local.day);

    if (date == today) {
      return DateFormat('h:mm a').format(local);
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(local);
  }
}

class _ItemSummaryRow extends StatelessWidget {
  const _ItemSummaryRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Overdue',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Unpaid',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
