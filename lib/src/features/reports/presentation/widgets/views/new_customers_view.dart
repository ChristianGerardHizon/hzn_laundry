import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../customers/domain/customer.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../controllers/new_customers_controller.dart';
import '../../controllers/new_customers_date_range_controller.dart';
import '../charts/line_chart_widget.dart';
import '../report_search_bar.dart';

/// View displaying new customers registered within a date range.
class NewCustomersView extends HookConsumerWidget {
  const NewCustomersView({super.key});

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, h:mm a');

  static const _searchFields = [
    ReportSearchField(key: 'name', label: 'Name'),
    ReportSearchField(key: 'phone', label: 'Phone'),
    ReportSearchField(key: 'address', label: 'Address'),
  ];

  static const _defaultSearchKeys = {'name'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(newCustomersReportProvider);
    final dateRange = ref.watch(newCustomersDateRangeControllerProvider);
    final searchController = useTextEditingController();
    final searchQuery = useListenableSelector(
      searchController,
      () => searchController.text,
    );
    final searchFields = useState(_defaultSearchKeys);

    return customersAsync.when(
      data: (customers) => _buildContent(
        context,
        ref,
        customers,
        dateRange,
        searchController: searchController,
        searchQuery: searchQuery,
        searchFields: searchFields,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading customers: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Customer> customers,
    DateTimeRange dateRange, {
    required TextEditingController searchController,
    required String searchQuery,
    required ValueNotifier<Set<String>> searchFields,
  }) {
    final isMobile = Breakpoints.isMobile(context);

    // Group by day for chart & highlight
    final dailyCounts = <DateTime, int>{};
    for (final c in customers) {
      final created = c.created;
      if (created == null) continue;
      final day = DateTime(created.year, created.month, created.day);
      dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
    }

    // Find peak day
    int peakCount = 0;
    DateTime? peakDay;
    for (final entry in dailyCounts.entries) {
      if (entry.value > peakCount) {
        peakCount = entry.value;
        peakDay = entry.key;
      }
    }

    final daysWithCustomers = dailyCounts.keys.length;
    final avgPerDay =
        daysWithCustomers > 0 ? customers.length / daysWithCustomers : 0.0;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(newCustomersReportProvider);
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
              totalNew: customers.length,
              avgPerDay: avgPerDay,
              peakDay: peakDay,
              peakCount: peakCount,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildNewCustomersChart(context, dailyCounts),
            const SizedBox(height: 16),
            ReportSearchBar(
              fields: _searchFields,
              selectedKeys: searchFields.value,
              controller: searchController,
              onSelectedKeysChanged: (keys) => searchFields.value = keys,
            ),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final filtered = _filterCustomers(
                  customers, searchQuery, searchFields.value);
              if (isMobile) {
                return _buildMobileCustomersList(context, filtered);
              }
              return _buildDesktopCustomersTable(context, filtered);
            }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search filtering
  // ---------------------------------------------------------------------------

  List<Customer> _filterCustomers(
    List<Customer> customers,
    String query,
    Set<String> activeKeys,
  ) {
    if (query.isEmpty) return customers;
    final q = query.toLowerCase();
    return customers.where((c) {
      for (final key in activeKeys) {
        final matches = switch (key) {
          'name' => c.name.toLowerCase().contains(q),
          'phone' => (c.phone ?? '').toLowerCase().contains(q),
          'address' => (c.address ?? '').toLowerCase().contains(q),
          _ => false,
        };
        if (matches) return true;
      }
      return false;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Date range picker
  // ---------------------------------------------------------------------------

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
          .read(newCustomersDateRangeControllerProvider.notifier)
          .setRange(DateTimeRange(start: picked.start, end: adjustedEnd));
    }
  }

  // ---------------------------------------------------------------------------
  // Chart
  // ---------------------------------------------------------------------------

  Widget _buildNewCustomersChart(
    BuildContext context,
    Map<DateTime, int> dailyCounts,
  ) {
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
          title: 'New Customers per Day',
          spots: spots,
          xLabels: xLabels,
          lineColor: Colors.purple,
          height: 220,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI cards
  // ---------------------------------------------------------------------------

  Widget _buildKpiSection(
    BuildContext context, {
    required int totalNew,
    required double avgPerDay,
    required DateTime? peakDay,
    required int peakCount,
    required bool isMobile,
  }) {
    final peakLabel = peakDay != null
        ? '${DateFormat('MMM d').format(peakDay)} ($peakCount)'
        : '—';

    final cards = [
      _KpiData('New Customers', '$totalNew', Icons.person_add,
          Colors.purple),
      _KpiData('Avg / Day', avgPerDay.toStringAsFixed(1),
          Icons.trending_up, Colors.blue),
      _KpiData('Peak Day', peakLabel, Icons.star, Colors.orange),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[0].title,
                    value: cards[0].value,
                    icon: cards[0].icon,
                    color: cards[0].color)),
            const SizedBox(width: 8),
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[1].title,
                    value: cards[1].value,
                    icon: cards[1].icon,
                    color: cards[1].color)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[2].title,
                    value: cards[2].value,
                    icon: cards[2].icon,
                    color: cards[2].color)),
            const Expanded(child: SizedBox()),
          ]),
        ],
      );
    }

    return Row(
      children: cards
          .expand((c) => [
                Expanded(
                    child: KpiCard(
                        compact: true,
                        title: c.title,
                        value: c.value,
                        icon: c.icon,
                        color: c.color)),
                const SizedBox(width: 12),
              ])
          .toList()
        ..removeLast(),
    );
  }

  // ---------------------------------------------------------------------------
  // Desktop: DataTable
  // ---------------------------------------------------------------------------

  Widget _buildDesktopCustomersTable(
    BuildContext context,
    List<Customer> customers,
  ) {
    if (customers.isEmpty) return _buildEmptyState(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              '${customers.length} new customers',
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
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Registered')),
                    ],
                    rows: customers
                        .map((c) => _buildDataRow(context, c))
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

  DataRow _buildDataRow(BuildContext context, Customer customer) {
    return DataRow(
      cells: [
        DataCell(Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        )),
        DataCell(Text(customer.phone ?? '—')),
        DataCell(Text(customer.address ?? '—')),
        DataCell(Text(
          customer.created != null
              ? _dateTimeFormat.format(customer.created!)
              : '—',
        )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile: card list
  // ---------------------------------------------------------------------------

  Widget _buildMobileCustomersList(
    BuildContext context,
    List<Customer> customers,
  ) {
    if (customers.isEmpty) return _buildEmptyState(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${customers.length} new customers',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        ...customers.map((c) => _buildMobileCustomerCard(context, c)),
      ],
    );
  }

  Widget _buildMobileCustomerCard(BuildContext context, Customer customer) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (customer.phone != null &&
                customer.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone,
                      size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(customer.phone!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  customer.created != null
                      ? _dateTimeFormat.format(customer.created!)
                      : '—',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
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
              Icon(Icons.person_add_disabled,
                  size: 48, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No new customers for this date range.',
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
