// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activities.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $activitiesRoute,
    ];

RouteBase get $activitiesRoute => GoRouteData.$route(
      path: '/activities',
      factory: $ActivitiesRoute._fromState,
    );

mixin $ActivitiesRoute on GoRouteData {
  static ActivitiesRoute _fromState(GoRouterState state) =>
      const ActivitiesRoute();

  @override
  String get location => GoRouteData.$location(
        '/activities',
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
