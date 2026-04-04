import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../controllers/employee_report_controller.dart';
import '../../controllers/employee_report_date_range_controller.dart';

/// View displaying employee attendance and salary report.
class EmployeeReportView extends HookConsumerWidget {
  const EmployeeReportView({super.key});

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _currencyFormat =
      NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(employeeReportProvider);
    final dateRange = ref.watch(employeeReportDateRangeControllerProvider);

    return reportAsync.when(
      data: (data) =>
          _buildContent(context, ref, data, dateRange),
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
            if (isMobile)
              _buildMobileEmployeeList(context, data)
            else
              _buildDesktopEmployeeTable(context, data),
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
      _KpiData('Employees', '${data.entries.length}', Icons.badge,
          Colors.blue),
      _KpiData('Total In', '${data.totalPresent}', Icons.check_circle,
          Colors.green),
      _KpiData('Total Out', '${data.totalOut}', Icons.cancel,
          Colors.grey),
      _KpiData(
          'Total Pay',
          _currencyFormat.format(data.totalPay),
          Icons.payments,
          Colors.orange),
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
            const SizedBox(width: 8),
            Expanded(
                child: KpiCard(
                    compact: true,
                    title: cards[3].title,
                    value: cards[3].value,
                    icon: cards[3].icon,
                    color: cards[3].color)),
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

  Widget _buildDesktopEmployeeTable(
    BuildContext context,
    EmployeeReportData data,
  ) {
    if (data.entries.isEmpty) return _buildEmptyState(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              '${data.entries.length} employees',
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
                      DataColumn(label: Text('Employee')),
                      DataColumn(label: Text('Days In'), numeric: true),
                      DataColumn(label: Text('Days Out'), numeric: true),
                      DataColumn(label: Text('Base Salary'), numeric: true),
                      DataColumn(label: Text('Incentive'), numeric: true),
                      DataColumn(label: Text('Total Pay'), numeric: true),
                    ],
                    rows: data.entries
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

  DataRow _buildDataRow(BuildContext context, EmployeeReportEntry entry) {
    return DataRow(
      cells: [
        DataCell(Text(
          entry.employee.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        )),
        DataCell(Text('${entry.daysPresent}')),
        DataCell(Text('${entry.daysOut}')),
        DataCell(Text(_currencyFormat.format(entry.baseSalary))),
        DataCell(Text(_currencyFormat.format(entry.incentiveAmount))),
        DataCell(Text(
          _currencyFormat.format(entry.totalPay),
          style: const TextStyle(fontWeight: FontWeight.w600),
        )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile: card list
  // ---------------------------------------------------------------------------

  Widget _buildMobileEmployeeList(
    BuildContext context,
    EmployeeReportData data,
  ) {
    if (data.entries.isEmpty) return _buildEmptyState(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${data.entries.length} employees',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        ...data.entries.map((e) => _buildMobileEmployeeCard(context, e)),
      ],
    );
  }

  Widget _buildMobileEmployeeCard(
    BuildContext context,
    EmployeeReportEntry entry,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.employee.name,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _currencyFormat.format(entry.totalPay),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MobileStatChip(
                  icon: Icons.check_circle,
                  label: '${entry.daysPresent} In',
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _MobileStatChip(
                  icon: Icons.cancel,
                  label: '${entry.daysOut} Out',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Base: ${_currencyFormat.format(entry.baseSalary)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Incentive: ${_currencyFormat.format(entry.incentiveAmount)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
              Icon(Icons.badge,
                  size: 48, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No employees found.',
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

class _MobileStatChip extends StatelessWidget {
  const _MobileStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
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
