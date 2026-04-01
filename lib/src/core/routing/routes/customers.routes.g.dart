// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $customersShellRoute,
    ];

RouteBase get $customersShellRoute => ShellRouteData.$route(
      factory: $CustomersShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/customers',
          factory: $CustomersRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $CustomerDetailRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $CustomersShellRouteExtension on CustomersShellRoute {
  static CustomersShellRoute _fromState(GoRouterState state) =>
      const CustomersShellRoute();
}

mixin $CustomersRoute on GoRouteData {
  static CustomersRoute _fromState(GoRouterState state) =>
      const CustomersRoute();

  @override
  String get location => GoRouteData.$location(
        '/customers',
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

mixin $CustomerDetailRoute on GoRouteData {
  static CustomerDetailRoute _fromState(GoRouterState state) =>
      CustomerDetailRoute(
        id: state.pathParameters['id']!,
      );

  CustomerDetailRoute get _self => this as CustomerDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/customers/${Uri.encodeComponent(_self.id)}',
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
