import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../widgets/views/new_customers_view.dart';
import '../widgets/views/sales_by_customer_view.dart';
import '../widgets/views/sales_detail_view.dart';
import '../widgets/views/sales_report_view.dart';

/// Main reports page with tabbed navigation for different report types.
class ReportsPage extends HookConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
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
        ],
      ),
    );
  }
}
