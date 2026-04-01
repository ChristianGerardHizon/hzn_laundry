import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'dashboard_footer.dart';
import 'inventory_alerts_section.dart';
import 'kanban_board_section.dart';
import 'quick_actions_section.dart';

/// Single-pane tablet layout for the dashboard.
///
/// Displays KPIs, quick actions, inventory alerts, and footer.
class TabletDashboardLayout extends HookConsumerWidget {
  const TabletDashboardLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branch = ref.watch(currentBranchControllerProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.dashboard,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Dashboard Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Show current branch if available
          if (branch != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    branch.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
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
