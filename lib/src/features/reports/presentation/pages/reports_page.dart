import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/attendance_report_controller.dart';
import '../controllers/employee_report_controller.dart';
import '../controllers/new_customers_controller.dart';
import '../controllers/payments_report_controller.dart';
import '../controllers/payments_summary_controller.dart';
import '../controllers/sales_by_customer_controller.dart';
import '../controllers/sales_detail_controller.dart';
import '../widgets/views/attendance_report_view.dart';
import '../widgets/views/incentive_report_view.dart';
import '../widgets/views/new_customers_view.dart';
import '../widgets/views/salary_report_view.dart';
import '../widgets/views/sales_by_customer_view.dart';
import '../widgets/views/sales_detail_view.dart';
import '../widgets/views/sales_report_view.dart';

/// Main reports page with tabbed navigation for different report types.
class ReportsPage extends HookConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 7);

    void refreshCurrentTab() {
      switch (tabController.index) {
        case 0:
          ref.invalidate(paymentsSummaryProvider);
          ref.invalidate(paymentsReportProvider);
        case 1:
          ref.invalidate(salesDetailProvider);
        case 2:
          ref.invalidate(salesByCustomerProvider);
        case 3:
          ref.invalidate(newCustomersReportProvider);
        case 4:
          ref.invalidate(attendanceReportProvider);
        case 5:
          ref.invalidate(salaryReportProvider);
        case 6:
          ref.invalidate(employeeReportProvider);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: refreshCurrentTab,
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(
              icon: Icon(Icons.attach_money),
              text: 'Sales',
            ),
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'Orders',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Sales by Customer',
            ),
            Tab(
              icon: Icon(Icons.person_add),
              text: 'New Customers',
            ),
            Tab(
              icon: Icon(Icons.calendar_month),
              text: 'Attendance',
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet),
              text: 'Salary',
            ),
            Tab(
              icon: Icon(Icons.payments),
              text: 'Incentives',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          SalesReportView(),
          SalesDetailView(),
          SalesByCustomerView(),
          NewCustomersView(),
          AttendanceReportView(),
          SalaryReportView(),
          IncentiveReportView(),
        ],
      ),
    );
  }
}
