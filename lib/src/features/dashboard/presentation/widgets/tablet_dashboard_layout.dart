import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'dashboard_footer.dart';
import 'inventory_alerts_section.dart';
import 'kanban_board_section.dart';
import 'quick_actions_section.dart';
import 'sales_summary_section.dart';

/// Single-pane tablet layout for the dashboard.
///
/// Displays KPIs, quick actions, inventory alerts, and footer.
class TabletDashboardLayout extends HookConsumerWidget {
  const TabletDashboardLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's date header
          Text(
            DateFormat('EEEE').format(DateTime.now()),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('MMMM d, yyyy').format(DateTime.now()),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Sales Summary Section (collapsible)
          const SalesSummarySection(),
          const SizedBox(height: 24),

          // Quick Actions Section
          const QuickActionsSection(),
          const SizedBox(height: 24),

          // Order Board (Kanban)
          const KanbanBoardSection(),
          const SizedBox(height: 24),

          // Inventory Alerts Section
          const InventoryAlertsSection(),
          const SizedBox(height: 24),

          // App Version Footer
          const DashboardFooter(),
        ],
      ),
    );
  }
}
