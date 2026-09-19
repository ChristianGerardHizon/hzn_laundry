import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../employees/data/repositories/employee_attendance_repository.dart';
import '../../../employees/data/repositories/employee_deduction_repository.dart';
import '../../../employees/data/repositories/employee_repository.dart';
import '../../../employees/domain/employee.dart';
import '../../../employees/domain/employee_attendance.dart';
import '../../../employees/domain/employee_deduction.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'salary_month_controller.dart';

part 'employee_report_controller.g.dart';

/// Combined report data for one employee.
class EmployeeReportEntry {
  const EmployeeReportEntry({
    required this.employee,
    required this.daysPresent,
    required this.daysOut,
    required this.totalDaysInRange,
    required this.baseSalary,
    this.deductionAmount = 0,
    this.deductions = const [],
  });

  final Employee employee;
  final int daysPresent;
  final int daysOut;
  final int totalDaysInRange;
  final num baseSalary;

  /// Total deduction amount for this period.
  final num deductionAmount;

  /// List of applicable deductions for this period.
  final List<EmployeeDeduction> deductions;

  num get totalPay => baseSalary - deductionAmount;
}

/// Fetches salary report data for the selected month and period.
@riverpod
Future<EmployeeReportData> salaryReport(Ref ref) async {
  final monthController = ref.watch(salaryMonthControllerProvider.notifier);
  final period = ref.watch(salaryPeriodControllerProvider);
  final dateRange = monthController.dateRangeForPeriod(period);
  // Watch the month state so provider rebuilds on change
  ref.watch(salaryMonthControllerProvider);
  // Branch scope kept watched so salary report refreshes on branch switch.
  ref.watch(currentBranchIdProvider);
  ref.watch(currentBranchIdsFilterProvider);
  return _buildEmployeeReport(
    ref,
    dateRange: dateRange,
    period: period,
  );
}

/// Shared logic for building employee report data.
Future<EmployeeReportData> _buildEmployeeReport(
  Ref ref, {
  required DateTimeRange dateRange,
  SalaryPeriod period = SalaryPeriod.fullMonth,
}) async {
  final employeeRepo = ref.read(employeeRepositoryProvider);
  final attendanceRepo = ref.read(employeeAttendanceRepositoryProvider);
  final deductionRepo = ref.read(employeeDeductionRepositoryProvider);

  final results = await Future.wait([
    employeeRepo.fetchAll(),
    attendanceRepo.fetchAllInDateRange(
      startDate: dateRange.start,
      endDate: dateRange.end,
    ),
  ]);

  final employees = (results[0] as Either).fold(
    (failure) => <Employee>[],
    (list) => list as List<Employee>,
  );

  final allAttendance = (results[1] as Either).fold(
    (failure) => <EmployeeAttendance>[],
    (list) => list as List<EmployeeAttendance>,
  );

  final allAttendanceByEmployee = <String, List<EmployeeAttendance>>{};
  for (final a in allAttendance) {
    allAttendanceByEmployee.putIfAbsent(a.employee, () => []).add(a);
  }

  final startDay = DateTime(
      dateRange.start.year, dateRange.start.month, dateRange.start.day);
  final endDay =
      DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
  final totalDays = endDay.difference(startDay).inDays + 1;

  final deductionResults = await Future.wait(
    employees.map((e) => deductionRepo.fetchForEmployee(e.id)),
  );

  final employeeDeductions = <String, List<EmployeeDeduction>>{};
  final reportMonth = dateRange.start;
  for (var i = 0; i < employees.length; i++) {
    final deductions = deductionResults[i].fold(
      (_) => <EmployeeDeduction>[],
      (list) => list,
    );
    employeeDeductions[employees[i].id] = deductions
        .where((d) => d.isApplicableFor(reportMonth))
        .toList();
  }

  final isBiMonthly = period != SalaryPeriod.fullMonth;
  final salaryDivisor = isBiMonthly ? 2 : 1;

  final entries = employees.map((employee) {
    final attendance = allAttendanceByEmployee[employee.id] ?? [];
    final daysPresent = attendance.where((a) => a.isPresent).length;
    final daysOut = attendance.where((a) => !a.isPresent).length;

    final deductions = employeeDeductions[employee.id] ?? [];
    num totalDeduction = 0;
    for (final d in deductions) {
      totalDeduction += d.computeAmount(employee.baseSalary);
    }

    return EmployeeReportEntry(
      employee: employee,
      daysPresent: daysPresent,
      daysOut: daysOut,
      totalDaysInRange: totalDays,
      baseSalary: employee.baseSalary / salaryDivisor,
      deductionAmount: totalDeduction / salaryDivisor,
      deductions: deductions,
    );
  }).toList();

  return EmployeeReportData(entries: entries);
}

/// Holds the full employee report data.
class EmployeeReportData {
  const EmployeeReportData({
    required this.entries,
  });

  final List<EmployeeReportEntry> entries;

  int get totalPresent => entries.fold(0, (sum, e) => sum + e.daysPresent);
  int get totalOut => entries.fold(0, (sum, e) => sum + e.daysOut);
  num get totalBaseSalary =>
      entries.fold<num>(0, (sum, e) => sum + e.baseSalary);
  num get totalDeductions =>
      entries.fold<num>(0, (sum, e) => sum + e.deductionAmount);
  num get totalPay => entries.fold<num>(0, (sum, e) => sum + e.totalPay);

  /// Returns a copy with a filtered subset of entries.
  EmployeeReportData copyWithFilteredEntries(
      List<EmployeeReportEntry> filtered) {
    return EmployeeReportData(entries: filtered);
  }
}
