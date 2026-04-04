import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../employees/data/repositories/employee_attendance_repository.dart';
import '../../../employees/data/repositories/employee_repository.dart';
import '../../../employees/domain/employee.dart';
import '../../../employees/domain/employee_attendance.dart';

part 'attendance_report_controller.g.dart';

/// Manages the date range for the attendance report tab.
@Riverpod(keepAlive: true)
class AttendanceReportDateRangeController
    extends _$AttendanceReportDateRangeController {
  @override
  DateTimeRange build() {
    final now = DateTime.now();
    // Default to current month
    final firstDay = DateTime(now.year, now.month);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    return DateTimeRange(start: firstDay, end: lastDay);
  }

  void setRange(DateTimeRange range) {
    state = range;
  }
}

/// Manages the selected employee filter for the attendance report.
@Riverpod(keepAlive: true)
class AttendanceReportEmployeeFilter
    extends _$AttendanceReportEmployeeFilter {
  @override
  String? build() => null; // null = all employees

  void setEmployee(String? employeeId) {
    state = employeeId;
  }
}

/// Data class for a single employee's attendance summary.
class EmployeeAttendanceSummary {
  const EmployeeAttendanceSummary({
    required this.employee,
    required this.daysPresent,
    required this.daysOut,
    required this.totalDays,
    required this.attendanceByDate,
  });

  final Employee employee;
  final int daysPresent;
  final int daysOut;
  final int totalDays;

  /// Map of date (normalized to midnight) -> isPresent
  final Map<DateTime, bool> attendanceByDate;

  double get attendanceRate =>
      totalDays > 0 ? (daysPresent / totalDays) * 100 : 0;
}

/// Holds the full attendance report data.
class AttendanceReportData {
  const AttendanceReportData({
    required this.summaries,
    required this.allAttendance,
    required this.dateRange,
  });

  final List<EmployeeAttendanceSummary> summaries;
  final List<EmployeeAttendance> allAttendance;
  final DateTimeRange dateRange;

  int get totalPresent =>
      summaries.fold(0, (sum, s) => sum + s.daysPresent);
  int get totalOut => summaries.fold(0, (sum, s) => sum + s.daysOut);
  int get totalDays =>
      summaries.isEmpty ? 0 : summaries.first.totalDays;
  double get overallAttendanceRate {
    if (summaries.isEmpty) return 0;
    final totalP = totalPresent;
    final totalExpected = summaries.length * totalDays;
    return totalExpected > 0 ? (totalP / totalExpected) * 100 : 0;
  }
}

/// Fetches attendance report data for the selected date range and employee
/// filter.
@riverpod
Future<AttendanceReportData> attendanceReport(Ref ref) async {
  final dateRange = ref.watch(attendanceReportDateRangeControllerProvider);
  final employeeFilter = ref.watch(attendanceReportEmployeeFilterProvider);

  final employeeRepo = ref.read(employeeRepositoryProvider);
  final attendanceRepo = ref.read(employeeAttendanceRepositoryProvider);

  // Fetch employees and attendance in parallel
  final results = await Future.wait([
    employeeRepo.fetchAll(),
    attendanceRepo.fetchAllInDateRange(
      startDate: dateRange.start,
      endDate: dateRange.end,
    ),
  ]);

  final employees = (results[0] as Either).fold(
    (_) => <Employee>[],
    (list) => list as List<Employee>,
  );

  final allAttendance = (results[1] as Either).fold(
    (_) => <EmployeeAttendance>[],
    (list) => list as List<EmployeeAttendance>,
  );

  // Filter employees if a specific one is selected
  final filteredEmployees = employeeFilter != null
      ? employees.where((e) => e.id == employeeFilter).toList()
      : employees;

  // Group attendance by employee
  final attendanceByEmployee = <String, List<EmployeeAttendance>>{};
  for (final a in allAttendance) {
    attendanceByEmployee.putIfAbsent(a.employee, () => []).add(a);
  }

  // Calculate total days in range
  final startDay = DateTime(
      dateRange.start.year, dateRange.start.month, dateRange.start.day);
  final endDay =
      DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
  final totalDays = endDay.difference(startDay).inDays + 1;

  // Build summaries
  final summaries = filteredEmployees.map((employee) {
    final attendance = attendanceByEmployee[employee.id] ?? [];
    final daysPresent = attendance.where((a) => a.isPresent).length;
    final daysOut = attendance.where((a) => !a.isPresent).length;

    // Build date -> isPresent map
    final attendanceByDate = <DateTime, bool>{};
    for (final a in attendance) {
      final day = DateTime(a.date.year, a.date.month, a.date.day);
      attendanceByDate[day] = a.isPresent;
    }

    return EmployeeAttendanceSummary(
      employee: employee,
      daysPresent: daysPresent,
      daysOut: daysOut,
      totalDays: totalDays,
      attendanceByDate: attendanceByDate,
    );
  }).toList();

  // Filter allAttendance for the selected employee if needed
  final filteredAttendance = employeeFilter != null
      ? allAttendance.where((a) => a.employee == employeeFilter).toList()
      : allAttendance;

  return AttendanceReportData(
    summaries: summaries,
    allAttendance: filteredAttendance,
    dateRange: dateRange,
  );
}
