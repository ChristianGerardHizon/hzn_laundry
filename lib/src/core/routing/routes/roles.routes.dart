import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'roles.routes.g.dart';

/// Legacy `/roles` — redirect to Management roles.
@TypedGoRoute<RolesRoute>(path: RolesRoute.path)
class RolesRoute extends GoRouteData with $RolesRoute {
  const RolesRoute();

  static const path = '/roles';

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final org = state.pathParameters['orgSlug'];
    final branch = state.pathParameters['branchSlug'];
    const suffix = '/management/roles';
    if (org != null && branch != null) {
      return '/$org/$branch$suffix';
    }
    return suffix;
  }
}
