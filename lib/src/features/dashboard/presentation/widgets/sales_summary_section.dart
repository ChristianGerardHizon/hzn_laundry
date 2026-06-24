import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../sales/presentation/widgets/sale_detail_dialog.dart';
import '../../domain/sales_summary.dart';
import '../controllers/add_ons_summary_controller.dart';
import '../controllers/loads_summary_controller.dart';
import '../controllers/sales_summary_controller.dart';
import '../controllers/total_packs_summary_controller.dart';
import 'add_ons_breakdown_modal.dart';
import 'dashboard_section_print_button.dart';
import 'kpi_card.dart';
import 'loads_breakdown_modal.dart';
import 'total_packs_modal.dart';

/// Dashboard section showing today's sales totals.
///
/// Each KPI card (Total Sales, Total Paid, Total Unpaid) is tappable
/// and opens a modal with the filtered breakdown list.
/// The section can be collapsed/expanded by tapping the header.
class SalesSummarySection extends HookConsumerWidget {
  const SalesSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(salesSummaryProvider);
    final theme = Theme.of(context);
    final isExpanded = useState(true);
    final isRefreshing = useState(false);

    Future<void> handleRefresh() async {
      isRefreshing.value = true;
      ref.invalidate(salesSummaryProvider);
      ref.invalidate(totalPacksSummaryProvider);
      ref.invalidate(addOnsSummaryProvider);
      ref.invalidate(loadsSummaryProvider);
      // Wait for salesSummary to settle before clearing spinner
      try {
        await ref.read(salesSummaryProvider.future);
      } catch (_) {}
      isRefreshing.value = false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (tappable to toggle)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => isExpanded.value = !isExpanded.value,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Today's Sales Summary",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded.value ? 0.0 : -0.25,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more,
                            size: 20,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 32,
                height: 32,
                child: isRefreshing.value
                    ? Padding(
                        padding: const EdgeInsets.all(6),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.outline,
                        ),
                      )
                    : IconButton(
                        onPressed: handleRefresh,
                        icon: const Icon(Icons.refresh),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        tooltip: 'Refresh KPIs',
                        color: theme.colorScheme.outline,
                      ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: summaryAsync.when(
                data: (data) => _SalesSummaryContent(data: data),
                loading: () => const _LoadingCards(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded.value
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _SalesSummaryContent extends ConsumerWidget {
  const _SalesSummaryContent({required this.data});

  final SalesSummaryData data;

  static final _currency =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  String _fmt(num amount) => _currency.format(amount);

  static final _qty = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(totalPacksSummaryProvider);
    final addOnsAsync = ref.watch(addOnsSummaryProvider);
    final loadsAsync = ref.watch(loadsSummaryProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;

    final int cols;
    if (screenWidth >= Breakpoints.desktop) {
      cols = 6;
    } else if (screenWidth >= Breakpoints.mobile) {
      cols = 2;
    } else {
      cols = 1;
    }

    final salesCards = [
      KpiCard(
        title: 'Total Sales',
        value: _fmt(data.totalSales),
        icon: Icons.point_of_sale,
        subtitle: '${data.salesItems.length} orders today',
        compact: true,
        color: Colors.blue,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Total Sales',
          icon: Icons.point_of_sale,
          color: Colors.blue,
          items: data.salesItems,
          total: data.totalSales,
        ),
      ),
      KpiCard(
        title: 'Payments Received',
        value: _fmt(data.totalPaymentsReceived),
        icon: Icons.payments_outlined,
        subtitle: '${data.paymentItems.length} payment entries',
        compact: true,
        color: Colors.green,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Payments Received',
          icon: Icons.payments_outlined,
          color: Colors.green,
          items: data.paymentItems,
          total: data.totalPaymentsReceived,
        ),
      ),
      KpiCard(
        title: 'Outstanding',
        value: _fmt(data.totalOutstanding),
        icon: Icons.pending_outlined,
        subtitle: '${data.outstandingItems.length} orders pending',
        compact: true,
        color: Colors.orange,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Outstanding',
          icon: Icons.pending_outlined,
          color: Colors.orange,
          items: data.outstandingItems,
          total: data.totalOutstanding,
        ),
      ),
      addOnsAsync.when(
        data: (summary) => KpiCard(
          title: 'Add-ons Sold',
          value: _qty.format(summary.totalQuantity),
          icon: Icons.shopping_bag_outlined,
          subtitle: summary.items.isEmpty
              ? 'No add-ons today'
              : '${summary.items.length} product${summary.items.length == 1 ? '' : 's'} · ${_fmt(summary.totalRevenue)}',
          compact: true,
          color: Colors.teal,
          onTap: () => showAddOnsBreakdownModal(
            context,
            summary,
            color: Colors.teal,
          ),
        ),
        loading: () => const _LoadingCard(),
        error: (_, __) => const _LoadingCard(),
      ),
      loadsAsync.when(
        data: (summary) => KpiCard(
          title: 'Loads',
          value: '${summary.totalLoads}',
          icon: Icons.local_laundry_service,
          subtitle: summary.orders.isEmpty
              ? 'No loads today'
              : '${summary.orders.length} order${summary.orders.length == 1 ? '' : 's'}',
          compact: true,
          color: Colors.indigo,
          onTap: () => showLoadsBreakdownModal(
            context,
            summary,
            color: Colors.indigo,
          ),
        ),
        loading: () => const _LoadingCard(),
        error: (_, __) => const _LoadingCard(),
      ),
      packsAsync.when(
        data: (summary) => KpiCard(
          title: 'Total Packs',
          value: '${summary.totalPacks}',
          icon: Icons.inventory_2_outlined,
          subtitle: summary.orders.isEmpty
              ? 'No packs today'
              : '${summary.orders.length} order${summary.orders.length == 1 ? '' : 's'}',
          compact: true,
          color: Colors.cyan,
          onTap: () => showTotalPacksModal(context, summary),
        ),
        loading: () => const _LoadingCard(),
        error: (_, __) => const _LoadingCard(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final rawWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        // Guard against negative/zero widths on extremely narrow constraints,
        // which would throw a BoxConstraints assertion.
        final cardWidth = rawWidth.isFinite && rawWidth > 0 ? rawWidth : 0.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: salesCards
              .map((c) => SizedBox(width: cardWidth, child: c))
              .toList(),
        );
      },
    );
  }

  void _showBreakdownModal(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<SalesSummaryItem> items,
    required num total,
  }) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      builder: (_) => _BreakdownDialog(
        title: title,
        icon: icon,
        color: color,
        items: items,
        total: total,
      ),
    );
  }
}

