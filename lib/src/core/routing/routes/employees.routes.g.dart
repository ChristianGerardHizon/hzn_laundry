// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employees.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $employeesShellRoute,
    ];

RouteBase get $employeesShellRoute => ShellRouteData.$route(
      factory: $EmployeesShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/employees',
          factory: $EmployeesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $EmployeeDetailRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $EmployeesShellRouteExtension on EmployeesShellRoute {
  static EmployeesShellRoute _fromState(GoRouterState state) =>
      const EmployeesShellRoute();
}

mixin $EmployeesRoute on GoRouteData {
  static EmployeesRoute _fromState(GoRouterState state) =>
      const EmployeesRoute();

  @override
  String get location => GoRouteData.$location(
        '/employees',
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

mixin $EmployeeDetailRoute on GoRouteData {
  static EmployeeDetailRoute _fromState(GoRouterState state) =>
      EmployeeDetailRoute(
        id: state.pathParameters['id']!,
      );

  EmployeeDetailRoute get _self => this as EmployeeDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/employees/${Uri.encodeComponent(_self.id)}',
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
