import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../controllers/employee_report_controller.dart';
import '../../controllers/salary_month_controller.dart';

/// View displaying employee salary breakdown by month.
class SalaryReportView extends HookConsumerWidget {
  const SalaryReportView({super.key});

  static final _monthFormat = DateFormat('MMMM yyyy');
  static final _currencyFormat =
      NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salaryReportProvider);
    final selectedMonth = ref.watch(salaryMonthControllerProvider);

    return reportAsync.when(
      data: (data) => _buildContent(context, ref, data, selectedMonth),
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
    DateTime selectedMonth,
  ) {
    final isMobile = Breakpoints.isMobile(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(salaryReportProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(context, ref, selectedMonth),
            const SizedBox(height: 12),
            _buildKpiSection(context, data, isMobile),
            const SizedBox(height: 16),
            if (data.entries.isEmpty)
              _buildEmptyState(context)
            else ...[
              if (isMobile)
                _buildMobileSalaryList(context, data)
              else
                _buildDesktopSalaryTable(context, data),
              const SizedBox(height: 16),
              _buildTotalsCard(context, data),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Month selector
  // ---------------------------------------------------------------------------

  Widget _buildMonthSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final prev = DateTime(selectedMonth.year, selectedMonth.month - 1);
            ref.read(salaryMonthControllerProvider.notifier).setMonth(prev);
          },
          tooltip: 'Previous month',
        ),
        PopupMenuButton<DateTime>(
          onSelected: (month) {
            ref.read(salaryMonthControllerProvider.notifier).setMonth(month);
          },
          itemBuilder: (context) {
            final now = DateTime.now();
            // Show last 12 months
            return List.generate(12, (i) {
              final month = DateTime(now.year, now.month - i);
              return PopupMenuItem<DateTime>(
                value: month,
                child: Text(
                  _monthFormat.format(month),
                  style: month.year == selectedMonth.year &&
                          month.month == selectedMonth.month
                      ? theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )
                      : theme.textTheme.bodyMedium,
                ),
              );
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  _monthFormat.format(selectedMonth),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down,
                    size: 20, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final next = DateTime(selectedMonth.year, selectedMonth.month + 1);
            // Don't go past current month
            final now = DateTime.now();
            if (next.year < now.year ||
                (next.year == now.year && next.month <= now.month)) {
              ref.read(salaryMonthControllerProvider.notifier).setMonth(next);
            }
          },
          tooltip: 'Next month',
        ),
      ],
    );
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
        'Total Base Salary',
        _currencyFormat.format(data.totalBaseSalary),
        Icons.account_balance_wallet,
        Colors.blue,
      ),
      _KpiData(
        'Total Incentive',
        _currencyFormat.format(data.totalIncentive),
        Icons.trending_up,
        Colors.green,
      ),
      _KpiData(
        'Total Payroll',
        _currencyFormat.format(data.totalPay),
        Icons.payments,
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
  // Desktop: DataTable
  // ---------------------------------------------------------------------------

  Widget _buildDesktopSalaryTable(
    BuildContext context,
    EmployeeReportData data,
  ) {
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
                      DataColumn(
                          label: Text('Base Salary'), numeric: true),
                      DataColumn(
                          label: Text('Incentive'), numeric: true),
                      DataColumn(
                          label: Text('Total Pay'), numeric: true),
                    ],
                    rows: data.entries
                        .map((e) => DataRow(
                              cells: [
                                DataCell(Text(
                                  e.employee.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                )),
                                DataCell(Text('${e.daysPresent}')),
                                DataCell(Text(_currencyFormat
                                    .format(e.baseSalary))),
                                DataCell(Text(_currencyFormat
                                    .format(e.incentiveAmount))),
                                DataCell(Text(
                                  _currencyFormat.format(e.totalPay),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                )),
                              ],
                            ))
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

  // ---------------------------------------------------------------------------
  // Mobile: card list
  // ---------------------------------------------------------------------------

  Widget _buildMobileSalaryList(
    BuildContext context,
    EmployeeReportData data,
  ) {
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
        ...data.entries.map((e) => _buildMobileSalaryCard(context, e)),
      ],
    );
  }

  Widget _buildMobileSalaryCard(
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
            _SalaryBreakdownRow(
              label: 'Base Salary',
              value: _currencyFormat.format(entry.baseSalary),
              theme: theme,
            ),
            _SalaryBreakdownRow(
              label: 'Incentive (${entry.daysPresent} days In)',
              value: _currencyFormat.format(entry.incentiveAmount),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Totals card
  // ---------------------------------------------------------------------------

  Widget _buildTotalsCard(BuildContext context, EmployeeReportData data) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TotalRow(
              label: 'Total Base Salary',
              value: _currencyFormat.format(data.totalBaseSalary),
              theme: theme,
            ),
            _TotalRow(
              label: 'Total Incentive',
              value: _currencyFormat.format(data.totalIncentive),
              theme: theme,
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Payroll',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _currencyFormat.format(data.totalPay),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
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
              Icon(Icons.account_balance_wallet,
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

class _SalaryBreakdownRow extends StatelessWidget {
  const _SalaryBreakdownRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
