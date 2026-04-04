import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routing/routes/customers.routes.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../../domain/customer_sales_entry.dart';
import '../../controllers/sales_by_customer_controller.dart';
import '../../controllers/sales_by_customer_date_range_controller.dart';
import '../report_search_bar.dart';

/// View displaying sales aggregated by customer within a date range.
class SalesByCustomerView extends HookConsumerWidget {
  const SalesByCustomerView({super.key});

  static final _currencyFormat =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _dateFormat = DateFormat('MMM d, yyyy');

  static const _searchFields = [
    ReportSearchField(key: 'customer', label: 'Customer'),
  ];

  static const _defaultSearchKeys = {'customer'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(salesByCustomerProvider);
    final dateRange = ref.watch(salesByCustomerDateRangeControllerProvider);
    final excludeUnpaid = useState(false);
    final searchController = useTextEditingController();
    final searchQuery = useListenableSelector(
      searchController,
      () => searchController.text,
    );
    final searchFields = useState(_defaultSearchKeys);

    return dataAsync.when(
      data: (entries) => _buildContent(
        context,
        ref,
        entries,
        dateRange,
        excludeUnpaid,
        searchController: searchController,
        searchQuery: searchQuery,
        searchFields: searchFields,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading data: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<CustomerSalesEntry> allEntries,
    DateTimeRange dateRange,
    ValueNotifier<bool> excludeUnpaid, {
    required TextEditingController searchController,
    required String searchQuery,
    required ValueNotifier<Set<String>> searchFields,
  }) {
    final isMobile = Breakpoints.isMobile(context);

    var entries = excludeUnpaid.value
        ? allEntries.where((e) => e.isFullyPaid).toList()
        : allEntries.toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      entries = entries
          .where((e) => e.customerName.toLowerCase().contains(q))
          .toList();
    }

    final totalRevenue =
        entries.fold<num>(0, (sum, e) => sum + e.totalSpent);
    final totalPaid = entries.fold<num>(0, (sum, e) => sum + e.totalPaid);
    final totalOrders =
        entries.fold<int>(0, (sum, e) => sum + e.orderCount);
    final topCustomer = entries.isNotEmpty ? entries.first : null;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(salesByCustomerProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range + exclude unpaid toggle
            _buildToolbar(context, ref, dateRange, excludeUnpaid),
            const SizedBox(height: 12),
            _buildKpiSection(
              context,
              customerCount: entries.length,
              totalRevenue: totalRevenue,
              totalPaid: totalPaid,
              totalOrders: totalOrders,
              topCustomer: topCustomer,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            ReportSearchBar(
              fields: _searchFields,
              selectedKeys: searchFields.value,
              controller: searchController,
              onSelectedKeysChanged: (keys) => searchFields.value = keys,
            ),
            const SizedBox(height: 12),
            if (isMobile)
              _buildMobileList(context, entries)
            else
              _buildDesktopTable(context, entries),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Toolbar: date range + exclude unpaid
  // ---------------------------------------------------------------------------

  Widget _buildToolbar(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange dateRange,
    ValueNotifier<bool> excludeUnpaid,
  ) {
    final theme = Theme.of(context);
    final startStr = _dateFormat.format(dateRange.start);
    final endStr = _dateFormat.format(dateRange.end);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
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
                Icon(Icons.date_range,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('$startStr – $endStr',
                    style: theme.textTheme.titleSmall),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down,
                    size: 20, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
        FilterChip(
          label: const Text('Paid only'),
          selected: excludeUnpaid.value,
          onSelected: (v) => excludeUnpaid.value = v,
          showCheckmark: true,
        ),
      ],
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
          .read(salesByCustomerDateRangeControllerProvider.notifier)
          .setRange(DateTimeRange(start: picked.start, end: adjustedEnd));
    }
  }

  // ---------------------------------------------------------------------------
  // KPI cards
  // ---------------------------------------------------------------------------

  Widget _buildKpiSection(
    BuildContext context, {
    required int customerCount,
    required num totalRevenue,
    required num totalPaid,
    required int totalOrders,
    required CustomerSalesEntry? topCustomer,
    required bool isMobile,
  }) {
    final topLabel = topCustomer != null
        ? '${topCustomer.customerName} (${_currencyFormat.format(topCustomer.totalSpent)})'
        : '—';

    final cards = [
      _KpiData('Customers', '$customerCount', Icons.people, Colors.purple),
      _KpiData('Total Revenue', _currencyFormat.format(totalRevenue),
          Icons.attach_money, Colors.green),
      _KpiData('Total Paid', _currencyFormat.format(totalPaid),
          Icons.check_circle, Colors.teal),
      _KpiData(
          'Total Orders', '$totalOrders', Icons.receipt_long, Colors.blue),
      _KpiData('Top Customer', topLabel, Icons.star, Colors.orange),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            Expanded(child: _kpiCard(cards[0])),
            const SizedBox(width: 8),
            Expanded(child: _kpiCard(cards[1])),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _kpiCard(cards[2])),
            const SizedBox(width: 8),
            Expanded(child: _kpiCard(cards[3])),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _kpiCard(cards[4])),
            const Expanded(child: SizedBox()),
          ]),
        ],
      );
    }

    return Row(
      children: cards
          .expand((c) => [
                Expanded(child: _kpiCard(c)),
                const SizedBox(width: 12),
              ])
          .toList()
        ..removeLast(),
    );
  }

  Widget _kpiCard(_KpiData c) => KpiCard(
      compact: true,
      title: c.title,
      value: c.value,
      icon: c.icon,
      color: c.color);

  // ---------------------------------------------------------------------------
  // Desktop: DataTable
  // ---------------------------------------------------------------------------

  Widget _buildDesktopTable(
    BuildContext context,
    List<CustomerSalesEntry> entries,
  ) {
    if (entries.isEmpty) return _buildEmptyState(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              '${entries.length} customers',
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
                    sortColumnIndex: 2,
                    sortAscending: false,
                    columns: const [
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Orders'), numeric: true),
                      DataColumn(label: Text('Total Spent'), numeric: true),
                      DataColumn(label: Text('Total Paid'), numeric: true),
                      DataColumn(label: Text('Balance'), numeric: true),
                    ],
                    rows: entries
                        .map((e) => _buildDataRow(context, e))
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

  DataRow _buildDataRow(BuildContext context, CustomerSalesEntry entry) {
    final theme = Theme.of(context);
    final balance = entry.unpaidAmount;

    return DataRow(
      cells: [
        DataCell(
          Text(
            entry.customerName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontStyle: entry.customerId == null
                  ? FontStyle.italic
                  : FontStyle.normal,
              color: entry.customerId != null
                  ? theme.colorScheme.primary
                  : null,
            ),
          ),
          onTap: entry.customerId != null
              ? () => CustomerDetailRoute(id: entry.customerId!).go(context)
              : null,
        ),
        DataCell(Text(
          '${entry.orderCount}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        )),
        DataCell(Text(
          _currencyFormat.format(entry.totalSpent),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        )),
        DataCell(Text(
          _currencyFormat.format(entry.totalPaid),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade700,
          ),
        )),
        DataCell(Text(
          _currencyFormat.format(balance),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: balance > 0 ? Colors.red.shade700 : theme.colorScheme.outline,
          ),
        )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile: card list
  // ---------------------------------------------------------------------------

  Widget _buildMobileList(
    BuildContext context,
    List<CustomerSalesEntry> entries,
  ) {
    if (entries.isEmpty) return _buildEmptyState(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${entries.length} customers',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        ...entries.map((e) => _buildMobileCard(context, e)),
      ],
    );
  }

  Widget _buildMobileCard(BuildContext context, CustomerSalesEntry entry) {
    final theme = Theme.of(context);
    final balance = entry.unpaidAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + total spent
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: entry.customerId != null
                        ? () => CustomerDetailRoute(id: entry.customerId!)
                            .go(context)
                        : null,
                    child: Text(
                      entry.customerName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontStyle: entry.customerId == null
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: entry.customerId != null
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                ),
                Text(
                  _currencyFormat.format(entry.totalSpent),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Orders + paid + balance
            Row(
              children: [
                Text(
                  '${entry.orderCount} ${entry.orderCount == 1 ? 'order' : 'orders'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  'Paid ${_currencyFormat.format(entry.totalPaid)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (balance > 0) ...[
                  Text(' · ',
                      style: TextStyle(color: theme.colorScheme.outline)),
                  Text(
                    'Bal ${_currencyFormat.format(balance)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared
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
              Icon(Icons.people_outline,
                  size: 48, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No sales found for this date range.',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
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
