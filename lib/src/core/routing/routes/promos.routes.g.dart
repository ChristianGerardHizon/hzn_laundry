// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promos.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $promosShellRoute,
    ];

RouteBase get $promosShellRoute => ShellRouteData.$route(
      factory: $PromosShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/promos',
          factory: $PromosRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $PromoDetailRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $PromosShellRouteExtension on PromosShellRoute {
  static PromosShellRoute _fromState(GoRouterState state) =>
      const PromosShellRoute();
}

mixin $PromosRoute on GoRouteData {
  static PromosRoute _fromState(GoRouterState state) => const PromosRoute();

  @override
  String get location => GoRouteData.$location(
        '/promos',
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

mixin $PromoDetailRoute on GoRouteData {
  static PromoDetailRoute _fromState(GoRouterState state) => PromoDetailRoute(
        id: state.pathParameters['id']!,
      );

  PromoDetailRoute get _self => this as PromoDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/promos/${Uri.encodeComponent(_self.id)}',
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
