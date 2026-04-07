import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../../../pos/domain/payment_status.dart';
import '../../../../pos/domain/sale.dart';
import '../../controllers/sales_detail_controller.dart';
import '../../controllers/sales_detail_date_range_controller.dart';
import '../charts/line_chart_widget.dart';
import '../report_search_bar.dart';

String _shortOrderNumber(String receiptNumber) {
  final parts = receiptNumber.split('-');
  if (parts.length >= 3) return '#${parts.last}';
  if (receiptNumber.length > 4) {
    return '#${receiptNumber.substring(receiptNumber.length - 4)}';
  }
  return receiptNumber;
}

/// View displaying a detailed list of orders within a date range.
///
/// Adapts layout between mobile (card list) and tablet/desktop (DataTable).
class SalesDetailView extends HookConsumerWidget {
  const SalesDetailView({super.key});

  static final _currencyFormat =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, h:mm a');

  static const _searchFields = [
    ReportSearchField(key: 'customer', label: 'Customer'),
    ReportSearchField(key: 'receipt', label: 'Receipt #'),
    ReportSearchField(key: 'amount', label: 'Amount'),
    ReportSearchField(key: 'status', label: 'Status'),
    ReportSearchField(key: 'orderStatus', label: 'Order Status'),
  ];

  static const _defaultSearchKeys = {'customer', 'receipt', 'amount'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesDetailProvider);
    final dateRange = ref.watch(salesDetailDateRangeControllerProvider);
    final searchController = useTextEditingController();
    final searchQuery = useListenableSelector(
      searchController,
      () => searchController.text,
    );
    final searchFields = useState(_defaultSearchKeys);