/// Full-screen dialog showing the breakdown list of sales.
class _BreakdownDialog extends StatelessWidget {
  const _BreakdownDialog({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.total,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<SalesSummaryItem> items;
  final num total;

  String _formatCurrency(num amount) {
    return NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_formatCurrency(total)} · ${items.length} orders',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DashboardSectionPrintButton.sales(
                    sectionTitle: title,
                    salesItems: items,
                    total: total,
                    color: color,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No orders'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _SalesBreakdownTile(
                        item: items[index],
                        itemNumber: index + 1,
                        accentColor: color,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SalesBreakdownTile extends StatelessWidget {
  const _SalesBreakdownTile({
    required this.item,
    required this.itemNumber,
    required this.accentColor,
  });

  final SalesSummaryItem item;
  final int itemNumber;
  final Color accentColor;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return InkWell(
      onTap: () => showSaleDetailDialog(context, saleId: item.saleId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _ItemNumberBadge(number: itemNumber, accentColor: accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: customer name, badges, amount
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.customerName != null &&
                                      item.customerName!.isNotEmpty
                                  ? item.customerName!
                                  : _shortOrderNumber(item.receiptNumber),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  _shortOrderNumber(item.receiptNumber),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.isBacklog) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.deepPurple.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Backlog',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (item.customerName == null ||
                                item.customerName!.isEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Walk-in customer',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(item.totalAmount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.postedDate != null) ...[
                                Text(
                                  _formatTime(item.postedDate!),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              _PaymentChip(label: item.statusLabel),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Services
                  if (item.serviceItems.isNotEmpty) ...[
                    const SizedBox(height: 4),
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
                            item.serviceItems.map((e) {
                              final qty = e.service?.formatQuantity(e.quantity) ??
                                  '${e.quantity}';
                              return '${e.serviceName} x$qty';
                            }).join(', '),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Add-ons
                  if (item.saleItems.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.saleItems
                                .map((e) => '${e.productName} x${e.quantity}')
                                .join(', '),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemNumberBadge extends StatelessWidget {
  const _ItemNumberBadge({required this.number, required this.accentColor});

  final int number;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Paid' => Colors.green,
      'Full Payment' => Colors.green,
      'Partial' => Colors.amber.shade800,
      'Partial Payment' => Colors.amber.shade800,
      _ => Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    const cardCount = 6;

    final int cols;
    if (screenWidth >= Breakpoints.desktop) {
      cols = 6;
    } else if (screenWidth >= Breakpoints.mobile) {
      cols = 2;
    } else {
      cols = 1;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final rawWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        final cardWidth = rawWidth.isFinite && rawWidth > 0 ? rawWidth : 0.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            cardCount,
            (_) => SizedBox(width: cardWidth, child: const _LoadingCard()),
          ),
        );
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 76,
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
