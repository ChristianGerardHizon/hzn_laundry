import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../entitlements/domain/feature_key.dart';
import '../../../entitlements/presentation/controllers/feature_enabled_provider.dart';
import '../controllers/attendance_report_controller.dart';
import '../controllers/consumables_usage_report_controller.dart';
import '../controllers/employee_report_controller.dart';
import '../controllers/new_customers_controller.dart';
import '../controllers/payments_report_controller.dart';
import '../controllers/payments_summary_controller.dart';
import '../controllers/sales_by_customer_controller.dart';
import '../controllers/sales_detail_controller.dart';
import '../controllers/sales_detail_summary_controller.dart';
import '../widgets/views/attendance_report_view.dart';
import '../widgets/views/consumables_usage_report_view.dart';
import '../widgets/views/new_customers_view.dart';
import '../widgets/views/salary_report_view.dart';
import '../widgets/views/sales_by_customer_view.dart';
import '../widgets/views/sales_detail_view.dart';
import '../widgets/views/sales_report_view.dart';

/// One report tab. [feature] hides the tab when that feature is off.
class _ReportTab {
  const _ReportTab({
    required this.icon,
    required this.label,
    required this.view,
    required this.refresh,
    this.feature,
  });

  final IconData icon;
  final String label;
  final Widget view;
  final void Function(WidgetRef ref) refresh;
  final FeatureKey? feature;
}

/// Main reports page with tabbed navigation for different report types.
class ReportsPage extends HookConsumerWidget {
  const ReportsPage({super.key});

  static final List<_ReportTab> _allTabs = [
    _ReportTab(
      icon: Icons.attach_money,
      label: 'Sales',
      view: const SalesReportView(),
      refresh: (ref) {
        ref.invalidate(paymentsSummaryProvider);
        ref.invalidate(paymentsReportControllerProvider);
      },
    ),
    _ReportTab(
      icon: Icons.list_alt,
      label: 'Orders',
      view: const SalesDetailView(),
      refresh: (ref) {
        ref.invalidate(salesDetailSummaryProvider);
        ref.invalidate(salesDetailControllerProvider);
      },
    ),
    _ReportTab(
      icon: Icons.people,
      label: 'Sales by Customer',
      view: const SalesByCustomerView(),
      refresh: (ref) {
        ref.invalidate(salesByCustomerRawProvider);
        ref.invalidate(salesByCustomerProvider);
      },
    ),
    _ReportTab(
      icon: Icons.person_add,
      label: 'New Customers',
      view: const NewCustomersView(),
      refresh: (ref) => ref.invalidate(newCustomersReportProvider),
    ),
    _ReportTab(
      icon: Icons.calendar_month,
      label: 'Attendance',
      view: const AttendanceReportView(),
      refresh: (ref) => ref.invalidate(attendanceReportProvider),
      feature: FeatureKey.attendance,
    ),
    _ReportTab(
      icon: Icons.account_balance_wallet,
      label: 'Salary',
      view: const SalaryReportView(),
      refresh: (ref) => ref.invalidate(salaryReportProvider),
      feature: FeatureKey.employees,
    ),
    _ReportTab(
      icon: Icons.science_outlined,
      label: 'Consumables',
      view: const ConsumablesUsageReportView(),
      refresh: (ref) => ref.invalidate(consumablesUsageReportProvider),
      feature: FeatureKey.consumableUsage,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = [
      for (final tab in _allTabs)
        if (tab.feature == null || ref.watch(featureEnabledProvider(tab.feature!)))
          tab,
    ];
    final tabController = useTabController(
      initialLength: tabs.length,
      keys: [tabs.length],
    );

    void refreshCurrentTab() {
      final index = tabController.index.clamp(0, tabs.length - 1);
      tabs[index].refresh(ref);
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
          tabs: [
            for (final tab in tabs) Tab(icon: Icon(tab.icon), text: tab.label),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [for (final tab in tabs) tab.view],
      ),
    );
  }
}
