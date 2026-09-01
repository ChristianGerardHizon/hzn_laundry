import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/pos/presentation/cart_controller.dart';
import '../../features/version_lock/presentation/controllers/play_store_update_provider.dart';
import '../i18n/strings.g.dart';
import '../packages/pocketbase/pb_connectivity_provider.dart';
import '../routing/routes/dashboard.routes.dart';
import '../routing/routes/organization.routes.dart';
import '../routing/routes/products.routes.dart';
import '../routing/routes/customers.routes.dart';
import '../routing/routes/employees.routes.dart';
import '../routing/routes/services.routes.dart';
import '../routing/routes/reports.routes.dart';
import '../routing/routes/activities.routes.dart';
import '../routing/routes/sales_history.routes.dart';
import '../routing/routes/promos.routes.dart';
import '../routing/routes/system.routes.dart';
import '../utils/breakpoints.dart';
import '../widgets/branch_switcher.dart';
import '../widgets/fullscreen_toggle_button.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../widgets/mobile_drawer.dart';
import '../widgets/nav_permissions.dart';
import '../widgets/tablet_nav_rail.dart';

/// Main adaptive shell widget that wraps authenticated app content.
///
/// Provides responsive navigation:
/// - Mobile (< 600px): Bottom navigation + drawer
/// - Tablet (600-1200px): Navigation rail
/// - Desktop (>= 1200px): Expanded navigation rail
class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({
    super.key,
    required this.child,
  });

  /// The child widget from the router (page content).
  final Widget child;

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  /// Key for the scaffold to control drawer.
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Dismiss keyboard when entering authenticated shell (e.g., after login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
    // Kick off Google Play's flexible in-app update check in the background.
    Future(() {
      ref
          .read(playStoreUpdateProvider.notifier)
          .startFlexibleUpdateIfAvailable();
    });
  }

  /// Route paths in order of navigation index.
  static const _routePaths = [
    DashboardRoute.path, // 0: /
    SalesHistoryRoute.path, // 1: /sales
    ProductsRoute.path, // 2: /products
    ServicesRoute.path, // 3: /services
    CustomersRoute.path, // 4: /customers
    EmployeesRoute.path, // 5: /employees
    ReportsRoute.path, // 6: /reports
    ActivitiesRoute.path, // 7: /activities
    OrganizationRoute.path, // 8: /organization
    PromosRoute.path, // 9: /promos
    SystemRoute.path, // 10: /system
  ];

  /// Routes in order of navigation index.
  static const _routes = <GoRouteData>[
    DashboardRoute(), // 0
    SalesHistoryRoute(), // 1
    ProductsRoute(), // 2
    ServicesRoute(), // 3
    CustomersRoute(), // 4
    EmployeesRoute(), // 5
    ReportsRoute(), // 6
    ActivitiesRoute(), // 7
    OrganizationRoute(), // 8
    PromosRoute(), // 9
    SystemRoute(), // 10
  ];

  /// Gets the selected index within the visible items based on current route.
  int _getSelectedIndex(BuildContext context, List<NavItem> visibleItems) {
    final location = GoRouterState.of(context).uri.path;

    // Find which visible item matches the current route
    for (int i = 0; i < visibleItems.length; i++) {
      final routeIndex = visibleItems[i].index;
      final routePath = _routePaths[routeIndex];

      if (location == routePath) return i;
      // For nested routes, check prefix (skip '/' to prevent matching everything)
      if (routeIndex > 0 && location.startsWith(routePath)) return i;
    }

    return 0;
  }

  void _onDestinationSelected(int visibleIndex, List<NavItem> visibleItems) {
    if (visibleIndex >= 0 && visibleIndex < visibleItems.length) {
      final routeIndex = visibleItems[visibleIndex].index;
      _routes[routeIndex].go(context);
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // Keep PocketBase health polling alive for the authenticated shell.
    ref.watch(pbConnectivityProvider);

    // Initialize cart controller early to load any active cart
    ref.watch(cartControllerProvider);

    // Listen for a completed flexible background update and prompt to restart.
    ref.listen(playStoreUpdateProvider, (previous, next) {
      if (next != FlexibleUpdateState.readyToInstall) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Update downloaded'),
            action: SnackBarAction(
              label: 'Restart',
              onPressed: () => ref
                  .read(playStoreUpdateProvider.notifier)
                  .completeFlexibleUpdate(),
            ),
            duration: const Duration(days: 1),
          ),
        );
      });
    });

    final isMobile = Breakpoints.isMobile(context);

    // Build permission-filtered nav items
    final t = Translations.of(context);
    final allNavItems = buildAllNavItems((key) => switch (key) {
          'dashboard' => t.navigation.dashboard,
          'salesHistory' => t.navigation.salesHistory,
          'products' => t.navigation.products,
          'services' => t.navigation.services,
          'customers' => t.navigation.customers,
          'employees' => t.navigation.employees,
          'reports' => t.navigation.reports,
          'activities' => t.navigation.activities,
          'organization' => t.navigation.organization,
          'system' => t.navigation.system,
          _ => key,
        });
    final roleAsync = ref.watch(currentUserRoleProvider);
    final role = roleAsync.value;
    final visibleItems = filterNavItems(allNavItems, role);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // Check if the router can pop (i.e. we're on a nested page)
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
          return;
        }

        // We're at a root page — confirm exit
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text(
              'Are you sure you want to close the app?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
      },
      child: isMobile
          ? _buildMobileLayout(context, visibleItems)
          : _buildTabletLayout(context, visibleItems),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<NavItem> visibleItems) {
    final selectedIndex = _getSelectedIndex(context, visibleItems);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MobileDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onDestinationSelected(i, visibleItems),
        visibleItems: visibleItems,
      ),
      body: SafeArea(
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: BranchSwitcher(compact: true)),
                  const FullscreenToggleButton(),
                ],
              ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MobileBottomNav(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onDestinationSelected(i, visibleItems),
        onMoreTap: _openDrawer,
        visibleItems: visibleItems,
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, List<NavItem> visibleItems) {
    final selectedIndex = _getSelectedIndex(context, visibleItems);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Navigation Rail
            TabletNavRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) =>
                  _onDestinationSelected(i, visibleItems),
              visibleItems: visibleItems,
            ),

            const VerticalDivider(width: 1),

            // Main content area
            Expanded(
              child: Scaffold(
                body: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: BranchSwitcher(compact: true)),
                          const FullscreenToggleButton(),
                        ],
                      ),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
