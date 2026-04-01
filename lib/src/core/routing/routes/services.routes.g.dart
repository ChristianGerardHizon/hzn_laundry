// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $servicesShellRoute,
    ];

RouteBase get $servicesShellRoute => ShellRouteData.$route(
      factory: $ServicesShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/services',
          factory: $ServicesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $ServiceDetailRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $ServicesShellRouteExtension on ServicesShellRoute {
  static ServicesShellRoute _fromState(GoRouterState state) =>
      const ServicesShellRoute();
}

mixin $ServicesRoute on GoRouteData {
  static ServicesRoute _fromState(GoRouterState state) => const ServicesRoute();

  @override
  String get location => GoRouteData.$location(
        '/services',
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

mixin $ServiceDetailRoute on GoRouteData {
  static ServiceDetailRoute _fromState(GoRouterState state) =>
      ServiceDetailRoute(
        id: state.pathParameters['id']!,
      );

  ServiceDetailRoute get _self => this as ServiceDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/services/${Uri.encodeComponent(_self.id)}',
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
