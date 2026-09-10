import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/consumables_usage_summary.dart';
import 'dashboard_section_print_button.dart';

void showConsumablesUsageBreakdownModal(
  BuildContext context,
  ConsumablesUsageSummaryData summary, {
  Color color = Colors.deepPurple,
  bool showCost = false,
}) {
  final rootContext = Navigator.of(context, rootNavigator: true).context;
  showDialog<void>(
    context: rootContext,
    useRootNavigator: true,
    builder: (_) => _ConsumablesUsageBreakdownDialog(
      summary: summary,
      color: color,
      showCost: showCost,
    ),
  );
}

class _ConsumablesUsageBreakdownDialog extends StatelessWidget {
  const _ConsumablesUsageBreakdownDialog({
    required this.summary,
    required this.color,
    required this.showCost,
  });

  final ConsumablesUsageSummaryData summary;
  final Color color;
  final bool showCost;

  static final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _qty = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = summary.items;
    final avg = _qty.format(summary.averagePerOrder);

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
                    child: Icon(Icons.science_outlined, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consumables used',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_qty.format(summary.totalQuantity)} used · $avg avg/order',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showCost)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currency.format(summary.totalCost),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  DashboardSectionPrintButton.consumables(
                    consumables: summary,
                    showConsumableCost: showCost,
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
            if (items.isEmpty)
              Expanded(child: _buildEmpty(theme))
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return _buildTotalsRow(theme);
                    }
                    return _buildItemTile(theme, items[index], index + 1);
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
          Icon(
            Icons.science_outlined,
            size: 48,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No consumables recorded today.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(
    ThemeData theme,
    ConsumableUsageBreakdownItem item,
    int number,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.isNotEmpty ? item.productName : 'Unnamed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'in ${item.orderCount} order${item.orderCount == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '×${_qty.format(item.quantity)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              if (showCost) ...[
                const SizedBox(height: 4),
                Text(
                  _currency.format(item.cost),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
            'Avg ${_qty.format(summary.averagePerOrder)} / order',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            showCost
                ? _currency.format(summary.totalCost)
                : '${_qty.format(summary.totalQuantity)} used',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
