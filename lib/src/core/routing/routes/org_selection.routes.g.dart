// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_selection.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $selectOrganizationRoute,
      $superAdminRoute,
    ];

RouteBase get $selectOrganizationRoute => GoRouteData.$route(
      path: '/select-organization',
      factory: $SelectOrganizationRoute._fromState,
    );

mixin $SelectOrganizationRoute on GoRouteData {
  static SelectOrganizationRoute _fromState(GoRouterState state) =>
      const SelectOrganizationRoute();

  @override
  String get location => GoRouteData.$location(
        '/select-organization',
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

RouteBase get $superAdminRoute => GoRouteData.$route(
      path: '/super-admin',
      factory: $SuperAdminRoute._fromState,
    );

mixin $SuperAdminRoute on GoRouteData {
  static SuperAdminRoute _fromState(GoRouterState state) =>
      const SuperAdminRoute();

  @override
  String get location => GoRouteData.$location(
        '/super-admin',
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
