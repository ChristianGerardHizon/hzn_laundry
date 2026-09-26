import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'users.routes.g.dart';

String _managementUsersLocation(GoRouterState state, {String? userId}) {
  final org = state.pathParameters['orgSlug'];
  final branch = state.pathParameters['branchSlug'];
  final suffix = userId == null
      ? '/management/users'
      : '/management/users/${Uri.encodeComponent(userId)}';
  if (org != null && branch != null) {
    return '/$org/$branch$suffix';
  }
  return suffix;
}

String _managementRolesLocation(GoRouterState state) {
  final org = state.pathParameters['orgSlug'];
  final branch = state.pathParameters['branchSlug'];
  const suffix = '/management/roles';
  if (org != null && branch != null) {
    return '/$org/$branch$suffix';
  }
  return suffix;
}

/// Legacy `/users` routes — redirect to Management.
@TypedGoRoute<UsersRoute>(
  path: UsersRoute.path,
  routes: [
    TypedGoRoute<UserDetailRoute>(path: ':id'),
    TypedGoRoute<UserRolesRoute>(path: 'roles'),
  ],
)
class UsersRoute extends GoRouteData with $UsersRoute {
  const UsersRoute();

  static const path = '/users';

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return _managementUsersLocation(state);
  }
}

/// Legacy user detail — redirect to Management.
class UserDetailRoute extends GoRouteData with $UserDetailRoute {
  const UserDetailRoute({required this.id, this.tab});

  final String id;
  final String? tab;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return _managementUsersLocation(state, userId: id);
  }
}

/// Legacy `/users/roles` — redirect to Management roles.
class UserRolesRoute extends GoRouteData with $UserRolesRoute {
  const UserRolesRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return _managementRolesLocation(state);
  }
}
