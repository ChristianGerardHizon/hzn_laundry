import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../machines/presentation/controllers/machines_controller.dart';
import '../../../pos/domain/payment_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../sales/presentation/widgets/sale_detail_dialog.dart';
import '../../../services/domain/sale_service_item.dart';

import '../../../storages/presentation/controllers/storage_locations_controller.dart';
import '../controllers/orders_by_resource_provider.dart';

/// Shows the Orders by Resource dialog.
Future<void> showOrdersByResourceDialog(BuildContext context) {
  return showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.largeMaxWidth,
    useRootNavigator: true,
    builder: (context) => const OrdersByResourceDialog(),
  );
}

/// Dialog displaying orders grouped by machine or storage location.
class OrdersByResourceDialog extends HookConsumerWidget {
  const OrdersByResourceDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groupMode = useState(ResourceGroupMode.storage);
    final selectedMachineId = useState<String?>(null);
    final selectedStorageId = useState<String?>(null);
    final dateMode = useState(ResourceDateMode.todayAndBacklogs);

    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final filter = OrdersByResourceFilter(
      groupMode: groupMode.value,
      machineId: selectedMachineId.value,
      storageId: selectedStorageId.value,
      dateMode: dateMode.value,
    );

    final dataAsync = ref.watch(ordersByResourceProvider(filter));
    final machinesAsync = ref.watch(machinesControllerProvider);
    final storagesAsync = ref.watch(storageLocationsControllerProvider);

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => ConstrainedDialogContent(
          maxWidth: DialogConstraints.largeMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.hub_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Orders by Resource',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Filter bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Machine / Storage toggle
                    SegmentedButton<ResourceGroupMode>(
                      segments: ResourceGroupMode.values
                          .map((m) => ButtonSegment(
                                value: m,
                                label: Text(m.displayName),
                                icon: Icon(
                                  m == ResourceGroupMode.machine
                                      ? Icons.local_laundry_service
                                      : Icons.inventory_2_outlined,
                                ),
                              ))
                          .toList(),
                      selected: {groupMode.value},
                      onSelectionChanged: (selected) {
                        groupMode.value = selected.first;
                        // Reset specific resource filter when switching modes
                        selectedMachineId.value = null;
                        selectedStorageId.value = null;
                      },
                    ),

                    // Resource dropdown
                    if (groupMode.value == ResourceGroupMode.machine)
                      SizedBox(
                        width: 180,
                        child: machinesAsync.when(
                          data: (machines) => DropdownButton<String?>(
                            value: selectedMachineId.value,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            hint: const Text('All Machines'),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Machines'),
                              ),
                              ...machines.map((m) => DropdownMenuItem(
                                    value: m.id,
                                    child: Text(
                                      m.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ],
                            onChanged: (v) => selectedMachineId.value = v,
                          ),
                          loading: () => const SizedBox(
                            height: 40,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (_, __) => const Text('Error loading'),
                        ),
                      ),

                    if (groupMode.value == ResourceGroupMode.storage)
                      SizedBox(
                        width: 180,
                        child: storagesAsync.when(
                          data: (storages) => DropdownButton<String?>(
                            value: selectedStorageId.value,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            hint: const Text('All Storages'),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Storages'),
                              ),
                              ...storages.map((s) => DropdownMenuItem(
                                    value: s.id,
                                    child: Text(
                                      s.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ],
                            onChanged: (v) => selectedStorageId.value = v,
                          ),
                          loading: () => const SizedBox(
                            height: 40,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (_, __) => const Text('Error loading'),
                        ),
                      ),
                  ],
                ),
              ),

              // Date filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 8,
                  children: ResourceDateMode.values
                      .map((mode) => FilterChip(
                            label: Text(mode.displayName),
                            selected: dateMode.value == mode,
                            onSelected: (_) => dateMode.value = mode,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by customer name or order #',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) => searchQuery.value = v,
                ),
              ),

              // Content
              Expanded(
                child: dataAsync.when(
                  data: (data) => _OrdersByResourceContent(
                    data: data,
                    searchQuery: searchQuery.value,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Failed to load orders: $error',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Content showing grouped order cards.
class _OrdersByResourceContent extends StatelessWidget {
  const _OrdersByResourceContent({
    required this.data,
    this.searchQuery = '',
  });

  final OrdersByResourceData data;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = searchQuery.trim().toLowerCase();

    final allGroups = [
      ...data.groups,
      if (data.unassigned.serviceItems.isNotEmpty) data.unassigned,
    ];

    // Filter groups by search query (match customer name or receipt number)
    final filteredGroups = query.isEmpty
        ? allGroups
        : allGroups
            .map((group) {
              final matchingSales = group.sales.where((sale) {
                final customer =
                    (sale.customerDisplay ?? '').toLowerCase();
                final receipt = sale.receiptNumber.toLowerCase();
                return customer.contains(query) || receipt.contains(query);
              }).toList();

              if (matchingSales.isEmpty) return null;

              final matchingSaleIds =
                  matchingSales.map((s) => s.id).toSet();
              return ResourceOrderGroup(
                resourceId: group.resourceId,
                resourceName: group.resourceName,
                serviceItems: group.serviceItems
                    .where((i) => matchingSaleIds.contains(i.saleId))
                    .toList(),
                sales: matchingSales,
              );
            })
            .whereType<ResourceOrderGroup>()
            .toList();

    if (filteredGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty ? 'No orders found' : 'No matching orders',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final group = filteredGroups[index];
        return _ResourceGroupCard(group: group);
      },
    );
  }
}

/// Card displaying a single resource group with collapsible orders.
class _ResourceGroupCard extends HookWidget {
  const _ResourceGroupCard({required this.group});

  final ResourceOrderGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnassigned = group.resourceId.isEmpty;
    final isExpanded = useState(true);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group header (tappable to collapse/expand)
          InkWell(
            onTap: () => isExpanded.value = !isExpanded.value,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUnassigned
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
                    : theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  Icon(
                    isUnassigned
                        ? Icons.help_outline
                        : Icons.local_laundry_service,
                    size: 20,
                    color: isUnassigned
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.resourceName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${group.sales.length} order${group.sales.length == 1 ? '' : 's'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded.value
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Collapsible order cards
          if (isExpanded.value)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: group.sales
                    .map(
                      (sale) => _OrderCard(
                        sale: sale,
                        serviceItems: group.serviceItems
                            .where((i) => i.saleId == sale.id)
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Short order number from receipt: "S-260401-X7KP" → "#X7KP"
String _shortOrderNumber(String receiptNumber) {
  final parts = receiptNumber.split('-');
  if (parts.length >= 3) return '#${parts.last}';
  if (receiptNumber.length > 4) {
    return '#${receiptNumber.substring(receiptNumber.length - 4)}';
  }
  return receiptNumber;
}

/// Order card matching the dashboard kanban card layout.
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.sale,
    required this.serviceItems,
  });

  final Sale sale;
  final List<SaleServiceItem> serviceItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat =
        NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final customerName = sale.customerDisplay ?? 'Walk-in';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showSaleDetailDialog(context, saleId: sale.id),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer name
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
                      customerName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Short order # + date badge + payment badge
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
                  if (sale.postedDate != null) ...[
                    _DateBadge(date: sale.postedDate!.toLocal()),
                    const SizedBox(width: 4),
                  ],
                  _PaymentBadge(paymentStatus: sale.paymentStatus),
                ],
              ),

              // Service items
              if (serviceItems.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.local_laundry_service,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        serviceItems.map((e) {
                          final qty = e.service?.formatQuantity(e.quantity) ??
                              '${e.quantity}';
                          return '${e.serviceName} x$qty';
                        }).join(', '),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Storage/packs badges
              if (sale.packs > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 12,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${sale.packs}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 6),
              // Amount + time
              Row(
                children: [
                  Text(
                    currencyFormat.format(sale.totalAmount),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (sale.postedDate != null)
                    Text(
                      DateFormat('h:mm a').format(sale.postedDate!.toLocal()),
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
}

/// Date badge (e.g. "Apr 2") for overdue/date display.
class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        DateFormat('MMM d').format(date),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.red,
        ),
      ),
    );
  }
}

/// Payment badge (Paid/Partial/Unpaid).
class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.paymentStatus});

  final PaymentStatus paymentStatus;

  @override
  Widget build(BuildContext context) {
    final color = switch (paymentStatus) {
      PaymentStatus.paid => Colors.green,
      PaymentStatus.partial => Colors.blue,
      PaymentStatus.unpaid => Colors.orange,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        paymentStatus.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

