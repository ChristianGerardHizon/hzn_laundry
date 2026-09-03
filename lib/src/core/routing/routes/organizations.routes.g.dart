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
          path: 'create',
          factory: $CreateOrganizationRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'setup/:id',
          factory: $OrganizationSetupRoute._fromState,
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

mixin $CreateOrganizationRoute on GoRouteData {
  static CreateOrganizationRoute _fromState(GoRouterState state) =>
      const CreateOrganizationRoute();

  @override
  String get location => GoRouteData.$location(
        '/organizations/create',
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

mixin $OrganizationSetupRoute on GoRouteData {
  static OrganizationSetupRoute _fromState(GoRouterState state) =>
      OrganizationSetupRoute(
        id: state.pathParameters['id']!,
      );

  OrganizationSetupRoute get _self => this as OrganizationSetupRoute;

  @override
  String get location => GoRouteData.$location(
        '/organizations/setup/${Uri.encodeComponent(_self.id)}',
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
