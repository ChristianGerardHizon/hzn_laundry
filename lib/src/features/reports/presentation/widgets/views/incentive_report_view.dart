import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../controllers/employee_report_controller.dart';
import '../../controllers/employee_report_date_range_controller.dart';

String _shortOrderNumber(String receiptNumber) {
  final parts = receiptNumber.split('-');
  if (parts.length >= 3) return '#${parts.last}';
  if (receiptNumber.length > 4) {
    return '#${receiptNumber.substring(receiptNumber.length - 4)}';
  }
  return receiptNumber;
}

/// View displaying the daily incentive breakdown.
class IncentiveReportView extends HookConsumerWidget {
  const IncentiveReportView({super.key});

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _currencyFormat =
      NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(employeeReportProvider);
    final dateRange = ref.watch(employeeReportDateRangeControllerProvider);

    return reportAsync.when(
      data: (data) => _buildContent(context, ref, data, dateRange),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading report: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    EmployeeReportData data,
    DateTimeRange dateRange,
  ) {
    final isMobile = Breakpoints.isMobile(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(employeeReportProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeRow(context, ref, dateRange),
            const SizedBox(height: 12),
            _buildKpiSection(context, data, isMobile),
            const SizedBox(height: 16),
            _buildRateCard(context, data),
            const SizedBox(height: 16),
            _buildPerEmployeeSummary(context, data),
            const SizedBox(height: 16),
            _buildDailyBreakdownHeader(context, data),
            const SizedBox(height: 8),
            if (data.dailyBreakdown.isEmpty)
              _buildEmptyState(context)
            else
              ...data.dailyBreakdown.map(
                  (entry) => _buildDayCard(context, entry)),
          ],
        ),
      ),
    );
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
            Text('$startStr \u2013 $endStr',
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
          .read(employeeReportDateRangeControllerProvider.notifier)
          .setRange(DateTimeRange(start: picked.start, end: adjustedEnd));
    }
  }

  // ---------------------------------------------------------------------------
  // KPI cards
  // ---------------------------------------------------------------------------

  Widget _buildKpiSection(
    BuildContext context,
    EmployeeReportData data,
    bool isMobile,
  ) {
    final cards = [
      _KpiData(
        'Service Revenue',
        _currencyFormat.format(data.totalServicePrice),
        Icons.point_of_sale,
        Colors.blue,
      ),
      _KpiData(
        'Total Incentive',
        _currencyFormat.format(data.totalIncentive),
        Icons.payments,
        Colors.green,
      ),
      _KpiData(
        'Days w/ Revenue',
        '${data.dailyBreakdown.where((d) => d.serviceRevenue > 0).length}',
        Icons.calendar_today,
        Colors.orange,
      ),
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
  // Rate info card
  // ---------------------------------------------------------------------------

  Widget _buildRateCard(BuildContext context, EmployeeReportData data) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: data.incentiveTiers.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incentive tiers (split among present employees):',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: data.incentiveTiers.map((tier) {
                            return Chip(
                              label: Text(
                                '${tier.label} \u2192 ${_currencyFormat.format(tier.incentiveAmount)}',
                                style: theme.textTheme.labelSmall,
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : Text.rich(
                      TextSpan(
                        text: 'Incentive rate: ',
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text:
                                '${_currencyFormat.format(data.incentiveRate)} per ${_currencyFormat.format(data.perServicePrice)} service revenue',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(
                            text:
                                ' \u2014 split among employees who are In that day',
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Per-employee incentive summary
  // ---------------------------------------------------------------------------

  Widget _buildPerEmployeeSummary(
    BuildContext context,
    EmployeeReportData data,
  ) {
    final theme = Theme.of(context);

    if (data.entries.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incentive per Employee',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                theme.colorScheme.primaryContainer,
                            child: Text(
                              entry.employee.name.isNotEmpty
                                  ? entry.employee.name[0].toUpperCase()
                                  : '?',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(entry.employee.name,
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      Text(
                        _currencyFormat.format(entry.incentiveAmount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _currencyFormat.format(data.totalIncentive),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Daily breakdown header
  // ---------------------------------------------------------------------------

  Widget _buildDailyBreakdownHeader(
    BuildContext context,
    EmployeeReportData data,
  ) {
    final theme = Theme.of(context);
    return Text(
      'Daily Breakdown',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Day card
  // ---------------------------------------------------------------------------

  Widget _buildDayCard(BuildContext context, DailyIncentiveEntry entry) {
    return _DayCard(entry: entry, currencyFormat: _currencyFormat);
  }

  // ---------------------------------------------------------------------------
  // Empty state
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
              Icon(Icons.payments,
                  size: 48, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No incentive data for this date range.',
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

class _DayCard extends HookWidget {
  const _DayCard({
    required this.entry,
    required this.currencyFormat,
  });

  final DailyIncentiveEntry entry;
  final NumberFormat currencyFormat;

  static final _dayFormat = DateFormat('EEE, MMM d');

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: entry.orderBreakdown.isNotEmpty
            ? () => isExpanded.value = !isExpanded.value
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _dayFormat.format(entry.date),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (entry.orderBreakdown.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded.value
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    currencyFormat.format(entry.dayIncentive),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Revenue and attendance
              Row(
                children: [
                  _DayStatChip(
                    label:
                        'Revenue: ${currencyFormat.format(entry.serviceRevenue)}',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _DayStatChip(
                    label: '${entry.presentEmployees.length} In',
                    color: Colors.green,
                  ),
                  if (entry.orderBreakdown.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    _DayStatChip(
                      label: '${entry.orderBreakdown.length} orders',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),

              if (entry.presentEmployees.isNotEmpty &&
                  entry.dayIncentive > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '${currencyFormat.format(entry.perEmployeeIncentive)} each \u2192 ${entry.presentEmployees.map((e) => e.name).join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              // Expanded order breakdown
              if (isExpanded.value && entry.orderBreakdown.isNotEmpty) ...[
                const Divider(height: 20),
                _OrderBreakdownSection(
                  entry: entry,
                  currencyFormat: currencyFormat,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderBreakdownSection extends StatelessWidget {
  const _OrderBreakdownSection({
    required this.entry,
    required this.currencyFormat,
  });

  final DailyIncentiveEntry entry;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Breakdown',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (isMobile)
          _buildMobileBreakdown(context, theme)
        else
          _buildTableBreakdown(context, theme),
        const Divider(height: 16),
        _buildTotalsRow(theme),
      ],
    );
  }

  Widget _buildTableBreakdown(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: constraints.maxWidth),
        child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 44,
        horizontalMargin: 0,
        columns: const [
          DataColumn(label: Text('Order')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Service Price'), numeric: true),
          DataColumn(label: Text('Incentive'), numeric: true),
        ],
        rows: [
          ...entry.orderBreakdown.map(
            (order) => DataRow(cells: [
              DataCell(Text(
                _shortOrderNumber(order.receiptNumber),
                style: const TextStyle(fontWeight: FontWeight.w500),
              )),
              DataCell(Text(order.customerName ?? '\u2014')),
              DataCell(Text(order.orderStatus)),
              DataCell(Text(currencyFormat.format(order.servicePrice))),
              DataCell(Text(
                currencyFormat.format(order.incentive),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              )),
            ]),
          ),
          // Totals row
          DataRow(cells: [
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            DataCell(Text(
              'Total Incentive',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            )),
            DataCell(Text(
              currencyFormat.format(entry.dayIncentive),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            )),
          ]),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildMobileBreakdown(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        ...entry.orderBreakdown.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _shortOrderNumber(order.receiptNumber),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (order.customerName != null &&
                          order.customerName!.isNotEmpty)
                        Text(
                          order.customerName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(order.servicePrice),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Incentive: ${currencyFormat.format(order.incentive)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsRow(ThemeData theme) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Incentive',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              currencyFormat.format(entry.dayIncentive),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
    );
  }
}

class _DayStatChip extends StatelessWidget {
  const _DayStatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
