import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/pos/presentation/cart_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../../features/version_lock/domain/version_check_result.dart';
import '../../features/version_lock/presentation/controllers/update_dismissed_provider.dart';
import '../../features/version_lock/presentation/controllers/version_check_provider.dart';
import '../../features/version_lock/presentation/widgets/optional_update_dialog.dart';
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
import '../widgets/mobile_bottom_nav.dart';
import '../widgets/mobile_drawer.dart';
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

  /// Gets the selected index based on current route location.
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    // Try exact match first
    final index = _routePaths.indexOf(location);
    if (index >= 0) return index;

    // For nested routes, check if location starts with any route path
    // Skip index 0 ('/') to prevent matching everything
    for (int i = 1; i < _routePaths.length; i++) {
      if (location.startsWith(_routePaths[i])) {
        return i;
      }
    }

    // Fallback to dashboard
    return 0;
  }

  void _onDestinationSelected(int index) {
    if (index >= 0 && index < _routes.length) {
      _routes[index].go(context);
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize cart controller early to load any active cart
    ref.watch(cartControllerProvider);

    // Listen for optional update availability
    ref.listen(versionCheckProvider, (previous, next) {
      final result = next.value;
      if (result == null) return;
      if (result.status != VersionCheckStatus.updateAvailable) return;
      if (ref.read(updateDismissedProvider)) return;

      ref.read(updateDismissedProvider.notifier).dismiss();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showOptionalUpdateDialog(context, result);
      });
    });

    final isMobile = Breakpoints.isMobile(context);

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
          ? _buildMobileLayout(context)
          : _buildTabletLayout(context),
    );
  }

  Widget _buildBranchBar(BuildContext context) {
    final theme = Theme.of(context);
    final branchAsync = ref.watch(currentBranchControllerProvider);

    return branchAsync.when(
      data: (branch) {
        if (branch == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.store,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                branch.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MobileDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      body: SafeArea(
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              _buildBranchBar(context),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MobileBottomNav(
        selectedIndex: selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        onMoreTap: _openDrawer,
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Navigation Rail
            TabletNavRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,
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
                      _buildBranchBar(context),
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
