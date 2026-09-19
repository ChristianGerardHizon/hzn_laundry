import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

/// Navigation helpers for [GoRouteData] classes nested under the
/// `/:orgSlug/:branchSlug` prefix in `router.dart`.
///
/// The prefix is a hand-written [GoRoute], outside every feature route
/// file's own `@TypedGoRoute`/`@TypedShellRoute` tree, so the codegen'd
/// `.location`/`.go`/`.push` on those classes are unprefixed (e.g.
/// `/products`) and would 404 if navigated to directly. These helpers read
/// the current `orgSlug`/`branchSlug` from [GoRouter.state] (not
/// [GoRouterState.of], which fails under dialog overlays) and prepend them.
extension OrgScopedGoRouteData on GoRouteData {
  /// Dialog contexts may be unmounted after [DialogDismissingObserver.dismissAllDialogs].
  BuildContext _routerContext(BuildContext context) {
    if (context.mounted) return context;
    final root = rootNavigatorKey.currentContext;
    assert(root != null && root.mounted, 'No navigator context for scoped navigation');
    return root!;
  }

  String _scopedLocation(BuildContext context) {
    final params = GoRouter.of(context).state.pathParameters;
    final orgSlug = params['orgSlug'];
    final branchSlug = params['branchSlug'];
    assert(
      orgSlug != null && branchSlug != null,
      'goScoped/pushScoped used outside org/branch route scope for $location',
    );
    return '/$orgSlug/$branchSlug$location';
  }

  /// Like [GoRouteData.go], but prefixed with the current org/branch scope.
  void goScoped(BuildContext context) {
    final ctx = _routerContext(context);
    ctx.go(_scopedLocation(ctx));
  }

  /// Like [GoRouteData.push], but prefixed with the current org/branch scope.
  Future<T?> pushScoped<T>(BuildContext context) {
    final ctx = _routerContext(context);
    return ctx.push<T>(_scopedLocation(ctx));
  }

  /// Like [GoRouteData.pushReplacement], but prefixed with the current
  /// org/branch scope.
  void pushReplacementScoped(BuildContext context) {
    final ctx = _routerContext(context);
    ctx.pushReplacement(_scopedLocation(ctx));
  }

  /// Like [GoRouteData.replace], but prefixed with the current org/branch
  /// scope.
  void replaceScoped(BuildContext context) {
    final ctx = _routerContext(context);
    ctx.replace(_scopedLocation(ctx));
  }
}
