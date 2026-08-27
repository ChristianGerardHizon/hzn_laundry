import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/dialog_dismissing_observer.dart';
import '../../../../core/routing/routes/customers.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../dashboard/presentation/controllers/kanban_sales_controller.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/presentation/payments_controller.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../services/domain/service_item_status.dart';
import '../controllers/sale_items_provider.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_service_items_provider.dart';
import 'assign_machines_dialog.dart';
import 'assign_storages_dialog.dart';
import 'prepare_order_for_ready.dart';
import 'set_packs_dialog.dart';
import 'sale_highlight_banner.dart';
import 'sale_status_chip.dart';

/// Reusable sale detail content widget.
///
/// Used by both SaleDetailPage and SaleDetailDialog to display sale information
/// without the scaffold/appbar wrapper.
class SaleDetailContent extends ConsumerWidget {
  const SaleDetailContent({
    super.key,
    required this.sale,
    this.compact = false,
  });

  final Sale sale;

  /// When true, uses a more compact layout suitable for dialogs.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleItemsAsync = ref.watch(saleItemsProvider(sale.id));
    final serviceItemsAsync = ref.watch(saleServiceItemsProvider(sale.id));
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: '₱');

    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _SaleHeaderCard(
            sale: sale,
            dateFormat: dateFormat,
            compact: compact,
          ),
          SizedBox(height: compact ? 12 : 16),

          // Highlight Banner - shows most important status
          _SaleHighlightBannerWithBalance(sale: sale),
          SizedBox(height: compact ? 12 : 16),

          // Services Section
          _ServiceItemsSection(
            sale: sale,
            serviceItemsAsync: serviceItemsAsync,
            currencyFormat: currencyFormat,
            compact: compact,
          ),

          // Packs Section
          if (sale.orderStatus != OrderStatus.pending)
            _PacksSection(
              sale: sale,
              compact: compact,
            ),

          // Addons Section
          _ItemsSection(
            saleItemsAsync: saleItemsAsync,
            currencyFormat: currencyFormat,
            compact: compact,
          ),
          SizedBox(height: compact ? 12 : 16),

          // Special Instructions Section
          _SpecialInstructionsSection(
            notes: sale.notes,
            compact: compact,
          ),
          SizedBox(height: compact ? 12 : 16),

          // Total Card
          _TotalCard(
            totalAmount: sale.totalAmount,
            currencyFormat: currencyFormat,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

/// Header card with receipt number, date, status, and customer info.
class _SaleHeaderCard extends StatelessWidget {
  const _SaleHeaderCard({
    required this.sale,
    required this.dateFormat,
    required this.compact,
  });

  final Sale sale;
  final DateFormat dateFormat;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
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
                        style: (compact
                                ? theme.textTheme.bodyLarge
                                : theme.textTheme.titleMedium)
                            ?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sale.postedDate != null
                            ? dateFormat.format(sale.postedDate!)
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
            if (sale.customerName != null && sale.customerName!.isNotEmpty) ...[
              const SizedBox(height: 8),
              SaleCustomerInfoRow(
                customerName: sale.customerName!,
                customerId: sale.customerId,
              ),
            ],
            const Divider(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Items section showing product items.
class _ItemsSection extends StatelessWidget {
  const _ItemsSection({
    required this.saleItemsAsync,
    required this.currencyFormat,
    required this.compact,
  });

  final AsyncValue<List<SaleItem>> saleItemsAsync;
  final NumberFormat currencyFormat;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Addons',
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
              child: Text('Error loading addons: $error'),
            ),
            data: (items) => items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No addons'),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        dense: compact,
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
      ],
    );
  }
}

/// Service items section with machine/storage assignments.
class _ServiceItemsSection extends StatelessWidget {
  const _ServiceItemsSection({
    required this.sale,
    required this.serviceItemsAsync,
    required this.currencyFormat,
    required this.compact,
  });

  final Sale sale;
  final AsyncValue<List<SaleServiceItem>> serviceItemsAsync;
  final NumberFormat currencyFormat;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return serviceItemsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (serviceItems) {
        if (serviceItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: serviceItems.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = serviceItems[index];
                  return _ServiceItemTile(
                    sale: sale,
                    item: item,
                    currencyFormat: currencyFormat,
                    compact: compact,
                  );
                },
              ),
            ),
            SizedBox(height: compact ? 12 : 16),
          ],
        );
      },
    );
  }
}

