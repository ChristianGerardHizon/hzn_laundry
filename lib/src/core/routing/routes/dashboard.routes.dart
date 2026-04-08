import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../features/dashboard/presentation/controllers/dashboard_date_override_provider.dart';
import '../../../features/dashboard/presentation/controllers/dashboard_kpi_provider.dart';
import '../../../features/users/domain/user_role.dart';
import '../../widgets/nav_permissions.dart';
import '../../../features/dashboard/presentation/controllers/dashboard_realtime_provider.dart';
import '../../../features/dashboard/presentation/controllers/inventory_alerts_controller.dart';
import '../../../features/dashboard/presentation/controllers/kanban_sales_controller.dart';
import '../../../features/dashboard/presentation/controllers/todays_sales_controller.dart';
import '../../../features/dashboard/presentation/controllers/sales_summary_controller.dart';
import '../../../features/dashboard/presentation/widgets/attendance_alert_section.dart';
import '../../../features/dashboard/presentation/widgets/date_override_banner.dart';
import '../../../features/dashboard/presentation/widgets/inventory_alerts_section.dart';
import '../../../features/dashboard/presentation/widgets/kanban_board_section.dart';
import '../../../features/dashboard/presentation/widgets/quick_actions_section.dart';
import '../../../features/dashboard/presentation/widgets/sales_summary_section.dart';
import '../../../features/dashboard/presentation/widgets/tablet_dashboard_layout.dart';
import '../../../features/dashboard/presentation/widgets/dashboard_footer.dart';
import '../../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../../utils/breakpoints.dart';

part 'dashboard.routes.g.dart';

/// Dashboard/home page route.
@TypedGoRoute<DashboardRoute>(path: DashboardRoute.path)
class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  static const path = '/';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardPage();
  }
}

/// Dashboard page content.
///
/// This is rendered within the [AppRoot] shell which provides
/// the AppBar and navigation. Only the body content is defined here.
///
/// On tablet: Shows single-pane overview layout
/// On mobile: Shows single-column list
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activate PocketBase realtime subscriptions for dashboard data.
    // Automatically unsubscribes when navigating away.
    ref.watch(dashboardRealtimeProvider);

    final isTablet = Breakpoints.isTabletOrLarger(context);

    if (isTablet) {
      return const Scaffold(
        body: TabletDashboardLayout(),
      );
    }

    // Mobile: Single column layout with all sections
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all dashboard data
          ref.invalidate(inventoryAlertsSummaryProvider);
          ref.invalidate(todaySalesSummaryProvider);
          ref.invalidate(salesSummaryProvider);
          ref.invalidate(kanbanSalesProvider);
          ref.invalidate(productsNearExpirationCountProvider);
          ref.invalidate(productsExpiredCountProvider);
          ref.invalidate(lowStockProductsCountProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Header
              const _MobileDashboardHeader(),
              const SizedBox(height: 8),

              // Warning banner when date is overridden
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DateOverrideBanner(),
              ),
              const SizedBox(height: 8),

              // Sales Summary Section (collapsible)
              const SalesSummarySection(),
              const SizedBox(height: 24),

              // Quick Actions Section
              const QuickActionsSection(),
              const SizedBox(height: 16),

              // Attendance Alert (shown when not all employees are marked)
              const AttendanceAlertSection(),
              const SizedBox(height: 24),

              // Order Board (Kanban)
              KanbanBoardSection(),
              SizedBox(height: 24),

              // Inventory Alerts Section
              const InventoryAlertsSection(),
              const SizedBox(height: 24),

              // App Version Footer
              const DashboardFooter(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile dashboard header widget.
class _MobileDashboardHeader extends ConsumerWidget {
  const _MobileDashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branch = ref.watch(currentBranchControllerProvider).value;
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          // Date display — tappable to open date picker (if permitted)
          if (canOverrideDate || isOverridden)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: canOverrideDate ? pickDate : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isOverridden
                            ? overrideColor
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(effectiveDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isOverridden
                              ? overrideColor
                              : theme.colorScheme.outline,
                          fontWeight:
                              isOverridden ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
