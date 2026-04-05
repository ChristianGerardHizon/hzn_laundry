import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'salary_month_controller.g.dart';

/// Bi-monthly period options.
enum SalaryPeriod {
  fullMonth,
  firstHalf,
  secondHalf;

  String label(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    return switch (this) {
      SalaryPeriod.fullMonth => 'Full Month',
      SalaryPeriod.firstHalf => '1st – 15th',
      SalaryPeriod.secondHalf => '16th – ${lastDay}th',
    };
  }
}

/// Manages the selected month for the salary report tab.
///
/// Stores the first day of the selected month. The date range is
/// computed as first-of-month to last-of-month.
@Riverpod(keepAlive: true)
class SalaryMonthController extends _$SalaryMonthController {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month);
  }

  /// Returns the full date range for the selected month.
  DateTimeRange get dateRange {
    final start = state;
    final end = DateTime(state.year, state.month + 1, 0, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }

  /// Returns the date range for a specific period within the month.
  DateTimeRange dateRangeForPeriod(SalaryPeriod period) {
    final month = state;
    switch (period) {
      case SalaryPeriod.fullMonth:
        return dateRange;
      case SalaryPeriod.firstHalf:
        return DateTimeRange(
          start: DateTime(month.year, month.month, 1),
          end: DateTime(month.year, month.month, 15, 23, 59, 59, 999),
        );
      case SalaryPeriod.secondHalf:
        final lastDay = DateTime(month.year, month.month + 1, 0).day;
        return DateTimeRange(
          start: DateTime(month.year, month.month, 16),
          end: DateTime(month.year, month.month, lastDay, 23, 59, 59, 999),
        );
    }
  }
}

/// Manages the selected salary period (full month, 1st half, 2nd half).
@Riverpod(keepAlive: true)
class SalaryPeriodController extends _$SalaryPeriodController {
  @override
  SalaryPeriod build() => SalaryPeriod.fullMonth;

  void setPeriod(SalaryPeriod period) {
    state = period;
  }
}

/// Manages the selected employee filter for salary report.
/// null = all employees.
@Riverpod(keepAlive: true)
class SalaryEmployeeFilter extends _$SalaryEmployeeFilter {
  @override
  String? build() => null;

  void setEmployee(String? employeeId) {
    state = employeeId;
  }
}
