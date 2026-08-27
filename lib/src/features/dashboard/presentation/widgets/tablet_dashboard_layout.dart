import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/nav_permissions.dart';
import '../../../users/domain/user_role.dart';
import '../controllers/dashboard_date_override_provider.dart';
import 'dashboard_alerts_row.dart';
import 'dashboard_footer.dart';
import 'date_override_banner.dart';
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
    final effectiveDate = ref.watch(dashboardEffectiveDateProvider);
    final isOverridden = ref.watch(isDashboardDateOverriddenProvider);
    final overrideColor = theme.brightness == Brightness.dark
        ? Colors.amber.shade200
        : Colors.amber.shade800;

    final role = ref.watch(currentUserRoleProvider).value;
    final canOverrideDate = role?.isAdmin == true ||
        (role?.hasPermission(Permissions.dashboardDateOverride) ?? false);

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: effectiveDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        final today = DateTime.now();
        final isToday = picked.year == today.year &&
            picked.month == today.month &&
            picked.day == today.day;
        if (isToday) {
          ref.read(dashboardDateOverrideProvider.notifier).clearOverride();
        } else {
          ref.read(dashboardDateOverrideProvider.notifier).setDate(picked);
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
            onTap: canOverrideDate ? pickDate : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEEE').format(effectiveDate),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOverridden ? overrideColor : null,
                      ),
                    ),
                    if (canOverrideDate) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: isOverridden
                            ? overrideColor
                            : theme.colorScheme.outline,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(effectiveDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isOverridden
                            ? overrideColor
                            : theme.colorScheme.outline,
                      ),
                    ),
                    if (isOverridden) const DateOverrideBanner(),
                  ],
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 16),
          const SalesSummarySection(),
          const SizedBox(height: 12),

          const DashboardAlertsRow(),
          const SizedBox(height: 12),

          // Quick Actions Section
          const QuickActionsSection(),
          const SizedBox(height: 16),

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
