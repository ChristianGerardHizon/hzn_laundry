// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_selection.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $selectOrganizationRoute,
      $superAdminShellRoute,
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

RouteBase get $superAdminShellRoute => ShellRouteData.$route(
      factory: $SuperAdminShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/super-admin',
          factory: $SuperAdminRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'packages',
              factory: $SuperAdminPackagesRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'payments',
              factory: $SuperAdminPaymentsRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'billing',
              factory: $SuperAdminBillingRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $SuperAdminShellRouteExtension on SuperAdminShellRoute {
  static SuperAdminShellRoute _fromState(GoRouterState state) =>
      const SuperAdminShellRoute();
}

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

mixin $SuperAdminPackagesRoute on GoRouteData {
  static SuperAdminPackagesRoute _fromState(GoRouterState state) =>
      const SuperAdminPackagesRoute();

  @override
  String get location => GoRouteData.$location(
        '/super-admin/packages',
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

mixin $SuperAdminPaymentsRoute on GoRouteData {
  static SuperAdminPaymentsRoute _fromState(GoRouterState state) =>
      const SuperAdminPaymentsRoute();

  @override
  String get location => GoRouteData.$location(
        '/super-admin/payments',
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

mixin $SuperAdminBillingRoute on GoRouteData {
  static SuperAdminBillingRoute _fromState(GoRouterState state) =>
      const SuperAdminBillingRoute();

  @override
  String get location => GoRouteData.$location(
        '/super-admin/billing',
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
