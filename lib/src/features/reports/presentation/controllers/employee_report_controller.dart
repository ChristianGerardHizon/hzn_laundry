import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../employees/data/repositories/employee_attendance_repository.dart';
import '../../../employees/data/repositories/employee_deduction_repository.dart';
import '../../../employees/data/repositories/employee_repository.dart';
import '../../../employees/domain/employee.dart';
import '../../../employees/domain/employee_attendance.dart';
import '../../../employees/domain/employee_deduction.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../settings/data/repositories/branch_repository.dart';
import '../../../settings/data/repositories/incentive_tier_repository.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/domain/incentive_tier.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/incentive_calculator.dart';
import 'employee_report_date_range_controller.dart';
import 'salary_month_controller.dart';

part 'employee_report_controller.g.dart';

/// Combined report data for one employee.
class EmployeeReportEntry {
  const EmployeeReportEntry({
    required this.employee,
    required this.daysPresent,
    required this.daysOut,
    required this.totalDaysInRange,
    required this.incentiveAmount,
    required this.baseSalary,
    this.deductionAmount = 0,
    this.deductions = const [],
  });

  final Employee employee;
  final int daysPresent;
  final int daysOut;
  final int totalDaysInRange;
  final num incentiveAmount;
  final num baseSalary;

  /// Total deduction amount for this period.
  final num deductionAmount;

  /// List of applicable deductions for this period.
  final List<EmployeeDeduction> deductions;

  num get totalPay => baseSalary + incentiveAmount - deductionAmount;
}

/// Breakdown of incentive for a single day.
class DailyIncentiveEntry {
  const DailyIncentiveEntry({
    required this.date,
    required this.serviceRevenue,
    required this.dayIncentive,
    required this.presentEmployees,
    required this.perEmployeeIncentive,
    required this.orderBreakdown,
  });

  final DateTime date;
  final num serviceRevenue;
  final num dayIncentive;
  final List<Employee> presentEmployees;
  final num perEmployeeIncentive;
  final List<OrderIncentiveEntry> orderBreakdown;
}

/// Breakdown of a single order's contribution to incentive.
class OrderIncentiveEntry {
  const OrderIncentiveEntry({
    required this.receiptNumber,
    required this.customerName,
    required this.servicePrice,
    required this.incentive,
    required this.orderStatus,
  });

  final String receiptNumber;
  final String? customerName;
  final num servicePrice;
  final num incentive;
  final String orderStatus;
}

