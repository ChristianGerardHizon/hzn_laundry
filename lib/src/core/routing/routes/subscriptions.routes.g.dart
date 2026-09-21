// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $subscriptionPayRoute,
    ];

RouteBase get $subscriptionPayRoute => GoRouteData.$route(
      path: '/subscription/pay/:organizationId',
      factory: $SubscriptionPayRoute._fromState,
    );

mixin $SubscriptionPayRoute on GoRouteData {
  static SubscriptionPayRoute _fromState(GoRouterState state) =>
      SubscriptionPayRoute(
        organizationId: state.pathParameters['organizationId']!,
      );

  SubscriptionPayRoute get _self => this as SubscriptionPayRoute;

  @override
  String get location => GoRouteData.$location(
        '/subscription/pay/${Uri.encodeComponent(_self.organizationId)}',
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
