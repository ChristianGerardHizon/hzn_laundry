import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/today_incentive_controller.dart';

/// Shows a bottom sheet with today's incentive breakdown.
void showTodayIncentiveModal(
  BuildContext context,
  TodayIncentiveSummary summary,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _TodayIncentiveSheet(summary: summary),
  );
}

class _TodayIncentiveSheet extends StatelessWidget {
  const _TodayIncentiveSheet({required this.summary});

  final TodayIncentiveSummary summary;

  static final _currency =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  static String _shortReceipt(String receipt) {
    final parts = receipt.split('-');
    if (parts.length >= 3) return '#${parts.last}';
    if (receipt.length > 4) return '#${receipt.substring(receipt.length - 4)}';
    return receipt;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orders = summary.orders;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.payments,
                      color: Colors.purple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Incentive Breakdown",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${orders.length} qualifying order${orders.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Total chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currency.format(summary.totalIncentive),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Body
          Expanded(
            child: orders.isEmpty
                ? _buildEmpty(context, theme)
                : _buildList(context, theme, scrollController),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_outlined,
              size: 48, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'No qualifying orders today.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Processing orders are excluded.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ThemeData theme,
    ScrollController scrollController,
  ) {
    final orders = summary.orders;
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orders.length + 1, // +1 for totals footer
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index == orders.length) {
          return _buildTotalsRow(theme);
        }
        return _buildOrderTile(theme, orders[index]);
      },
    );
  }

  Widget _buildOrderTile(ThemeData theme, TodayOrderIncentiveEntry order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Receipt + customer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _shortReceipt(order.receiptNumber),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (order.customerName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    order.customerName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                _StatusBadge(status: order.orderStatus),
              ],
            ),
          ),
          // Prices
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currency.format(order.servicePrice),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _currency.format(order.incentive),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Incentive',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            _currency.format(summary.totalIncentive),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      'ready' => Colors.green,
      'pickedUp' => Colors.blue,
      'pending' => Colors.orange,
      _ => theme.colorScheme.onSurfaceVariant,
    };
    final label = switch (status) {
      'ready' => 'Ready',
      'pickedUp' => 'Picked Up',
      'pending' => 'Pending',
      _ => status,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 6, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