/// Fetches employee report data for the selected date range.
@riverpod
Future<EmployeeReportData> employeeReport(Ref ref) async {
  final dateRange = ref.watch(employeeReportDateRangeControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  return _buildEmployeeReport(ref, dateRange: dateRange, branchId: branchId);
}

/// Fetches salary report data for the selected month and period.
@riverpod
Future<EmployeeReportData> salaryReport(Ref ref) async {
  final monthController = ref.watch(salaryMonthControllerProvider.notifier);
  final period = ref.watch(salaryPeriodControllerProvider);
  final dateRange = monthController.dateRangeForPeriod(period);
  final branchId = ref.watch(currentBranchIdProvider);
  // Watch the month state so provider rebuilds on change
  ref.watch(salaryMonthControllerProvider);
  return _buildEmployeeReport(
    ref,
    dateRange: dateRange,
    branchId: branchId,
    period: period,
  );
}

/// Shared logic for building employee report data.
Future<EmployeeReportData> _buildEmployeeReport(
  Ref ref, {
  required DateTimeRange dateRange,
  required String? branchId,
  SalaryPeriod period = SalaryPeriod.fullMonth,
}) async {
  final employeeRepo = ref.read(employeeRepositoryProvider);
  final attendanceRepo = ref.read(employeeAttendanceRepositoryProvider);
  final deductionRepo = ref.read(employeeDeductionRepositoryProvider);
  final salesRepo = ref.read(salesRepositoryProvider);
  final branchRepo = ref.read(branchRepositoryProvider);
  final tierRepo = ref.read(incentiveTierRepositoryProvider);

  // Fetch employees, branch, sale service totals (view), attendance, and tiers
  // all in parallel
  final results = await Future.wait([
    employeeRepo.fetchAll(), // 0
    if (branchId != null) branchRepo.fetchOne(branchId), // 1 (optional)
    salesRepo.getSaleServiceTotals(
      startDate: dateRange.start,
      endDate: dateRange.end,
      branchId: branchId,
      filterByProcessedDate: true,
    ), // 1 or 2
    attendanceRepo.fetchAllInDateRange(
      startDate: dateRange.start,
      endDate: dateRange.end,
    ), // 2 or 3
    if (branchId != null) tierRepo.fetchForBranch(branchId), // 3 or 4
  ]);

  // Unpack results
  int idx = 0;
  final employees = (results[idx++] as Either).fold(
    (failure) => <Employee>[],
    (list) => list as List<Employee>,
  );

  Branch? branch;
  if (branchId != null) {
    branch = (results[idx++] as Either).fold((_) => null, (b) => b as Branch);
  }

  // Sale service totals from the view (1 query, no N+1)
  final saleRecords = (results[idx++] as Either).fold(
    (failure) => <dynamic>[],
    (list) => list as List<dynamic>,
  );

  // All attendance in date range (1 query, no N+1)
  final allAttendance = (results[idx++] as Either).fold(
    (failure) => <EmployeeAttendance>[],
    (list) => list as List<EmployeeAttendance>,
  );

  // Incentive tiers for this branch
  List<IncentiveTier> incentiveTiers = [];
  if (branchId != null) {
    incentiveTiers = (results[idx++] as Either).fold(
      (failure) => <IncentiveTier>[],
      (list) => list as List<IncentiveTier>,
    );
  }

  // Fallback: use legacy flat fields if no tiers configured
  final incentiveRate = branch?.incentiveAmount ?? 5;
  final perServicePrice = branch?.incentivePerServiceItems ?? 200;

  // Process sale service totals from the view
  final dailyServiceRevenue = <DateTime, num>{};
  final dailyOrderBreakdown = <DateTime, List<OrderIncentiveEntry>>{};
  for (final record in saleRecords) {
    // Use `processedDate` as the incentive date — stamped by the hook when
    // orderStatus first transitions to ready/pickedUp. Falls back to updated.
    final processedStr = record.getStringValue('processedDate');
    final fallbackStr = record.getStringValue('updated');
    final saleDate = parseToLocal(processedStr) ??
        parseToLocal(fallbackStr) ??
        DateTime.now();
    final day = DateTime(saleDate.year, saleDate.month, saleDate.day);

    final orderStatus = record.getStringValue('orderStatus');
    // Processing orders don't count toward incentives
    if (orderStatus == 'processing') continue;

    final saleServiceTotal =
        (record.data['serviceTotalAmount'] as num?) ?? 0;
    if (saleServiceTotal <= 0) continue;

    dailyServiceRevenue[day] =
        (dailyServiceRevenue[day] ?? 0) + saleServiceTotal;

    // Calculate incentive per order using custom tiers or legacy flat rate
    final orderIncentive = calculateIncentive(
      saleServiceTotal,
      incentiveTiers,
      incentiveRate,
      perServicePrice,
    );

    final receiptNumber = record.getStringValue('receiptNumber');
    final customerName = record.getStringValue('customerName');

    dailyOrderBreakdown.putIfAbsent(day, () => []).add(
      OrderIncentiveEntry(
        receiptNumber: receiptNumber,
        customerName: customerName.isEmpty ? null : customerName,
        servicePrice: saleServiceTotal,
        incentive: orderIncentive,
        orderStatus: orderStatus,
      ),
    );
  }

  // Group attendance by employee (already filtered by date range from query)
  final allAttendanceByEmployee = <String, List<EmployeeAttendance>>{};
  for (final a in allAttendance) {
    allAttendanceByEmployee.putIfAbsent(a.employee, () => []).add(a);
  }

  // Build a map of day -> set of present employee IDs
  final dailyPresentIds = <DateTime, Set<String>>{};
  for (final employee in employees) {
    final attendance = allAttendanceByEmployee[employee.id] ?? [];
    for (final a in attendance) {
      if (a.isPresent) {
        final day = DateTime(a.date.year, a.date.month, a.date.day);
        dailyPresentIds.putIfAbsent(day, () => {}).add(employee.id);
      }
    }
  }

  // Employee ID -> map to build lookup
  final employeeMap = {for (final e in employees) e.id: e};

  // Calculate per-employee incentive by iterating each day
  final employeeIncentives = <String, num>{};
  final dailyBreakdown = <DailyIncentiveEntry>[];

  // Iterate over all days in the range
  final startDay = DateTime(
      dateRange.start.year, dateRange.start.month, dateRange.start.day);
  final endDay =
      DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);

  var currentDay = startDay;
  num totalServicePrice = 0;

  while (!currentDay.isAfter(endDay)) {
    final revenue = dailyServiceRevenue[currentDay] ?? 0;
    totalServicePrice += revenue;

    final presentIds = dailyPresentIds[currentDay] ?? {};
    final presentCount = presentIds.length;

    // Calculate day's incentive as sum of per-order incentives
    final orders = dailyOrderBreakdown[currentDay] ?? [];
    num dayIncentive = 0;
    for (final order in orders) {
      dayIncentive += order.incentive;
    }
    num perEmployee = 0;
    if (presentCount > 0 && dayIncentive > 0) {
      perEmployee = dayIncentive / presentCount;
    }

    // Accumulate per-employee
    for (final empId in presentIds) {
      employeeIncentives[empId] =
          (employeeIncentives[empId] ?? 0) + perEmployee;
    }

    // Only add to breakdown if there was revenue or attendance
    if (revenue > 0 || presentCount > 0) {
      dailyBreakdown.add(DailyIncentiveEntry(
        date: currentDay,
        serviceRevenue: revenue,
        dayIncentive: dayIncentive,
        presentEmployees:
            presentIds.map((id) => employeeMap[id]!).toList(),
        perEmployeeIncentive: perEmployee,
        orderBreakdown: dailyOrderBreakdown[currentDay] ?? [],
      ));
    }

    currentDay = currentDay.add(const Duration(days: 1));
  }

  // Calculate total days in range
  final totalDays = endDay.difference(startDay).inDays + 1;

  // Fetch deductions for all employees in parallel
  final deductionResults = await Future.wait(
    employees.map((e) => deductionRepo.fetchForEmployee(e.id)),
  );

  // Map employee ID -> applicable deductions for this month
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

  // For bi-monthly periods, base salary and deductions are halved
  final isBiMonthly = period != SalaryPeriod.fullMonth;
  final salaryDivisor = isBiMonthly ? 2 : 1;

  // Build final entries
  final entries = employees.map((employee) {
    final attendance = allAttendanceByEmployee[employee.id] ?? [];
    final daysPresent = attendance.where((a) => a.isPresent).length;
    final daysOut = attendance.where((a) => !a.isPresent).length;

    // Calculate total deductions (halved for bi-monthly)
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
      incentiveAmount: employeeIncentives[employee.id] ?? 0,
      baseSalary: employee.baseSalary / salaryDivisor,
      deductionAmount: totalDeduction / salaryDivisor,
      deductions: deductions,
    );
  }).toList();

  return EmployeeReportData(
    entries: entries,
    dailyBreakdown: dailyBreakdown,
    totalServicePrice: totalServicePrice,
    incentiveRate: incentiveRate,
    perServicePrice: perServicePrice,
    branch: branch,
    incentiveTiers: incentiveTiers,
  );
}