/// Individual service item tile with machine/storage info and mark done button.
class _ServiceItemTile extends HookConsumerWidget {
  const _ServiceItemTile({
    required this.sale,
    required this.item,
    required this.currencyFormat,
    required this.compact,
  });

  final Sale sale;
  final SaleServiceItem item;
  final NumberFormat currencyFormat;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasMachine =
        item.machineName != null && item.machineName!.isNotEmpty;
    final hasStorage =
        item.storageName != null && item.storageName!.isNotEmpty;
    final isCompleted = item.status == ServiceItemStatus.completed;
    final isProcessing = sale.orderStatus == OrderStatus.processing;
    final canMarkDone = isProcessing && hasMachine && !isCompleted;

    final isMarking = useState(false);

    Future<void> markDone() async {
      isMarking.value = true;
      final repo = ref.read(salesRepositoryProvider);
      final result = await repo.markServiceItemCompleted(item.id);
      isMarking.value = false;

      if (!context.mounted) return;

      await result.fold(
        (failure) async {
          showErrorSnackBar(context, message: failure.messageString);
        },
        (allCompleted) async {
          // Refresh the service items and kanban board
          ref.invalidate(saleServiceItemsProvider(sale.id));
          ref.invalidate(kanbanSalesProvider);

          if (allCompleted) {
            showSuccessSnackBar(
              context,
              message: 'All services completed! Assign machines and packs...',
            );

            if (!context.mounted) return;
            final prepared = await prepareOrderForReadyStatus(
              context: context,
              ref: ref,
              saleId: sale.id,
              sale: sale,
            );
            if (prepared && context.mounted) {
              final statusResult =
                  await repo.updateOrderStatus(sale.id, OrderStatus.ready);
              statusResult.fold(
                (failure) {
                  if (context.mounted) {
                    showErrorSnackBar(context,
                        message: failure.messageString);
                  }
                },
                (_) {
                  ref.invalidate(saleProvider(sale.id));
                  ref.invalidate(kanbanSalesProvider);
                },
              );
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

    Future<void> _editMachine(BuildContext ctx, WidgetRef ref) async {
      final initialAssignments = <String, List<String>>{};
      final initialLoadCounts = <String, Map<String, int>>{};
      if (item.machineIds.isNotEmpty) {
        initialAssignments[item.id] = item.machineIds;
        if (item.machineLoadCounts.isNotEmpty) {
          initialLoadCounts[item.id] = item.machineLoadCounts;
        }
      }
      final result = await showAssignMachinesDialog(
        ctx,
        serviceItems: [item],
        initialAssignments: initialAssignments,
        initialLoadCounts: initialLoadCounts,
      );
      if (result == true) {
        ref.invalidate(saleServiceItemsProvider(sale.id));
        ref.invalidate(kanbanSalesProvider);
      }
    }

    Future<void> _editStorage(BuildContext ctx, WidgetRef ref) async {
      final initialAssignments = <String, List<String>>{};
      if (item.storageIds.isNotEmpty) {
        initialAssignments[item.id] = item.storageIds;
      }
      final result = await showAssignStoragesDialog(
        ctx,
        saleId: sale.id,
        serviceItems: [item],
        initialAssignments: initialAssignments,
        initialPacks: sale.packs > 0 ? sale.packs : null,
      );
      if (result == true) {
        ref.invalidate(saleServiceItemsProvider(sale.id));
        ref.invalidate(saleProvider(sale.id));
        ref.invalidate(kanbanSalesProvider);
      }
    }

    return Padding(
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service name + price row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isCompleted
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currencyFormat.format(item.unitPrice)} x ${item.service?.formatQuantity(item.quantity) ?? '${item.quantity}'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(item.subtotal),
                style: theme.textTheme.titleSmall,
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
                    child: GestureDetector(
                      onTap: isCompleted
                          ? null
                          : () => _editMachine(context, ref),
                      child: SaleAssignmentInfoCard(
                        icon: Icons.local_laundry_service,
                        label: 'Machine',
                        name: item.machineName!,
                        color: isCompleted ? Colors.grey : Colors.blue,
                        compact: compact,
                        showEditHint: !isCompleted,
                      ),
                    ),
                  ),
                if (hasMachine && hasStorage) const SizedBox(width: 12),
                if (hasStorage)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _editStorage(context, ref),
                      child: SaleAssignmentInfoCard(
                        icon: Icons.inventory_2,
                        label: 'Storage',
                        name: item.storageName!,
                        color: Colors.teal,
                        compact: compact,
                        showEditHint: true,
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // Assign buttons when no assignment exists
          if (!hasMachine) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _editMachine(context, ref),
                icon: const Icon(Icons.local_laundry_service, size: 18),
                label: const Text('Assign Machine'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
          if (!hasStorage && sale.orderStatus != OrderStatus.pending) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _editStorage(context, ref),
                icon: const Icon(Icons.inventory_2, size: 18),
                label: const Text('Assign Storage'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                ),
              ),
            ),
          ],

          // Mark Done button
          if (canMarkDone) ...[
            const SizedBox(height: 12),
            SizedBox(
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
            ),
          ],
        ],
      ),
    );
  }
}

