// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_history.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $customerHistoryRoute,
    ];

RouteBase get $customerHistoryRoute => GoRouteData.$route(
      path: '/history/:token',
      factory: $CustomerHistoryRoute._fromState,
    );

mixin $CustomerHistoryRoute on GoRouteData {
  static CustomerHistoryRoute _fromState(GoRouterState state) =>
      CustomerHistoryRoute(
        token: state.pathParameters['token']!,
      );

  CustomerHistoryRoute get _self => this as CustomerHistoryRoute;

  @override
  String get location => GoRouteData.$location(
        '/history/${Uri.encodeComponent(_self.token)}',
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
