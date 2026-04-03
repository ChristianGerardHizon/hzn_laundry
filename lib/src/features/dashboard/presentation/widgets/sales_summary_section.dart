import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../sales/presentation/widgets/sale_detail_dialog.dart';
import '../../domain/sales_summary.dart';
import '../controllers/sales_summary_controller.dart';
import 'kpi_card.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (tappable to toggle)
          InkWell(
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

class _SalesSummaryContent extends StatelessWidget {
  const _SalesSummaryContent({required this.data});

  final SalesSummaryData data;

  String _formatCurrency(num amount) {
    return NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    final cards = [
      KpiCard(
        title: 'Total Sales',
        value: _formatCurrency(data.totalSales),
        icon: Icons.point_of_sale,
        subtitle: '${data.items.length} orders',
        compact: true,
        color: Colors.blue,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Total Sales',
          icon: Icons.point_of_sale,
          color: Colors.blue,
          items: data.items,
          total: data.totalSales,
        ),
      ),
      KpiCard(
        title: 'Total Paid',
        value: _formatCurrency(data.totalPaid),
        icon: Icons.check_circle_outline,
        subtitle: '${data.items.where((i) => i.isPaid).length} paid',
        compact: true,
        color: Colors.green,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Total Paid',
          icon: Icons.check_circle_outline,
          color: Colors.green,
          items: data.items.where((i) => i.isPaid).toList(),
          total: data.totalPaid,
        ),
      ),
      KpiCard(
        title: 'Total Unpaid',
        value: _formatCurrency(data.totalUnpaid),
        icon: Icons.pending_outlined,
        subtitle: '${data.items.where((i) => !i.isPaid).length} unpaid',
        compact: true,
        color: Colors.orange,
        onTap: () => _showBreakdownModal(
          context,
          title: 'Total Unpaid',
          icon: Icons.pending_outlined,
          color: Colors.orange,
          items: data.items.where((i) => !i.isPaid).toList(),
          total: data.totalUnpaid,
        ),
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const SizedBox(width: 8),
        ],
      ],
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
    showDialog<void>(
      context: context,
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
                      _SalesBreakdownTile(item: items[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SalesBreakdownTile extends StatelessWidget {
  const _SalesBreakdownTile({required this.item});

  final SalesSummaryItem item;

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
    final currencyFormat =
        NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return InkWell(
      onTap: () => showSaleDetailDialog(context, saleId: item.saleId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: order number, badges, amount
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _shortOrderNumber(item.receiptNumber),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.isBacklog) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
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
                      if (item.customerName != null &&
                          item.customerName!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.customerName!,
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
                        _PaymentChip(isPaid: item.isPaid),
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
                        final qty =
                            e.service?.formatQuantity(e.quantity) ??
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
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isMobile(context)) {
      return const Column(
        children: [
          _LoadingCard(),
          SizedBox(height: 8),
          _LoadingCard(),
          SizedBox(height: 8),
          _LoadingCard(),
        ],
      );
    }

    return const Row(
      children: [
        Expanded(child: _LoadingCard()),
        SizedBox(width: 8),
        Expanded(child: _LoadingCard()),
        SizedBox(width: 8),
        Expanded(child: _LoadingCard()),
      ],
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
