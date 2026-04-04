import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../employees/data/repositories/employee_attendance_repository.dart';
import '../../../employees/data/repositories/employee_repository.dart';
import '../../../employees/domain/employee.dart';
import '../../../employees/domain/employee_attendance.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../settings/data/repositories/branch_repository.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
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
  });

  final Employee employee;
  final int daysPresent;
  final int daysOut;
  final int totalDaysInRange;
  final num incentiveAmount;
  final num baseSalary;

  num get totalPay => baseSalary + incentiveAmount;
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

/// Fetches salary report data for the selected month.
@riverpod
Future<EmployeeReportData> salaryReport(Ref ref) async {
  final monthController = ref.watch(salaryMonthControllerProvider.notifier);
  final dateRange = monthController.dateRange;
  final branchId = ref.watch(currentBranchIdProvider);
  // Watch the month state so provider rebuilds on change
  ref.watch(salaryMonthControllerProvider);
  return _buildEmployeeReport(ref, dateRange: dateRange, branchId: branchId);
}

/// Shared logic for building employee report data.
Future<EmployeeReportData> _buildEmployeeReport(
  Ref ref, {
  required DateTimeRange dateRange,
  required String? branchId,
}) async {
  final employeeRepo = ref.read(employeeRepositoryProvider);
  final attendanceRepo = ref.read(employeeAttendanceRepositoryProvider);
  final salesRepo = ref.read(salesRepositoryProvider);
  final branchRepo = ref.read(branchRepositoryProvider);

  // Fetch employees
  final employeesResult = await employeeRepo.fetchAll();
  final employees = employeesResult.fold(
    (failure) => <Employee>[],
    (list) => list,
  );

  // Fetch branch for incentive settings
  Branch? branch;
  if (branchId != null) {
    final branchResult = await branchRepo.fetchOne(branchId);
    branch = branchResult.fold((_) => null, (b) => b);
  }

  final incentiveRate = branch?.incentiveAmount ?? 5;
  final perServicePrice = branch?.incentivePerServiceItems ?? 200;

  // Fetch sales for date range (by postedDate)
  final salesResult = await salesRepo.getSalesForDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
    branchId: branchId,
  );
  final salesByPostedDate = salesResult.fold(
    (failure) => <Sale>[],
    (list) => list,
  );

  // Also fetch sales without postedDate that fall in range by created date.
  // Older orders may not have postedDate set.
  final allBranchSalesResult = await salesRepo.getSales(branchId: branchId);
  final allBranchSales = allBranchSalesResult.fold(
    (failure) => <Sale>[],
    (list) => list,
  );
  final salesByCreatedOnly = allBranchSales.where((sale) {
    if (sale.postedDate != null) return false; // already fetched above
    final created = sale.created;
    if (created == null) return false;
    return !created.isBefore(dateRange.start) &&
        !created.isAfter(dateRange.end);
  }).toList();

  // Merge and deduplicate
  final salesIdSet = salesByPostedDate.map((s) => s.id).toSet();
  final mergedSales = [
    ...salesByPostedDate,
    ...salesByCreatedOnly.where((s) => !salesIdSet.contains(s.id)),
  ];

  // Filter to eligible order statuses (ready/pickedUp)
  final eligibleSales = mergedSales.where((sale) =>
      sale.orderStatus == OrderStatus.ready ||
      sale.orderStatus == OrderStatus.pickedUp).toList();

  // Fetch service items for eligible sales, compute per-order incentive,
  // and group by day
  final dailyServiceRevenue = <DateTime, num>{};
  final dailyOrderBreakdown = <DateTime, List<OrderIncentiveEntry>>{};
  for (final sale in eligibleSales) {
    final itemsResult = await salesRepo.getSaleServiceItems(sale.id);
    final items = itemsResult.fold(
      (failure) => <SaleServiceItem>[],
      (list) => list,
    );
    // Use postedDate or created for day grouping
    final saleDate = sale.postedDate ?? sale.created ?? DateTime.now();
    final day = DateTime(saleDate.year, saleDate.month, saleDate.day);
    num saleServiceTotal = 0;
    for (final item in items) {
      dailyServiceRevenue[day] =
          (dailyServiceRevenue[day] ?? 0) + item.subtotal;
      saleServiceTotal += item.subtotal;
    }
    // Calculate incentive per order
    final orderIncentive = perServicePrice > 0
        ? (saleServiceTotal / perServicePrice).floor() * incentiveRate
        : 0;
    if (saleServiceTotal > 0) {
      dailyOrderBreakdown.putIfAbsent(day, () => []).add(
        OrderIncentiveEntry(
          receiptNumber: sale.receiptNumber,
          customerName: sale.customerName,
          servicePrice: saleServiceTotal,
          incentive: orderIncentive,
          orderStatus: sale.orderStatus.displayName,
        ),
      );
    }
  }

  // Fetch all attendance records for all employees in the range
  final allAttendanceByEmployee = <String, List<EmployeeAttendance>>{};
  for (final employee in employees) {
    final attendanceResult =
        await attendanceRepo.fetchForEmployee(employee.id);
    final allAttendance = attendanceResult.fold(
      (failure) => <EmployeeAttendance>[],
      (list) => list,
    );
    // Filter within date range
    allAttendanceByEmployee[employee.id] = allAttendance.where((a) {
      return !a.date.isBefore(dateRange.start) &&
          !a.date.isAfter(dateRange.end);
    }).toList();
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

  // Build final entries
  final entries = employees.map((employee) {
    final attendance = allAttendanceByEmployee[employee.id] ?? [];
    final daysPresent = attendance.where((a) => a.isPresent).length;
    final daysOut = attendance.where((a) => !a.isPresent).length;

    return EmployeeReportEntry(
      employee: employee,
      daysPresent: daysPresent,
      daysOut: daysOut,
      totalDaysInRange: totalDays,
      incentiveAmount: employeeIncentives[employee.id] ?? 0,
      baseSalary: employee.baseSalary,
    );
  }).toList();

  return EmployeeReportData(
    entries: entries,
    dailyBreakdown: dailyBreakdown,
    totalServicePrice: totalServicePrice,
    incentiveRate: incentiveRate,
    perServicePrice: perServicePrice,
    branch: branch,
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
  });

  final List<EmployeeReportEntry> entries;
  final List<DailyIncentiveEntry> dailyBreakdown;
  final num totalServicePrice;
  final num incentiveRate;
  final num perServicePrice;
  final Branch? branch;

  int get totalPresent => entries.fold(0, (sum, e) => sum + e.daysPresent);
  int get totalOut => entries.fold(0, (sum, e) => sum + e.daysOut);
  num get totalIncentive =>
      entries.fold<num>(0, (sum, e) => sum + e.incentiveAmount);
  num get totalBaseSalary =>
      entries.fold<num>(0, (sum, e) => sum + e.baseSalary);
  num get totalPay => entries.fold<num>(0, (sum, e) => sum + e.totalPay);
}
