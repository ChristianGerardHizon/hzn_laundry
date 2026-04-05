import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../../../employees/domain/deduction_value_type.dart';
import '../../../../employees/domain/employee_deduction.dart';
import '../../../../employees/presentation/controllers/employees_controller.dart';
import '../../controllers/employee_report_controller.dart';
import '../../controllers/salary_month_controller.dart';

/// View displaying employee salary breakdown by month with bi-monthly support.
class SalaryReportView extends HookConsumerWidget {
  const SalaryReportView({super.key});

  static final _currencyFormat =
      NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salaryReportProvider);
    final selectedMonth = ref.watch(salaryMonthControllerProvider);
    final selectedPeriod = ref.watch(salaryPeriodControllerProvider);
    final selectedEmployee = ref.watch(salaryEmployeeFilterProvider);
    final employeesAsync = ref.watch(employeesControllerProvider);

    return reportAsync.when(
      data: (data) => _buildContent(
        context,
        ref,
        data,
        selectedMonth,
        selectedPeriod,
        selectedEmployee,
        employeesAsync,
      ),
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
    SalaryPeriod selectedPeriod,
    String? selectedEmployee,
    AsyncValue employeesAsync,
  ) {
    final isMobile = Breakpoints.isMobile(context);

    // Filter entries by selected employee
    final filteredData = selectedEmployee != null
        ? data.copyWithFilteredEntries(
            data.entries
                .where((e) => e.employee.id == selectedEmployee)
                .toList(),
          )
        : data;

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
            const SizedBox(height: 8),
            _buildFiltersRow(
              context,
              ref,
              selectedMonth,
              selectedPeriod,
              selectedEmployee,
              employeesAsync,
              isMobile,
            ),
            const SizedBox(height: 12),
            _buildKpiSection(context, filteredData, isMobile),
            const SizedBox(height: 16),
            if (filteredData.entries.isEmpty)
              _buildEmptyState(context)
            else ...[
              ...filteredData.entries.map((e) => _EmployeeBreakdownCard(
                    entry: e,
                    period: selectedPeriod,
                    currencyFormat: _currencyFormat,
                  )),
              const SizedBox(height: 16),
              _buildTotalsCard(context, filteredData),
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
        // Month dropdown
        PopupMenuButton<int>(
          onSelected: (month) {
            ref
                .read(salaryMonthControllerProvider.notifier)
                .setMonth(DateTime(selectedMonth.year, month));
          },
          itemBuilder: (context) {
            final now = DateTime.now();
            return List.generate(12, (i) {
              final m = i + 1;
              final isFuture = selectedMonth.year == now.year && m > now.month;
              final isSelected = m == selectedMonth.month;
              return PopupMenuItem<int>(
                value: m,
                enabled: !isFuture,
                child: Text(
                  DateFormat('MMMM').format(DateTime(2000, m)),
                  style: isSelected
                      ? theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )
                      : isFuture
                          ? theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.38),
                            )
                          : theme.textTheme.bodyMedium,
                ),
              );
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM').format(selectedMonth),
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
        const SizedBox(width: 8),
        // Year dropdown
        PopupMenuButton<int>(
          onSelected: (year) {
            ref
                .read(salaryMonthControllerProvider.notifier)
                .setMonth(DateTime(year, selectedMonth.month));
          },
          itemBuilder: (context) {
            final now = DateTime.now();
            return List.generate(5, (i) {
              final year = now.year - i;
              final isSelected = year == selectedMonth.year;
              return PopupMenuItem<int>(
                value: year,
                child: Text(
                  '$year',
                  style: isSelected
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
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${selectedMonth.year}',
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
  // Filters row: period selector + employee filter
  // ---------------------------------------------------------------------------

  Widget _buildFiltersRow(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
    SalaryPeriod selectedPeriod,
    String? selectedEmployee,
    AsyncValue employeesAsync,
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(context, ref, selectedMonth, selectedPeriod),
          const SizedBox(height: 8),
          _buildEmployeeFilter(context, ref, selectedEmployee, employeesAsync),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child:
              _buildPeriodSelector(context, ref, selectedMonth, selectedPeriod),
        ),
        const SizedBox(width: 12),
        _buildEmployeeFilter(context, ref, selectedEmployee, employeesAsync),
      ],
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
    SalaryPeriod selectedPeriod,
  ) {
    return SegmentedButton<SalaryPeriod>(
      segments: SalaryPeriod.values
          .map((p) => ButtonSegment(
                value: p,
                label: Text(
                  p.label(selectedMonth),
                  style: const TextStyle(fontSize: 12),
                ),
              ))
          .toList(),
      selected: {selectedPeriod},
      onSelectionChanged: (selected) {
        ref
            .read(salaryPeriodControllerProvider.notifier)
            .setPeriod(selected.first);
      },
      showSelectedIcon: false,
    );
  }

  Widget _buildEmployeeFilter(
    BuildContext context,
    WidgetRef ref,
    String? selectedEmployee,
    AsyncValue employeesAsync,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: employeesAsync.when(
        data: (employees) => DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: selectedEmployee,
            isDense: true,
            icon: Icon(Icons.arrow_drop_down,
                size: 20, color: theme.colorScheme.onSurfaceVariant),
            hint: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('All Employees', style: theme.textTheme.titleSmall),
              ],
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('All Employees', style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
              ...employees.map((e) => DropdownMenuItem<String?>(
                    value: e.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(e.name, style: theme.textTheme.titleSmall),
                      ],
                    ),
                  )),
            ],
            onChanged: (value) {
              ref
                  .read(salaryEmployeeFilterProvider.notifier)
                  .setEmployee(value);
            },
          ),
        ),
        loading: () => const SizedBox(
          height: 36,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, __) => Text('Error', style: theme.textTheme.bodySmall),
      ),
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
        'Base Salary',
        _currencyFormat.format(data.totalBaseSalary),
        Icons.account_balance_wallet,
        Colors.blue,
      ),
      _KpiData(
        'Incentive',
        _currencyFormat.format(data.totalIncentive),
        Icons.trending_up,
        Colors.green,
      ),
      _KpiData(
        'Deductions',
        _currencyFormat.format(data.totalDeductions),
        Icons.money_off,
        Colors.red,
      ),
      _KpiData(
        'Net Payroll',
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
            _TotalRow(
              label: 'Total Deductions',
              value: '-${_currencyFormat.format(data.totalDeductions)}',
              theme: theme,
              valueColor: Colors.red,
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Payroll',
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

// =============================================================================
// Employee breakdown card (expandable)
// =============================================================================

class _EmployeeBreakdownCard extends HookWidget {
  const _EmployeeBreakdownCard({
    required this.entry,
    required this.period,
    required this.currencyFormat,
  });

  final EmployeeReportEntry entry;
  final SalaryPeriod period;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    final theme = Theme.of(context);
    final e = entry;
    final isBiMonthly = period != SalaryPeriod.fullMonth;

    // For sublabel display: the full-month base salary
    final fullBaseSalary = isBiMonthly ? e.baseSalary * 2 : e.baseSalary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => isExpanded.value = !isExpanded.value,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: name + net pay
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.employee.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${e.daysPresent} days present',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(e.totalPay),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded.value
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              // Summary row (always visible)
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _MiniChip(
                    label: 'Base: ${currencyFormat.format(e.baseSalary)}',
                    color: Colors.blue,
                  ),
                  if (e.incentiveAmount > 0)
                    _MiniChip(
                      label:
                          '+${currencyFormat.format(e.incentiveAmount)}',
                      color: Colors.green,
                    ),
                  if (e.deductionAmount > 0)
                    _MiniChip(
                      label:
                          '-${currencyFormat.format(e.deductionAmount)}',
                      color: Colors.red,
                    ),
                ],
              ),

              // Expanded breakdown
              if (isExpanded.value) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Earnings section
                Text(
                  'Earnings',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                _BreakdownRow(
                  label: 'Base Salary',
                  sublabel: isBiMonthly
                      ? '${currencyFormat.format(fullBaseSalary)} ÷ 2'
                      : null,
                  value: currencyFormat.format(e.baseSalary),
                  theme: theme,
                ),
                if (e.incentiveAmount > 0)
                  _BreakdownRow(
                    label: 'Incentive (${e.daysPresent} days)',
                    value: currencyFormat.format(e.incentiveAmount),
                    theme: theme,
                    valueColor: Colors.green,
                  ),

                // Deductions section
                if (e.deductions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Deductions',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...e.deductions.map((d) {
                    final fullAmount = d.computeAmount(e.employee.baseSalary);
                    final amount = isBiMonthly ? fullAmount / 2 : fullAmount;
                    return _BreakdownRow(
                      label: d.displayName,
                      sublabel: _deductionSublabel(d, e.employee.baseSalary),
                      value: '-${currencyFormat.format(amount)}',
                      theme: theme,
                      valueColor: Colors.red,
                    );
                  }),
                ],

                // Net pay
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Pay',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      currencyFormat.format(e.totalPay),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _deductionSublabel(EmployeeDeduction d, num baseSalary) {
    final isBiMonthly = period != SalaryPeriod.fullMonth;
    if (d.valueType == DeductionValueType.percentage) {
      final pctLabel =
          '${d.value}% of ${SalaryReportView._currencyFormat.format(baseSalary)}';
      if (isBiMonthly) {
        return '$pctLabel ÷ 2';
      }
      return pctLabel;
    }
    if (isBiMonthly) {
      return '${SalaryReportView._currencyFormat.format(d.computeAmount(baseSalary))} ÷ 2';
    }
    return null;
  }
}

// =============================================================================
// Small helper widgets
// =============================================================================

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    this.sublabel,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final String? sublabel;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w500,
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

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
