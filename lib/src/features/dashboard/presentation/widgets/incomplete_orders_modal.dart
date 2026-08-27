import 'package:flutter/material.dart';

import '../../../pos/domain/order_status.dart';
import '../../../sales/presentation/widgets/sale_detail_dialog.dart';
import '../../domain/incomplete_orders.dart';

void showIncompleteOrdersModal(
  BuildContext context,
  IncompleteOrdersData data, {
  Color color = Colors.deepOrange,
}) {
  final parentContext = context;
  final rootContext = Navigator.of(context, rootNavigator: true).context;
  showDialog<void>(
    context: rootContext,
    useRootNavigator: true,
    builder: (_) => _IncompleteOrdersDialog(
      data: data,
      color: color,
      parentContext: parentContext,
    ),
  );
}

class _IncompleteOrdersDialog extends StatelessWidget {
  const _IncompleteOrdersDialog({
    required this.data,
    required this.color,
    required this.parentContext,
  });

  final IncompleteOrdersData data;
  final Color color;
  final BuildContext parentContext;

  static String _shortReceipt(String receipt) {
    final parts = receipt.split('-');
    if (parts.length >= 3) return '#${parts.last}';
    if (receipt.length > 4) return '#${receipt.substring(receipt.length - 4)}';
    return receipt;
  }

  static String _statusLabel(OrderStatus status) => switch (status) {
        OrderStatus.pending => 'Pending',
        OrderStatus.processing => 'Processing',
        OrderStatus.ready => 'Ready',
        OrderStatus.pickedUp => 'Picked up',
      };

  static String _issueLabel(OrderDataIssue issue) => switch (issue) {
        OrderDataIssue.stillProcessing => 'Still processing',
        OrderDataIssue.missingMachines => 'Missing machines',
        OrderDataIssue.missingPacks => 'Missing packs',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orders = data.orders;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.warning_amber_rounded,
                        color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Needs Attention',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          orders.isEmpty
                              ? 'All orders have complete details'
                              : '${orders.length} order${orders.length == 1 ? '' : 's'} need details',
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
            if (orders.isEmpty)
              Expanded(child: _buildEmpty(theme))
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    return _buildOrderTile(context, theme, orders[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              size: 48, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'All orders have complete details.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(
    BuildContext context,
    ThemeData theme,
    IncompleteOrderEntry order,
  ) {
    final hasName =
        order.customerName != null && order.customerName!.isNotEmpty;
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        showSaleDetailDialog(parentContext, saleId: order.saleId);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        hasName ? order.customerName! : 'Walk-in',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_shortReceipt(order.receiptNumber)} · ${_statusLabel(order.orderStatus)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final issue in order.issues)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(_issueLabel(issue)),
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    backgroundColor: color.withValues(alpha: 0.12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
