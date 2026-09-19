import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hzn_laundry/src/core/foundation/failure.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKpiSection(context, report),
          const SizedBox(height: 24),

          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Status Pie Chart
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
                        Color(0xFF4CAF50), // In Stock - Green
                        Color(0xFFFBC02D), // Low Stock - Yellow
                        Color(0xFFF44336), // Out of Stock - Red
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Products by Category Bar Chart
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

          // Low Stock Items Table
          _buildLowStockTable(context, report),
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

  Widget _buildLowStockTable(BuildContext context, InventoryReport report) {
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
