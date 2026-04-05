import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../dashboard/presentation/widgets/kpi_card.dart';
import '../../../../employees/presentation/controllers/employees_controller.dart';
import '../../controllers/attendance_report_controller.dart';

/// View displaying employee attendance calendar report with filters and KPIs.
class AttendanceReportView extends ConsumerWidget {
  const AttendanceReportView({super.key});

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _dayFormat = DateFormat('d');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(attendanceReportProvider);
    final dateRange = ref.watch(attendanceReportDateRangeControllerProvider);
    final selectedEmployee = ref.watch(attendanceReportEmployeeFilterProvider);
    final employeesAsync = ref.watch(employeesControllerProvider);

    return reportAsync.when(
      data: (data) => _buildContent(
        context,
        ref,
        data,
        dateRange,
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
    AttendanceReportData data,
    DateTimeRange dateRange,
    String? selectedEmployee,
    AsyncValue employeesAsync,
  ) {
    final isMobile = Breakpoints.isMobile(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(attendanceReportProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltersRow(
              context,
              ref,
              dateRange,
              selectedEmployee,
              employeesAsync,
              isMobile,
            ),
            const SizedBox(height: 12),
            _buildKpiSection(context, data, isMobile),
            const SizedBox(height: 16),
            ...data.summaries.map(
              (summary) => _buildEmployeeCalendarCard(context, summary, dateRange),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filters: date range + employee dropdown
  // ---------------------------------------------------------------------------

  Widget _buildFiltersRow(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange dateRange,
    String? selectedEmployee,
    AsyncValue employeesAsync,
    bool isMobile,
  ) {
    final children = [
      _buildDateRangeRow(context, ref, dateRange),
      if (isMobile) const SizedBox(height: 8) else const SizedBox(width: 12),
      _buildEmployeeFilter(context, ref, selectedEmployee, employeesAsync),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildDateRangeRow(context, ref, dateRange)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildEmployeeFilter(
                  context, ref, selectedEmployee, employeesAsync)),
        ],
      ),
    );
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
          children: [
            Icon(Icons.date_range,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$startStr \u2013 $endStr',
                  style: theme.textTheme.titleSmall),
            ),
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
    // Strip time component so initialDateRange stays within lastDate bounds
    final initialRange = DateTimeRange(
      start: DateUtils.dateOnly(dateRange.start),
      end: DateUtils.dateOnly(dateRange.end),
    );
    final lastDate = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: lastDate,
      initialDateRange: initialRange,
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
          .read(attendanceReportDateRangeControllerProvider.notifier)
          .setRange(DateTimeRange(start: picked.start, end: adjustedEnd));
    }
  }

  Widget _buildEmployeeFilter(
    BuildContext context,
    WidgetRef ref,
    String? selectedEmployee,
    AsyncValue employeesAsync,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: employeesAsync.when(
        data: (employees) => DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: selectedEmployee,
            isDense: true,
            isExpanded: true,
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
                    Text('All Employees',
                        style: theme.textTheme.titleSmall),
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
                  .read(attendanceReportEmployeeFilterProvider.notifier)
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
    AttendanceReportData data,
    bool isMobile,
  ) {
    final cards = [
      _KpiData('Employees', '${data.summaries.length}', Icons.badge,
          Colors.blue),
      _KpiData('Total In', '${data.totalPresent}', Icons.check_circle,
          Colors.green),
      _KpiData('Total Out', '${data.totalOut}', Icons.cancel, Colors.grey),
      _KpiData(
        'Attendance Rate',
        '${data.overallAttendanceRate.toStringAsFixed(1)}%',
        Icons.percent,
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
  // Employee calendar card
  // ---------------------------------------------------------------------------

  Widget _buildEmployeeCalendarCard(
    BuildContext context,
    EmployeeAttendanceSummary summary,
    DateTimeRange dateRange,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: employee name + stats
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.employee.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.check_circle,
                            label: '${summary.daysPresent} In',
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            icon: Icons.cancel,
                            label: '${summary.daysOut} Out',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            icon: Icons.percent,
                            label:
                                '${summary.attendanceRate.toStringAsFixed(1)}%',
                            color: _getAttendanceRateColor(
                                summary.attendanceRate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Calendar grid
            _buildCalendarGrid(context, summary, dateRange),
          ],
        ),
      ),
    );
  }

  Color _getAttendanceRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  // ---------------------------------------------------------------------------
  // Calendar grid
  // ---------------------------------------------------------------------------

  Widget _buildCalendarGrid(
    BuildContext context,
    EmployeeAttendanceSummary summary,
    DateTimeRange dateRange,
  ) {
    final theme = Theme.of(context);
    final startDay = DateTime(
        dateRange.start.year, dateRange.start.month, dateRange.start.day);
    final endDay =
        DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);

    // Group days by month
    final monthGroups = <DateTime, List<DateTime>>{};
    var current = startDay;
    while (!current.isAfter(endDay)) {
      final monthKey = DateTime(current.year, current.month);
      monthGroups.putIfAbsent(monthKey, () => []).add(current);
      current = current.add(const Duration(days: 1));
    }

    return Column(
      children: monthGroups.entries.map((entry) {
        return _buildMonthCalendar(
          context,
          theme,
          entry.key,
          entry.value,
          summary.attendanceByDate,
          startDay,
          endDay,
        );
      }).toList(),
    );
  }

  Widget _buildMonthCalendar(
    BuildContext context,
    ThemeData theme,
    DateTime month,
    List<DateTime> daysInRange,
    Map<DateTime, bool> attendanceByDate,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final firstDayOfMonth = DateTime(month.year, month.month);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Monday = 1, Sunday = 7
    final startWeekday = firstDayOfMonth.weekday;
    // Offset: how many blank cells before the 1st
    final leadingBlanks = startWeekday - 1;

    final totalCells = leadingBlanks + lastDayOfMonth.day;
    final rows = (totalCells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text(
            _monthYearFormat.format(month),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        // Weekday headers
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        // Calendar grid rows
        ...List.generate(rows, (rowIndex) {
          return Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNum = cellIndex - leadingBlanks + 1;

              if (dayNum < 1 || dayNum > lastDayOfMonth.day) {
                return const Expanded(child: SizedBox(height: 36));
              }

              final day = DateTime(month.year, month.month, dayNum);
              final isInRange = !day.isBefore(rangeStart) && !day.isAfter(rangeEnd);
              final attendance = attendanceByDate[day];

              return Expanded(
                child: _buildDayCell(
                  context,
                  theme,
                  day,
                  isInRange,
                  attendance,
                ),
              );
            }),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    ThemeData theme,
    DateTime day,
    bool isInRange,
    bool? attendance,
  ) {
    Color? bgColor;
    Color textColor = theme.colorScheme.onSurface;

    if (!isInRange) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.25);
    } else if (attendance == true) {
      bgColor = Colors.green.withValues(alpha: 0.2);
      textColor = Colors.green.shade800;
    } else if (attendance == false) {
      bgColor = Colors.red.withValues(alpha: 0.15);
      textColor = Colors.red.shade700;
    }

    // Today highlight
    final now = DateTime.now();
    final isToday = day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;

    return Container(
      height: 36,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: isToday
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          _dayFormat.format(day),
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight:
                isToday || attendance != null ? FontWeight.w600 : null,
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

class _StatChip extends StatelessWidget {
  const _StatChip({
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