    return salesAsync.when(
      data: (sales) => _buildContent(
        context,
        ref,
        sales,
        dateRange,
        searchController: searchController,
        searchQuery: searchQuery,
        searchFields: searchFields,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading orders: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Sale> sales,
    DateTimeRange dateRange, {
    required TextEditingController searchController,
    required String searchQuery,
    required ValueNotifier<Set<String>> searchFields,
  }) {
    final isMobile = Breakpoints.isMobile(context);
    final nonVoidedSales = sales.where((s) => s.status != 'voided').toList();
    final totalRevenue =
        nonVoidedSales.fold<num>(0, (sum, s) => sum + s.totalAmount);
    final paidCount = sales.where((s) => s.isPaid).length;
    final unpaidCount = sales.where((s) => !s.isPaid).length;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(salesDetailProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeRow(context, ref, dateRange),
            const SizedBox(height: 12),
            _buildKpiSection(
              context,
              totalRevenue: totalRevenue,
              totalOrders: sales.length,
              paidCount: paidCount,
              unpaidCount: unpaidCount,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildOrdersByDayChart(context, sales),
            const SizedBox(height: 16),
            ReportSearchBar(
              fields: _searchFields,
              selectedKeys: searchFields.value,
              controller: searchController,
              onSelectedKeysChanged: (keys) => searchFields.value = keys,
            ),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final filtered =
                  _filterSales(sales, searchQuery, searchFields.value);
              if (isMobile) {
                return _buildMobileOrdersList(context, filtered);
              }
              return _buildDesktopOrdersTable(context, filtered);
            }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search filtering
  // ---------------------------------------------------------------------------

  List<Sale> _filterSales(
    List<Sale> sales,
    String query,
    Set<String> activeKeys,
  ) {
    if (query.isEmpty) return sales;
    final q = query.toLowerCase();
    return sales.where((s) {
      for (final key in activeKeys) {
        final matches = switch (key) {
          'receipt' => s.receiptNumber.toLowerCase().contains(q),
          'customer' => (s.customerName ?? '').toLowerCase().contains(q),
          'amount' => _currencyFormat.format(s.totalAmount).contains(q),
          'status' => s.status.toLowerCase().contains(q),
          'orderStatus' =>
            s.orderStatus.displayName.toLowerCase().contains(q),
          _ => false,
        };
        if (matches) return true;
      }
      return false;
    }).toList();
  }

  Widget _buildDateRangeRow(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange dateRange,
  ) {
    final theme = Theme.of(context);
    final startStr = _dateFormat.format(dateRange.start);
    final endStr = _dateFormat.format(dateRange.end);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _pickDateRange(context, ref, dateRange),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '$startStr – $endStr',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange dateRange,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: dateRange,
    );
    if (picked != null) {
      final adjustedEnd = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
        999,
      );
      ref
          .read(salesDetailDateRangeControllerProvider.notifier)
          .setRange(DateTimeRange(start: picked.start, end: adjustedEnd));
    }
  }

  Widget _buildOrdersByDayChart(BuildContext context, List<Sale> sales) {
    final dailyCounts = <DateTime, int>{};
    for (final sale in sales) {
      final postedDate = sale.postedDate;
      if (postedDate == null) continue;
      final day = DateTime(postedDate.year, postedDate.month, postedDate.day);
      dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
    }

    if (dailyCounts.isEmpty) return const SizedBox.shrink();

    final sortedDays = dailyCounts.keys.toList()..sort();
    final spots = sortedDays.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        dailyCounts[entry.value]!.toDouble(),
      );
    }).toList();
    final xLabels =
        sortedDays.map((d) => DateFormat('MMM d').format(d)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChartWidget(
          title: 'Orders per Day',
          spots: spots,
          xLabels: xLabels,
          lineColor: Colors.blue,
          height: 220,
        ),
      ),
    );
  }

  Widget _buildKpiSection(
    BuildContext context, {
    required num totalRevenue,
    required int totalOrders,
    required int paidCount,
    required int unpaidCount,
    required bool isMobile,
  }) {
    final cards = [
      _KpiData('Total Revenue', _currencyFormat.format(totalRevenue),
          Icons.attach_money, Colors.green),
      _KpiData('Total Orders', '$totalOrders', Icons.receipt_long, Colors.blue),
      _KpiData(
          'Paid Orders', '$paidCount', Icons.check_circle, Colors.teal),
      _KpiData(
          'Unpaid Orders', '$unpaidCount', Icons.cancel, Colors.orange),
    ];

    if (isMobile) {
      // 2x2 grid on mobile
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[0].title,
                    value: cards[0].value,
                    icon: cards[0].icon,
                    color: cards[0].color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[1].title,
                    value: cards[1].value,
                    icon: cards[1].icon,
                    color: cards[1].color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[2].title,
                    value: cards[2].value,
                    icon: cards[2].icon,
                    color: cards[2].color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[3].title,
                    value: cards[3].value,
                    icon: cards[3].icon,
                    color: cards[3].color),
              ),
            ],
          ),
        ],
      );
    }

    // Desktop: single row
    return Row(
      children: cards
          .expand((c) => [
                Expanded(
                  child: KpiCard(
                    compact: true,
                    title: c.title,
                    value: c.value,
                    icon: c.icon,
                    color: c.color,
                  ),
                ),
                const SizedBox(width: 12),
              ])
          .toList()
        ..removeLast(),
    );
  }

  // ---------------------------------------------------------------------------
  // Desktop: DataTable
  // ---------------------------------------------------------------------------

  Widget _buildDesktopOrdersTable(BuildContext context, List<Sale> sales) {
    if (sales.isEmpty) return _buildEmptyState(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              '${sales.length} orders',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowHeight: 44,
                    dataRowMinHeight: 40,
                    dataRowMaxHeight: 48,
                    columns: const [
                      DataColumn(label: Text('Receipt #')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Amount'), numeric: true),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Order Status')),
                      DataColumn(label: Text('Paid')),
                      DataColumn(label: Text('Picked Up')),
                      DataColumn(label: Text('Created')),
                      DataColumn(label: Text('')),
                    ],
                    rows: sales
                        .map((sale) => _buildDataRow(context, sale))
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, Sale sale) {
    final theme = Theme.of(context);
    final isVoided = sale.status == 'voided';
    final strikeStyle = TextStyle(
      decoration: TextDecoration.lineThrough,
      color: theme.colorScheme.outline,
    );

    return DataRow(
      cells: [
        DataCell(Text(
          _shortOrderNumber(sale.receiptNumber),
          style: isVoided ? strikeStyle : null,
        )),
        DataCell(Text(sale.customerName ?? '—')),
        DataCell(Text(_currencyFormat.format(sale.totalAmount))),
        DataCell(_buildStatusChip(context, sale.status)),
        DataCell(_buildOrderStatusChip(context, sale.orderStatus.displayName)),
        DataCell(Builder(builder: (context) {
          final color = switch (sale.paymentStatus) {
            PaymentStatus.paid => Colors.green,
            PaymentStatus.partial => Colors.blue,
            PaymentStatus.unpaid => Colors.orange,
          };
          final icon = switch (sale.paymentStatus) {
            PaymentStatus.paid => Icons.check_circle,
            PaymentStatus.partial => Icons.timelapse,
            PaymentStatus.unpaid => Icons.cancel,
          };
          return Icon(icon, size: 18, color: color);
        })),
        DataCell(Text(
          sale.pickedUpAt != null
              ? _dateTimeFormat.format(sale.pickedUpAt!)
              : '—',
        )),
        DataCell(Text(
          sale.postedDate != null ? _dateTimeFormat.format(sale.postedDate!) : '—',
        )),
        DataCell(
          IconButton(
            icon: Icon(Icons.open_in_new,
                size: 16, color: theme.colorScheme.primary),
            tooltip: 'View order',
            onPressed: () => SaleDetailRoute(id: sale.id).go(context),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile: card list
  // ---------------------------------------------------------------------------

  Widget _buildMobileOrdersList(BuildContext context, List<Sale> sales) {
    if (sales.isEmpty) return _buildEmptyState(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${sales.length} orders',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        ...sales.map((sale) => _buildMobileOrderCard(context, sale)),
      ],
    );
  }

  Widget _buildMobileOrderCard(BuildContext context, Sale sale) {
    final theme = Theme.of(context);
    final isVoided = sale.status == 'voided';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => SaleDetailRoute(id: sale.id).go(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer name
              if (sale.customerName != null &&
                  sale.customerName!.isNotEmpty) ...[
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
                        sale.customerName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isVoided
                              ? theme.colorScheme.outline
                              : theme.colorScheme.onSurface,
                          decoration: isVoided
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              // Short order # + payment badge
              Row(
                children: [
                  Text(
                    _shortOrderNumber(sale.receiptNumber),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontFamily: 'monospace',
                      decoration:
                          isVoided ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const Spacer(),
                  _PaymentBadge(paymentStatus: sale.paymentStatus),
                ],
              ),
              const SizedBox(height: 6),
              // Status chips
              Row(
                children: [
                  _buildStatusChip(context, sale.status),
                  const SizedBox(width: 6),
                  _buildOrderStatusChip(
                      context, sale.orderStatus.displayName),
                  if (sale.packs > 0) ...[
                    const SizedBox(width: 6),
                    _MiniChip(
                      label: '${sale.packs} pack${sale.packs > 1 ? 's' : ''}',
                      color: Colors.purple,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Amount + time
              Row(
                children: [
                  Text(
                    _currencyFormat.format(sale.totalAmount),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isVoided ? theme.colorScheme.outline : null,
                      decoration:
                          isVoided ? TextDecoration.lineThrough : null,
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

  static String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateFormat('h:mm a').format(local);
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'No orders found for this date range.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final (Color color, String label) = switch (status) {
      'completed' => (Colors.green, 'Completed'),
      'refunded' => (Colors.blue, 'Refunded'),
      'voided' => (Colors.red, 'Voided'),
      _ => (Colors.grey, status),
    };

    return _MiniChip(label: label, color: color);
  }

  Widget _buildOrderStatusChip(BuildContext context, String displayName) {
    final color = switch (displayName) {
      'Pending' => Colors.orange,
      'Processing' => Colors.blue,
      'Ready' => Colors.teal,
      'Picked Up' => Colors.green,
      _ => Colors.grey,
    };

    return _MiniChip(label: displayName, color: color);
  }
}

/// Lightweight chip that avoids Material Chip's extra padding.
class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

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
    final label = paymentStatus.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (paymentStatus) {
              PaymentStatus.paid => Icons.check_circle,
              PaymentStatus.partial => Icons.timelapse,
              PaymentStatus.unpaid => Icons.cancel,
            },
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiData {
  const _KpiData(this.title, this.value, this.icon, this.color);
  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
