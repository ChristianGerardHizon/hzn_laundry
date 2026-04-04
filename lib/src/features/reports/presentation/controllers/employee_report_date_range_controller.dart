import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employee_report_date_range_controller.g.dart';

/// Manages the date range for the employee report tab.
@Riverpod(keepAlive: true)
class EmployeeReportDateRangeController
    extends _$EmployeeReportDateRangeController {
  @override
  DateTimeRange build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTimeRange(
      start: today.subtract(const Duration(days: 6)),
      end: today.add(const Duration(days: 1)).subtract(
            const Duration(milliseconds: 1),
          ),
    );
  }

  void setRange(DateTimeRange range) {
    state = range;
  }
}
