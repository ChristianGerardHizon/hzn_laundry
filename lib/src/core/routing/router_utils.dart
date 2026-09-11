import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/settings/presentation/controllers/branches_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../../features/version_lock/domain/version_check_result.dart';
import '../../features/version_lock/presentation/controllers/version_check_provider.dart';
import '../widgets/nav_permissions.dart';
import 'pending_redirect_provider.dart';
import 'route_permissions.dart';
import 'route_scope_provider.dart';
import 'routes/auth.routes.dart';
import 'routes/dashboard.routes.dart';
import 'routes/version_lock.routes.dart';

/// Utility functions for router configuration.
abstract class RouterUtils {
  /// Routes that should not trigger auth redirects.
  static const List<String> ignoredRoutes = [
    '/login',
    '/splash',
    '/auth-loading',
    '/forgot-password',
    '/force-update',
    '/web-update',
    '/history',
  ];

  /// True for empty or slash-only paths (not a registered shell route).
  static bool isEmptyRootPath(String path) => path.isEmpty || path == '/';

  /// Current path without calling [GoRouter.state], which throws [StateError]
  /// when the match list is empty.
  static String currentLocation(GoRouter router) {
    final config = router.routerDelegate.currentConfiguration;
    return config.lastOrNull?.matchedLocation ?? config.uri.path;
  }

  /// Home path for an authenticated user: scoped dashboard when possible.
  ///
  /// Returns null while org/branch scope is still loading, or when scope
  /// cannot be resolved (missing memberships / empty slugs). Callers on
  /// splash must not treat null as "stay via redirect to /splash" forever
  /// without also checking loading — see [redirect] step 3.
  static String? homePathFor(Ref ref) {
    final prefix = _resolveScopePrefix(ref);
    if (prefix == null) return null;
    return '$prefix${DashboardRoute.path}';
  }

  /// True while org or branch controllers are still resolving.
  static bool isScopeLoading(Ref ref) {
    final orgAsync = ref.read(currentOrganizationControllerProvider);
    final branchAsync = ref.read(currentBranchControllerProvider);
    return orgAsync.isLoading || branchAsync.isLoading;
  }

  /// Resolves `/orgSlug/branchSlug` from current org/branch controllers.
  static String? _resolveScopePrefix(Ref ref) {
    final orgAsync = ref.read(currentOrganizationControllerProvider);
    if (orgAsync.isLoading) return null;
    final org = orgAsync.value;
    if (org == null || org.slug.isEmpty) return null;

    final branchAsync = ref.read(currentBranchControllerProvider);
    if (branchAsync.isLoading) return null;

    final isAll =
        ref.read(currentBranchControllerProvider.notifier).isAllBranchesMode;
    if (isAll) {
      return '/${org.slug}/$allBranchesSlug';
    }

    final branch = branchAsync.value;
    final branchSlug = branch?.slug;
    if (branchSlug == null || branchSlug.isEmpty) return null;
    return '/${org.slug}/$branchSlug';
  }

  /// Replaces the `/orgSlug/branchSlug` segments of [currentLocation].
  static String replaceScopeSegment(
    String currentLocation, {
    String? orgSlug,
    String? branchSlug,
  }) {
    final segments = currentLocation.split('/');
    // ['', orgSlug, branchSlug, ...rest]
    if (segments.length < 3) return currentLocation;
    if (orgSlug != null) segments[1] = orgSlug;
    if (branchSlug != null) segments[2] = branchSlug;
    return segments.join('/');
  }

