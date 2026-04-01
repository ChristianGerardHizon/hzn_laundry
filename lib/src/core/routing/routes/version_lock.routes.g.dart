// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_lock.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $forceUpdateRoute,
      $webUpdateRoute,
    ];

RouteBase get $forceUpdateRoute => GoRouteData.$route(
      path: '/force-update',
      factory: $ForceUpdateRoute._fromState,
    );

mixin $ForceUpdateRoute on GoRouteData {
  static ForceUpdateRoute _fromState(GoRouterState state) =>
      const ForceUpdateRoute();

  @override
  String get location => GoRouteData.$location(
        '/force-update',
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

RouteBase get $webUpdateRoute => GoRouteData.$route(
      path: '/web-update',
      factory: $WebUpdateRoute._fromState,
    );

mixin $WebUpdateRoute on GoRouteData {
  static WebUpdateRoute _fromState(GoRouterState state) =>
      const WebUpdateRoute();

  @override
  String get location => GoRouteData.$location(
        '/web-update',
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
