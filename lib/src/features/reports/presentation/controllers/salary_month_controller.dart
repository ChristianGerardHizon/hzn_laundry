import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'salary_month_controller.g.dart';

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
}