  /// Global redirect function for auth, version, and org/branch scope guards.
  static FutureOr<String?> redirect(
    BuildContext context,
    GoRouterState state,
    Ref ref,
  ) async {
    final currentPath = state.matchedLocation;
    final uriPath = state.uri.path;
    final fullUri = state.uri.toString();

    // Public customer history — no auth/version/scope checks.
    if (uriPath.startsWith('/history') || currentPath.startsWith('/history')) {
      return null;
    }

    // --- Version check redirects (take priority over auth) ---
    final versionAsync = ref.read(versionCheckProvider);
    final versionStatus = versionAsync.value?.status;

    if (versionStatus == VersionCheckStatus.forceUpdateRequired &&
        currentPath != ForceUpdateRoute.path) {
      return ForceUpdateRoute.path;
    }
    if (currentPath == ForceUpdateRoute.path &&
        versionStatus != VersionCheckStatus.forceUpdateRequired) {
      return SplashRoute.path;
    }
    if (versionStatus == VersionCheckStatus.webUpdateAvailable &&
        currentPath != WebUpdateRoute.path) {
      return WebUpdateRoute.path;
    }
    if (currentPath == WebUpdateRoute.path &&
        versionStatus != VersionCheckStatus.webUpdateAvailable) {
      return SplashRoute.path;
    }

    final isIgnored = ignoredRoutes.any(
      (route) =>
          currentPath.startsWith(route) || uriPath.startsWith(route),
    );

    final authAsync = ref.read(authControllerProvider);
    final isAuthenticated = authAsync.value != null;
    final isAuthLoading = authAsync.isLoading;
    final isOnLoginPage = currentPath == LoginRoute.path;
    final isOnSplashPage = currentPath == SplashRoute.path;

    // Bare `/` is not registered under the org/branch shell.
    if (isEmptyRootPath(uriPath)) {
      if (isAuthLoading) return SplashRoute.path;
      if (!isAuthenticated) return LoginRoute.path;
      if (isScopeLoading(ref)) return SplashRoute.path;
      return homePathFor(ref) ?? SplashRoute.path;
    }

    // 1. Still loading auth on splash - stay on splash
    if (isAuthLoading && isOnSplashPage) {
      return SplashRoute.path;
    }

    // 2. Auth loading + protected route - stash URL, go to splash
    if (isAuthLoading && !isIgnored) {
      PendingRedirect.stash(fullUri);
      Future(() {
        ref.read(pendingRedirectProvider.notifier).set(fullUri);
      });
      return SplashRoute.path;
    }

    // 3. Splash complete - redirect based on auth result
    if (isOnSplashPage && !isAuthLoading) {
      if (!isAuthenticated) return LoginRoute.path;
      // Wait for org/branch (and their slugs) before leaving splash.
      if (isScopeLoading(ref)) return null;
      final home = homePathFor(ref);
      if (home == null) return null;
      final pendingUrl = ref.read(pendingRedirectProvider.notifier).peek();
      if (pendingUrl != null) {
        ref.read(pendingRedirectProvider.notifier).clear();
        return pendingUrl;
      }
      return home;
    }

    // 4. Login page - redirect if authenticated
    if (isOnLoginPage) {
      if (isAuthenticated) {
        if (isScopeLoading(ref)) return SplashRoute.path;
        final home = homePathFor(ref);
        if (home == null) return SplashRoute.path;
        final pendingUrl = ref.read(pendingRedirectProvider.notifier).peek();
        if (pendingUrl != null) {
          ref.read(pendingRedirectProvider.notifier).clear();
          return pendingUrl;
        }
        return home;
      }
      return null;
    }

    // 5. Not authenticated + protected route - redirect to login
    if (!isAuthenticated && !isIgnored) {
      return LoginRoute.path;
    }

    // 5d. Flat main-app path (no org/branch prefix) → scoped rewrite
    if (isAuthenticated &&
        !isIgnored &&
        state.pathParameters['orgSlug'] == null &&
        scopedAppPaths.any((p) => matchesRoutePath(uriPath, p))) {
      final prefix = _resolveScopePrefix(ref);
      if (prefix != null) {
        return state.uri.replace(path: '$prefix$uriPath').toString();
      }
      return SplashRoute.path;
    }

    // 5e. Validate scoped URL org/branch segments
    if (isAuthenticated &&
        !isIgnored &&
        state.pathParameters['orgSlug'] != null) {
      final orgSlug = state.pathParameters['orgSlug']!;
      final branchSlug = state.pathParameters['branchSlug']!;

      final orgAsync = ref.read(currentOrganizationControllerProvider);
      if (orgAsync.isLoading) return null;
      final org = orgAsync.value;
      if (org == null || org.slug != orgSlug) {
        final prefix = _resolveScopePrefix(ref);
        if (prefix == null) return null;
        final wrongPrefixLength = '/$orgSlug/$branchSlug'.length;
        final suffix = currentPath.length > wrongPrefixLength
            ? currentPath.substring(wrongPrefixLength)
            : '';
        // Prefer uriPath suffix when matchedLocation is incomplete.
        final uriSuffix = uriPath.length > wrongPrefixLength
            ? uriPath.substring(wrongPrefixLength)
            : suffix;
        return state.uri.replace(path: '$prefix$uriSuffix').toString();
      }

      final branchesAsync = ref.read(branchesControllerProvider);
      if (branchesAsync.isLoading) return null;
      final orgBranches = branchesAsync.value ?? const [];

      bool branchValid;
      if (branchSlug == allBranchesSlug) {
        branchValid = await ref
            .read(currentBranchControllerProvider.notifier)
            .canViewAllBranches();
      } else {
        final match =
            orgBranches.where((b) => b.slug == branchSlug).firstOrNull;
        if (match == null) {
          branchValid = false;
        } else {
          final allowedIds = await ref
              .read(currentBranchControllerProvider.notifier)
              .switchableBranchIds();
          branchValid = allowedIds.contains(match.id);
        }
      }

      if (!branchValid) {
        return homePathFor(ref) ?? SplashRoute.path;
      }

      ref.read(currentRouteScopeProvider.notifier).set(orgSlug, branchSlug);
    }

    // 6. Role permission guards
    if (isAuthenticated && !isIgnored) {
      final role = ref.read(currentUserRoleProvider).value;
      final scopePrefixLength = state.pathParameters['orgSlug'] != null
          ? '/${state.pathParameters['orgSlug']}/${state.pathParameters['branchSlug']}'
              .length
          : 0;
      final pathForPerms = uriPath.length >= scopePrefixLength
          ? uriPath.substring(scopePrefixLength)
          : currentPath.substring(
              scopePrefixLength.clamp(0, currentPath.length),
            );
      final unscoped =
          pathForPerms.isEmpty ? DashboardRoute.path : pathForPerms;
      if (!canAccessPath(unscoped, role)) {
        final prefix = uriPath.substring(0, scopePrefixLength);
        return '$prefix${fallbackPathFor(role)}';
      }
    }

    return null;
  }

  /// Error page builder for unknown routes.
  static Widget errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '404',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                try {
                  const DashboardRoute().goScoped(context);
                } catch (_) {
                  context.go(SplashRoute.path);
                }
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
