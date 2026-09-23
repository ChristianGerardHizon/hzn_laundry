import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hzn_laundry/src/core/foundation/failure.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../../domain/inventory_report.dart';
import '../../controllers/inventory_report_controller.dart';
import '../charts/bar_chart_widget.dart';
import '../charts/pie_chart_widget.dart';

/// View displaying the inventory report with charts and tables.
class InventoryReportView extends ConsumerWidget {
  const InventoryReportView({super.key});

  static final _currencyFormat = NumberFormat.currency(symbol: '₱');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(inventoryReportProvider);

    return reportAsync.when(
      data: (report) => _buildContent(context, report),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(Failure.displayErrorMessage(error)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, InventoryReport report) {
    final isCompact = Breakpoints.isCompactContent(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKpiSection(context, report),
          const SizedBox(height: 24),

          // Charts — stacked on compact, side-by-side when wide
          if (isCompact) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PieChartWidget(
                  title: 'Stock Status',
                  data: report.stockStatusBreakdown.map(
                    (k, v) => MapEntry(k, v),
                  ),
                  height: 220,
                  colors: const [
                    Color(0xFF4CAF50), // In Stock - Green
                    Color(0xFFFBC02D), // Low Stock - Yellow
                    Color(0xFFF44336), // Out of Stock - Red
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChartWidget(
                  title: 'Products by Category',
                  data: report.productsByCategory.map(
                    (k, v) => MapEntry(k, v),
                  ),
                  height: 220,
                  barColor: Colors.deepPurple,
                ),
              ),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PieChartWidget(
                        title: 'Stock Status',
                        data: report.stockStatusBreakdown.map(
                          (k, v) => MapEntry(k, v),
                        ),
                        height: 220,
                        colors: const [
                          Color(0xFF4CAF50),
                          Color(0xFFFBC02D),
                          Color(0xFFF44336),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BarChartWidget(
                        title: 'Products by Category',
                        data: report.productsByCategory.map(
                          (k, v) => MapEntry(k, v),
                        ),
                        height: 220,
                        barColor: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Low Stock Items
          _buildLowStockSection(context, report, isCompact: isCompact),
        ],
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context, InventoryReport report) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        KpiCard(
          title: 'Total Products',
          value: report.totalProducts.toString(),
          icon: Icons.inventory_2,
          color: Colors.deepPurple,
          compact: true,
        ),
        KpiCard(
          title: 'In Stock',
          value: report.inStockCount.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
          compact: true,
        ),
        KpiCard(
          title: 'Low Stock',
          value: report.lowStockCount.toString(),
          icon: Icons.warning,
          color: Colors.yellow.shade700,
          compact: true,
        ),
        KpiCard(
          title: 'Out of Stock',
          value: report.outOfStockCount.toString(),
          icon: Icons.remove_shopping_cart,
          color: Colors.red,
          compact: true,
        ),
        KpiCard(
          title: 'Expired',
          value: report.expiredCount.toString(),
          icon: Icons.dangerous,
          color: Colors.red.shade900,
          compact: true,
        ),
        KpiCard(
          title: 'Near Expiration',
          value: report.nearExpirationCount.toString(),
          icon: Icons.access_time,
          color: Colors.amber.shade700,
          compact: true,
        ),
        KpiCard(
          title: 'Inventory Value',
          value: _currencyFormat.format(report.totalInventoryValue),
          icon: Icons.attach_money,
          color: Colors.blue,
          compact: true,
        ),
      ],
    );
  }

  Widget _buildLowStockSection(
    BuildContext context,
    InventoryReport report, {
    required bool isCompact,
  }) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y');

    if (report.lowStockItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Low Stock Items',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No low stock items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isCompact) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Low Stock Items',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              for (final item in report.lowStockItems) ...[
                _LowStockItemCard(
                  item: item,
                  dateFormat: dateFormat,
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Low Stock Items',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Current'), numeric: true),
                  DataColumn(label: Text('Threshold'), numeric: true),
                  DataColumn(label: Text('Expiration')),
                ],
                rows: report.lowStockItems.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item.productName)),
                    DataCell(Text(item.categoryName)),
                    DataCell(Text(item.currentStock.toString())),
                    DataCell(Text(item.threshold.toString())),
                    DataCell(Text(
                      item.expirationDate != null
                          ? dateFormat.format(item.expirationDate!)
                          : '-',
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockItemCard extends StatelessWidget {
  const _LowStockItemCard({
    required this.item,
    required this.dateFormat,
  });

  final LowStockItem item;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiration = item.expirationDate != null
        ? dateFormat.format(item.expirationDate!)
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.categoryName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'Stock: ${item.currentStock} / ${item.threshold}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Expires: $expiration',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
