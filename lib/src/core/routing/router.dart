import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../../features/version_lock/presentation/controllers/version_check_provider.dart';
import '../pages/app_root.dart';
import '../widgets/nav_permissions.dart';
import 'dialog_dismissing_observer.dart';
import 'pending_redirect_provider.dart';
import 'router_utils.dart';
import 'routes/auth.routes.dart';
import 'routes/dashboard.routes.dart';
import 'routes/management.routes.dart';
import 'routes/organizations.routes.dart';
import 'routes/products.routes.dart';
import 'routes/customer_history.routes.dart';
import 'routes/customers.routes.dart';
import 'routes/employees.routes.dart';
import 'routes/services.routes.dart';
import 'routes/sales.routes.dart';
import 'routes/sales_history.routes.dart';
import 'routes/reports.routes.dart';
import 'routes/activities.routes.dart';
import 'routes/promos.routes.dart';
import 'routes/system.routes.dart';
import 'routes/version_lock.routes.dart';

part 'router.g.dart';

/// Global navigator key for root navigation.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Global ScaffoldMessenger key for showing snackbars on root scaffold.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Provides the GoRouter instance for the application.
///
/// Configured with auth redirects and error handling.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  _stashWebDeepLinkIfNeeded();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SplashRoute.path,
    debugLogDiagnostics: true,
    observers: [SentryNavigatorObserver(), DialogDismissingObserver()],
    redirect: (context, state) => RouterUtils.redirect(context, state, ref),
    errorBuilder: RouterUtils.errorBuilder,
    routes: [
      // Version lock routes (outside shell)
      $forceUpdateRoute,
      $webUpdateRoute,

      // Public customer history route (outside shell, no auth)
      $customerHistoryRoute,

      // Auth routes (outside shell)
      $splashRoute,
      $loginRoute,
      $forgotPasswordRoute,
      $authLoadingRoute,

      // Org/branch-scoped main app. `:orgSlug`/`:branchSlug` are hand-written
      // so feature route `path:` constants stay unchanged. Navigate with
      // `.goScoped(context)` / `.pushScoped(context)` under this prefix.
      GoRoute(
        path: '/:orgSlug/:branchSlug',
        redirect: (context, state) {
          final org = state.pathParameters['orgSlug']!;
          final branch = state.pathParameters['branchSlug']!;
          final path = state.uri.path.replaceAll(RegExp(r'/+$'), '');
          if (path == '/$org/$branch') {
            return '/$org/$branch${DashboardRoute.path}';
          }
          return null;
        },
        routes: [
          ShellRoute(
            builder: (context, state, child) => AppRoot(child: child),
            routes: [
              $dashboardRoute,
              $productsShellRoute,
              $servicesShellRoute,
              $customersShellRoute,
              $employeesShellRoute,
              $salesRoute,
              $salesShellRoute,
              $reportsRoute,
              $activitiesRoute,
              $managementShellRoute,
              $organizationsRoute,
              $promosShellRoute,
              $systemShellRoute,
            ],
          ),
        ],
      ),
    ],
  );

  ref.listen(authControllerProvider, (previous, next) {
    router.refresh();
  });

  ref.listen(versionCheckProvider, (previous, next) {
    if (previous?.isLoading == true && !next.isLoading) {
      router.refresh();
    }
  });

  ref.listen(currentUserRoleProvider, (previous, next) {
    router.refresh();
  });

  ref.listen(currentOrganizationControllerProvider, (previous, next) {
    router.refresh();
  });

  ref.listen(currentBranchControllerProvider, (previous, next) {
    router.refresh();
  });

  Future.microtask(router.refresh);

  return router;
}

void _stashWebDeepLinkIfNeeded() {
  if (!kIsWeb) return;

  final platform = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  final uri = Uri.tryParse(platform);
  final path = uri?.path ?? platform;
  if (path.isEmpty || path == '/') return;
  if (RouterUtils.ignoredRoutes.any((route) => path.startsWith(route))) {
    return;
  }

  PendingRedirect.stash(uri?.toString() ?? platform);
}