/// Holds the full employee report data.
class EmployeeReportData {
  const EmployeeReportData({
    required this.entries,
    required this.dailyBreakdown,
    required this.totalServicePrice,
    required this.incentiveRate,
    required this.perServicePrice,
    this.branch,
    this.incentiveTiers = const [],
  });

  final List<EmployeeReportEntry> entries;
  final List<DailyIncentiveEntry> dailyBreakdown;
  final num totalServicePrice;
  final num incentiveRate;
  final num perServicePrice;
  final Branch? branch;
  final List<IncentiveTier> incentiveTiers;

  int get totalPresent => entries.fold(0, (sum, e) => sum + e.daysPresent);
  int get totalOut => entries.fold(0, (sum, e) => sum + e.daysOut);
  num get totalIncentive =>
      entries.fold<num>(0, (sum, e) => sum + e.incentiveAmount);
  num get totalBaseSalary =>
      entries.fold<num>(0, (sum, e) => sum + e.baseSalary);
  num get totalDeductions =>
      entries.fold<num>(0, (sum, e) => sum + e.deductionAmount);
  num get totalPay => entries.fold<num>(0, (sum, e) => sum + e.totalPay);

  /// Returns a copy with a filtered subset of entries.
  EmployeeReportData copyWithFilteredEntries(List<EmployeeReportEntry> filtered) {
    return EmployeeReportData(
      entries: filtered,
      dailyBreakdown: dailyBreakdown,
      totalServicePrice: totalServicePrice,
      incentiveRate: incentiveRate,
      perServicePrice: perServicePrice,
      branch: branch,
      incentiveTiers: incentiveTiers,
    );
  }
}
