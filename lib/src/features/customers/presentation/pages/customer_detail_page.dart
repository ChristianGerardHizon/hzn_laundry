import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pocketbase/pocketbase.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/data/dto/sale_item_dto.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../sales/presentation/widgets/sale_detail_dialog.dart';
import '../../../services/data/dto/sale_service_item_dto.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../promos/domain/customer_promo.dart';
import '../../../promos/presentation/controllers/customer_promos_provider.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../domain/customer.dart';
import '../controllers/customer_provider.dart';
import '../controllers/customers_controller.dart';
import '../widgets/customer_form_sheet.dart';
import '../widgets/customer_transfer_branch_dialog.dart';

/// Customer detail page showing customer information and sales history.
class CustomerDetailPage extends HookConsumerWidget {
  const CustomerDetailPage({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerProvider(customerId));
    final isTablet = Breakpoints.isTabletOrLarger(context);

    return customerAsync.when(
      data: (customer) {
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Customer Not Found'),
              automaticallyImplyLeading: !isTablet,
            ),
            body: const Center(
              child: Text('The requested customer could not be found.'),
            ),
          );
        }

        final theme = Theme.of(context);
        final branches = ref.watch(branchesControllerProvider).value;
        final branchName = _branchName(branches, customer.branchId);

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            automaticallyImplyLeading: !isTablet,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(customerProvider(customerId));
                  showInfoSnackBar(
                    context,
                    message: 'Refreshing...',
                    duration: const Duration(seconds: 1),
                  );
                },
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSheet(context, ref),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, ref, value, customer),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'transfer',
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text('Transfer Branch'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Customer info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Information',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'Name', value: customer.name),
                      _InfoRow(label: 'Branch', value: branchName),
                      if (customer.phone != null && customer.phone!.isNotEmpty)
                        _InfoRow(label: 'Phone', value: customer.phone!),
                      if (customer.address != null &&
                          customer.address!.isNotEmpty)
                        _InfoRow(label: 'Address', value: customer.address!),
                      if (customer.notes != null && customer.notes!.isNotEmpty)
                        _InfoRow(label: 'Notes', value: customer.notes!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Loyalty programs section
              _CustomerLoyaltySection(customerId: customerId),
              const SizedBox(height: 16),

              // Sales history section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales History',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _CustomerSalesHistory(customerId: customerId),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    final customer = ref.read(customerProvider(customerId)).value;
    if (customer == null) return;

    showCustomerFormDialog(context, customer: customer);
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Customer customer,
  ) async {
    if (action == 'transfer') {
      final transferred = await showCustomerTransferBranchDialog(
        context,
        customer: customer,
      );
      if (transferred == true && context.mounted) {
        ref.invalidate(customerProvider(customerId));
        showSuccessSnackBar(
          context,
          message: 'Customer transferred to the selected branch',
        );
      }
      return;
    }

    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await ref
            .read(customersControllerProvider.notifier)
            .deleteCustomer(customer.id);
        if (success && context.mounted) {
          showSuccessSnackBar(context, message: 'Customer deleted');
          context.pop();
        } else if (context.mounted) {
          showErrorSnackBar(context, message: 'Failed to delete customer');
        }
      }
    }
  }

  static String _branchName(List<Branch>? branches, String? branchId) {
    if (branchId == null || branchId.isEmpty) return 'Unassigned';
    if (branches == null) return '…';
    for (final branch in branches) {
      if (branch.id == branchId) return branch.name;
    }
    return 'Unknown';
  }
}

/// Time range filter for customer sales history.
enum _SalesFilterMode {
  today('Today', Icons.today),
  weekly('Weekly', Icons.date_range),
  monthly('Monthly', Icons.calendar_month),
  yearly('Yearly', Icons.calendar_today),
  allTime('All Time', Icons.all_inclusive),
  custom('Custom', Icons.tune);

  const _SalesFilterMode(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Returns the PocketBase date filter clause, or null for all time.
  /// For [custom], use [dateFilterForRange] instead.
  String? get dateFilter {
    final now = DateTime.now();
    switch (this) {
      case _SalesFilterMode.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return 'postedDate >= "${start.toPocketBaseUtc()}" && postedDate < "${end.toPocketBaseUtc()}"';
      case _SalesFilterMode.weekly:
        final start = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 7));
        return 'postedDate >= "${start.toPocketBaseUtc()}" && postedDate < "${end.toPocketBaseUtc()}"';
      case _SalesFilterMode.monthly:
        final start = DateTime(now.year, now.month);
        final end = DateTime(now.year, now.month + 1);
        return 'postedDate >= "${start.toPocketBaseUtc()}" && postedDate < "${end.toPocketBaseUtc()}"';
      case _SalesFilterMode.yearly:
        final start = DateTime(now.year);
        final end = DateTime(now.year + 1);
        return 'postedDate >= "${start.toPocketBaseUtc()}" && postedDate < "${end.toPocketBaseUtc()}"';
      case _SalesFilterMode.allTime:
      case _SalesFilterMode.custom:
        return null;
    }
  }

  /// Returns a PocketBase date filter for a custom date range.
  static String dateFilterForRange(DateTime start, DateTime end) {
    final endExclusive =
        DateTime(end.year, end.month, end.day).add(const Duration(days: 1));
    return 'postedDate >= "${start.toPocketBaseUtc()}" && postedDate < "${endExclusive.toPocketBaseUtc()}"';
  }
}