/// Packs section showing laundry bag count with edit capability.
class _PacksSection extends HookConsumerWidget {
  const _PacksSection({
    required this.sale,
    required this.compact,
  });

  final Sale sale;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasPacks = sale.packs > 0;

    Future<void> editPacks() async {
      final result = await showSetPacksDialog(
        context,
        initialPacks: sale.packs > 0 ? sale.packs : null,
      );
      if (result == null || !context.mounted) return;

      final repo = ref.read(salesRepositoryProvider);
      final updateResult =
          await repo.updateSale(sale.id, {'packs': result});
      updateResult.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(context, message: failure.messageString);
          }
        },
        (_) {
          ref.invalidate(saleProvider(sale.id));
          ref.invalidate(kanbanSalesProvider);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Packs',
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: editPacks,
              icon: Icon(
                hasPacks ? Icons.edit : Icons.add,
                size: 16,
              ),
              label: Text(hasPacks ? 'Edit' : 'Set Packs'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 20,
                  color: hasPacks
                      ? Colors.purple
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  hasPacks
                      ? '${sale.packs} pack${sale.packs > 1 ? 's' : ''}'
                      : 'No packs set',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasPacks
                        ? Colors.purple
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: hasPacks ? FontWeight.w600 : null,
                    fontStyle: hasPacks ? null : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: compact ? 12 : 16),
      ],
    );
  }
}

/// Special instructions section — always visible.
class _SpecialInstructionsSection extends StatelessWidget {
  const _SpecialInstructionsSection({
    required this.notes,
    required this.compact,
  });

  final String? notes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNotes = notes != null && notes!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Instructions',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasNotes ? Icons.note_alt : Icons.note_alt_outlined,
                  size: 20,
                  color: hasNotes
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasNotes ? notes! : 'No special instructions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasNotes
                          ? null
                          : theme.colorScheme.onSurfaceVariant,
                      fontStyle: hasNotes ? null : FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Total amount card.
class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.totalAmount,
    required this.currencyFormat,
    required this.compact,
  });

  final num totalAmount;
  final NumberFormat currencyFormat;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: compact
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.titleLarge,
            ),
            Text(
              currencyFormat.format(totalAmount),
              style: (compact
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.headlineMedium)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple info row with icon, label, and value.
class SaleInfoRow extends StatelessWidget {
  const SaleInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clickable customer info row that navigates to customer detail.
class SaleCustomerInfoRow extends StatelessWidget {
  const SaleCustomerInfoRow({
    super.key,
    required this.customerName,
    this.customerId,
  });

  final String customerName;
  final String? customerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCustomerId = customerId != null && customerId!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: hasCustomerId
                ? InkWell(
                    onTap: () {
                      DialogDismissingObserver.dismissAllDialogs();
                      CustomerDetailRoute(id: customerId!).go(context);
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              customerName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
                    customerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Card showing a machine or storage assignment with a large icon.
class SaleAssignmentInfoCard extends StatelessWidget {
  const SaleAssignmentInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.name,
    required this.color,
    this.compact = false,
    this.showEditHint = false,
  });

  final IconData icon;
  final String label;
  final String name;
  final Color color;
  final bool compact;
  final bool showEditHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: compact ? 24 : 32,
                  color: color,
                ),
                SizedBox(height: compact ? 4 : 8),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showEditHint)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.edit,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wraps [SaleHighlightBanner] with balance-due data from the payments provider.
class _SaleHighlightBannerWithBalance extends ConsumerWidget {
  const _SaleHighlightBannerWithBalance({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPaid =
        ref.watch(saleTotalPaidProvider(sale.id)).value ?? 0;
    final balanceDue = sale.totalAmount - totalPaid;

    return SaleHighlightBanner(
      orderStatus: sale.orderStatus,
      isPaid: sale.isPaid,
      saleStatus: sale.status,
      paymentStatus: sale.paymentStatus,
      balanceDue: balanceDue,
    );
  }
}
