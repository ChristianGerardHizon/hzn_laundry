import 'package:flutter/material.dart';

import '../../../sales/presentation/widgets/sale_detail_dialog.dart';
import '../../domain/packs_summary.dart';
import 'dashboard_section_print_button.dart';

void showTotalPacksModal(
  BuildContext context,
  TotalPacksSummary summary,
) {
  final rootContext = Navigator.of(context, rootNavigator: true).context;
  showDialog<void>(
    context: rootContext,
    useRootNavigator: true,
    builder: (_) => _TotalPacksDialog(summary: summary),
  );
}

class _TotalPacksDialog extends StatelessWidget {
  const _TotalPacksDialog({required this.summary});

  final TotalPacksSummary summary;

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

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
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
                      color: Colors.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: Colors.cyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Packs Breakdown',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${orders.length} order${orders.length == 1 ? '' : 's'} with packs',
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
                      color: Colors.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${summary.totalPacks} pack${summary.totalPacks == 1 ? '' : 's'}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DashboardSectionPrintButton.packs(
                    packs: summary,
                    color: Colors.cyan,
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

            // Body
            if (orders.isEmpty)
              Expanded(child: _buildEmpty(context, theme))
            else
              Flexible(child: _buildList(context, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 48, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'No packs recorded today.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, ThemeData theme) {
    final orders = summary.orders;
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orders.length + 1,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index == orders.length) {
          return _buildTotalsRow(theme);
        }
        return _buildOrderTile(context, theme, orders[index], index + 1);
      },
    );
  }

  Widget _buildOrderTile(
    BuildContext context,
    ThemeData theme,
    PacksOrderEntry order,
    int itemNumber,
  ) {
    return InkWell(
      onTap: () => showSaleDetailDialog(context, saleId: order.saleId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _ItemNumberBadge(number: itemNumber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName ?? 'Walk-in',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _shortReceipt(order.receiptNumber),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _StatusBadge(status: order.orderStatus),
                ],
              ),
            ),
            Text(
              '${order.packs} pack${order.packs == 1 ? '' : 's'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.cyan,
              ),
            ),
          ],
        ),
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
            'Total Packs',
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${summary.totalPacks} pack${summary.totalPacks == 1 ? '' : 's'}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemNumberBadge extends StatelessWidget {
  const _ItemNumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.cyan,
        ),
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