/// Data holder for customer sales with their service items and add-ons.
class _CustomerSalesData {
  const _CustomerSalesData({
    required this.sales,
    this.serviceItemsBySale = const {},
    this.saleItemsBySale = const {},
  });

  final List<Sale> sales;
  final Map<String, List<SaleServiceItem>> serviceItemsBySale;
  final Map<String, List<SaleItem>> saleItemsBySale;
}

/// Widget that fetches and displays sales history for a customer.
///
/// Uses card-style layout matching the dashboard kanban board cards.
class _CustomerSalesHistory extends HookConsumerWidget {
  const _CustomerSalesHistory({required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterMode = useState(_SalesFilterMode.allTime);
    final customStart = useState<DateTime?>(null);
    final customEnd = useState<DateTime?>(null);
    final pb = ref.watch(pocketbaseProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    final future = useMemoized(
      () => _fetchCustomerSalesData(
        pb,
        filterMode.value,
        customStart: customStart.value,
        customEnd: customEnd.value,
      ),
      [filterMode.value, customStart.value, customEnd.value],
    );
    final snapshot = useFuture(future);

    Future<void> pickCustomDate() async {
      final now = DateTime.now();
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: now,
        initialDateRange: customStart.value != null && customEnd.value != null
            ? DateTimeRange(start: customStart.value!, end: customEnd.value!)
            : DateTimeRange(
                start: now.subtract(const Duration(days: 7)), end: now),
      );
      if (range != null) {
        customStart.value = range.start;
        customEnd.value = range.end;
        filterMode.value = _SalesFilterMode.custom;
      }
    }

    final salesCount = snapshot.data?.sales.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final mode in _SalesFilterMode.values) ...[
                if (mode != _SalesFilterMode.values.first)
                  const SizedBox(width: 8),
                FilterChip(
                  selected: filterMode.value == mode,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mode.icon,
                        size: 16,
                        color: filterMode.value == mode
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(mode.label),
                    ],
                  ),
                  onSelected: (_) {
                    if (mode == _SalesFilterMode.custom) {
                      pickCustomDate();
                    } else {
                      filterMode.value = mode;
                    }
                  },
                  showCheckmark: false,
                ),
              ],
            ],
          ),
        ),
        // Custom date range display
        if (filterMode.value == _SalesFilterMode.custom &&
            customStart.value != null &&
            customEnd.value != null) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: pickCustomDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(customStart.value!)} — ${dateFormat.format(customEnd.value!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Sales count
        if (snapshot.connectionState != ConnectionState.waiting &&
            salesCount != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$salesCount ${salesCount == 1 ? 'order' : 'orders'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        // Sales list
        if (snapshot.connectionState == ConnectionState.waiting)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          () {
            final data = snapshot.data;
            final sales = data?.sales ?? [];

            if (sales.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        filterMode.value == _SalesFilterMode.allTime
                            ? 'No sales yet'
                            : 'No sales for this period',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sales.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sale = sales[index];
                return _SaleCard(
                  sale: sale,
                  serviceItems: data?.serviceItemsBySale[sale.id] ?? [],
                  saleItems: data?.saleItemsBySale[sale.id] ?? [],
                );
              },
            );
          }(),
        ],
      ],
    );
  }

  Future<_CustomerSalesData> _fetchCustomerSalesData(
    PocketBase pb,
    _SalesFilterMode filterMode, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    var filter = 'customer = "$customerId" && status != "voided"';

    if (filterMode == _SalesFilterMode.custom &&
        customStart != null &&
        customEnd != null) {
      filter =
          '$filter && ${_SalesFilterMode.dateFilterForRange(customStart, customEnd)}';
    } else {
      final dateFilter = filterMode.dateFilter;
      if (dateFilter != null) {
        filter = '$filter && $dateFilter';
      }
    }

    final records =
        await pb.collection(PocketBaseCollections.sales).getFullList(
              filter: filter,
              sort: '-postedDate',
            );

    final sales =
        records.map((record) => SaleDto.fromRecord(record).toEntity()).toList();

    if (sales.isEmpty) return const _CustomerSalesData(sales: []);

    // Batch-fetch service items and sale items for all sales
    final saleIds = sales.map((s) => s.id).toList();
    final saleIdFilter = saleIds.map((id) => 'sale = "$id"').join(' || ');

    final results = await Future.wait([
      pb.collection(PocketBaseCollections.saleServiceItems).getFullList(
            filter: '($saleIdFilter)',
            expand: 'service',
          ),
      pb
          .collection(PocketBaseCollections.saleItems)
          .getFullList(filter: '($saleIdFilter)'),
    ]);

    final Map<String, List<SaleServiceItem>> serviceItemsBySale = {};
    for (final record in results[0]) {
      final serviceExpanded = record.get<RecordModel?>('expand.service');
      final item = SaleServiceItemDto.fromRecord(record).toEntity(
        serviceExpanded: serviceExpanded,
      );
      serviceItemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }

    final Map<String, List<SaleItem>> saleItemsBySale = {};
    for (final record in results[1]) {
      final item = SaleItemDto.fromRecord(record).toEntity();
      saleItemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }

    return _CustomerSalesData(
      sales: sales,
      serviceItemsBySale: serviceItemsBySale,
      saleItemsBySale: saleItemsBySale,
    );
  }
}

