// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'management.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $managementShellRoute,
    ];

RouteBase get $managementShellRoute => ShellRouteData.$route(
      factory: $ManagementShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/management',
          factory: $ManagementRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'users',
              factory: $ManagementUsersRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $ManagementUserDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'roles',
              factory: $ManagementRolesRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $ManagementRoleDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'branches',
              factory: $ManagementBranchesRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $ManagementBranchDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'machines',
              factory: $ManagementMachinesRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $ManagementMachineDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'storages',
              factory: $ManagementStoragesRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $ManagementStorageDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'product-categories',
              factory: $ManagementProductCategoriesRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $ManagementProductCategoryDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'quantity-units',
              factory: $ManagementQuantityUnitsRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $ManagementQuantityUnitDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'cashier-groups',
              factory: $ManagementCashierGroupsRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $ManagementCashierGroupDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'import',
              factory: $ManagementImportRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'settings',
              factory: $ManagementSettingsRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $ManagementShellRouteExtension on ManagementShellRoute {
  static ManagementShellRoute _fromState(GoRouterState state) =>
      const ManagementShellRoute();
}

mixin $ManagementRoute on GoRouteData {
  static ManagementRoute _fromState(GoRouterState state) =>
      const ManagementRoute();

  @override
  String get location => GoRouteData.$location(
        '/management',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementUsersRoute on GoRouteData {
  static ManagementUsersRoute _fromState(GoRouterState state) =>
      const ManagementUsersRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/users',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementUserDetailRoute on GoRouteData {
  static ManagementUserDetailRoute _fromState(GoRouterState state) =>
      ManagementUserDetailRoute(
        id: state.pathParameters['id']!,
        tab: state.uri.queryParameters['tab'],
      );

  ManagementUserDetailRoute get _self => this as ManagementUserDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/management/users/${Uri.encodeComponent(_self.id)}',
        queryParams: {
          if (_self.tab != null) 'tab': _self.tab,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementRolesRoute on GoRouteData {
  static ManagementRolesRoute _fromState(GoRouterState state) =>
      const ManagementRolesRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/roles',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementRoleDetailRoute on GoRouteData {
  static ManagementRoleDetailRoute _fromState(GoRouterState state) =>
      ManagementRoleDetailRoute(
        id: state.pathParameters['id']!,
      );

  ManagementRoleDetailRoute get _self => this as ManagementRoleDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/management/roles/${Uri.encodeComponent(_self.id)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementBranchesRoute on GoRouteData {
  static ManagementBranchesRoute _fromState(GoRouterState state) =>
      const ManagementBranchesRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/branches',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementBranchDetailRoute on GoRouteData {
  static ManagementBranchDetailRoute _fromState(GoRouterState state) =>
      ManagementBranchDetailRoute(
        id: state.pathParameters['id']!,
      );

  ManagementBranchDetailRoute get _self => this as ManagementBranchDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/management/branches/${Uri.encodeComponent(_self.id)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementMachinesRoute on GoRouteData {
  static ManagementMachinesRoute _fromState(GoRouterState state) =>
      const ManagementMachinesRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/machines',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementMachineDetailRoute on GoRouteData {
  static ManagementMachineDetailRoute _fromState(GoRouterState state) =>
      ManagementMachineDetailRoute(
        id: state.pathParameters['id']!,
      );

  ManagementMachineDetailRoute get _self =>
      this as ManagementMachineDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/management/machines/${Uri.encodeComponent(_self.id)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementStoragesRoute on GoRouteData {
  static ManagementStoragesRoute _fromState(GoRouterState state) =>
      const ManagementStoragesRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/storages',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementStorageDetailRoute on GoRouteData {
  static ManagementStorageDetailRoute _fromState(GoRouterState state) =>
      ManagementStorageDetailRoute(
        id: state.pathParameters['id']!,
      );

  ManagementStorageDetailRoute get _self =>
      this as ManagementStorageDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/management/storages/${Uri.encodeComponent(_self.id)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementProductCategoriesRoute on GoRouteData {
  static ManagementProductCategoriesRoute _fromState(GoRouterState state) =>
      const ManagementProductCategoriesRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/product-categories',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementProductCategoryDetailRoute on GoRouteData {
  static ManagementProductCategoryDetailRoute _fromState(GoRouterState state) =>
      ManagementProductCategoryDetailRoute(
        id: state.pathParameters['id']!,
      );

  ManagementProductCategoryDetailRoute get _self =>
      this as ManagementProductCategoryDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/management/product-categories/${Uri.encodeComponent(_self.id)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementQuantityUnitsRoute on GoRouteData {
  static ManagementQuantityUnitsRoute _fromState(GoRouterState state) =>
      const ManagementQuantityUnitsRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/quantity-units',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementQuantityUnitDetailRoute on GoRouteData {
  static ManagementQuantityUnitDetailRoute _fromState(GoRouterState state) =>
      ManagementQuantityUnitDetailRoute(
        id: state.pathParameters['id']!,
      );

  ManagementQuantityUnitDetailRoute get _self =>
      this as ManagementQuantityUnitDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/management/quantity-units/${Uri.encodeComponent(_self.id)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementCashierGroupsRoute on GoRouteData {
  static ManagementCashierGroupsRoute _fromState(GoRouterState state) =>
      const ManagementCashierGroupsRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/cashier-groups',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementCashierGroupDetailRoute on GoRouteData {
  static ManagementCashierGroupDetailRoute _fromState(GoRouterState state) =>
      ManagementCashierGroupDetailRoute(
        id: state.pathParameters['id']!,
      );

  ManagementCashierGroupDetailRoute get _self =>
      this as ManagementCashierGroupDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/management/cashier-groups/${Uri.encodeComponent(_self.id)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementImportRoute on GoRouteData {
  static ManagementImportRoute _fromState(GoRouterState state) =>
      const ManagementImportRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/import',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ManagementSettingsRoute on GoRouteData {
  static ManagementSettingsRoute _fromState(GoRouterState state) =>
      const ManagementSettingsRoute();

  @override
  String get location => GoRouteData.$location(
        '/management/settings',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
