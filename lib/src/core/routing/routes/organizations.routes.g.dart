// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizations.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $organizationsRoute,
    ];

RouteBase get $organizationsRoute => GoRouteData.$route(
      path: '/organizations',
      factory: $OrganizationsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: ':id',
          factory: $OrganizationDetailRoute._fromState,
        ),
      ],
    );

mixin $OrganizationsRoute on GoRouteData {
  static OrganizationsRoute _fromState(GoRouterState state) =>
      const OrganizationsRoute();

  @override
  String get location => GoRouteData.$location(
        '/organizations',
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

mixin $OrganizationDetailRoute on GoRouteData {
  static OrganizationDetailRoute _fromState(GoRouterState state) =>
      OrganizationDetailRoute(
        id: state.pathParameters['id']!,
      );

  OrganizationDetailRoute get _self => this as OrganizationDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/organizations/${Uri.encodeComponent(_self.id)}',
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