/// Sale card matching the dashboard kanban board card style.
class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    this.serviceItems = const [],
    this.saleItems = const [],
  });

  final Sale sale;
  final List<SaleServiceItem> serviceItems;
  final List<SaleItem> saleItems;

  String _shortOrderNumber(String receiptNumber) {
    final parts = receiptNumber.split('-');
    if (parts.length >= 3) return '#${parts.last}';
    if (receiptNumber.length > 4) {
      return '#${receiptNumber.substring(receiptNumber.length - 4)}';
    }
    return receiptNumber;
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

  Color _orderStatusColor(Sale sale) {
    return switch (sale.orderStatus) {
      OrderStatus.pending => Colors.orange,
      OrderStatus.processing => Colors.blue,
      OrderStatus.ready => Colors.teal,
      OrderStatus.pickedUp => Colors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final statusColor = _orderStatusColor(sale);
    final paymentColor = sale.isPaid ? Colors.green : Colors.orange;

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
              // Short order number & badges
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
                  // Order status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sale.orderStatus.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Payment badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: paymentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sale.isPaid ? 'Paid' : 'Unpaid',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: paymentColor,
                      ),
                    ),
                  ),
                ],
              ),
              // Services & Add-ons summary
              if (serviceItems.isNotEmpty || saleItems.isNotEmpty) ...[
                const SizedBox(height: 6),
                if (serviceItems.isNotEmpty)
                  _ItemSummaryRow(
                    icon: Icons.local_laundry_service,
                    label: serviceItems.map((e) {
                      final qty = e.service?.formatQuantity(e.quantity) ??
                          '${e.quantity}';
                      return '${e.serviceName} x$qty';
                    }).join(', '),
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
                  if (sale.postedDate != null)
                    Text(
                      _formatTime(sale.postedDate!),
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

// ── Loyalty Programs Section ─────────────────────────────────────────────────

class _CustomerLoyaltySection extends ConsumerWidget {
  const _CustomerLoyaltySection({required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosAsync = ref.watch(customerPromosProvider(customerId));
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.loyalty, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Loyalty Programs',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            promosAsync.when(
              data: (promos) {
                if (promos.isEmpty) {
                  return Text(
                    'No loyalty programs enrolled.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }

                return Column(
                  children: promos
                      .map((cp) => _LoyaltyProgressTile(customerPromo: cp))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, _) => Text(
                'Error loading loyalty data',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyProgressTile extends StatelessWidget {
  const _LoyaltyProgressTile({required this.customerPromo});

  final CustomerPromo customerPromo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final promo = customerPromo.promo;
    if (promo == null) return const SizedBox.shrink();

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (customerPromo.isRewardRedeemed) {
      statusText = 'Redeemed';
      statusColor = theme.colorScheme.tertiary;
      statusIcon = Icons.check_circle;
    } else if (customerPromo.canRedeem) {
      statusText = 'Reward Ready!';
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.card_giftcard;
    } else {
      statusText =
          '${customerPromo.completedOrders}/${promo.requiredOrders} orders';
      statusColor = theme.colorScheme.onSurfaceVariant;
      statusIcon = Icons.timer;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  promo.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: customerPromo.progressPercent,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 4),
          Text(
            'Reward: ${promo.rewardDisplay}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
