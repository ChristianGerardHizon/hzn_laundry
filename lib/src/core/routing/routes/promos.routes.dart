import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/promos/presentation/pages/promo_detail_page.dart';
import '../../../features/promos/presentation/pages/promos_list_page.dart';
import '../../../features/promos/presentation/pages/promos_shell.dart';
import '../../utils/breakpoints.dart';

part 'promos.routes.g.dart';

/// Promos shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<PromosShellRoute>(
  routes: [
    TypedGoRoute<PromosRoute>(
      path: PromosRoute.path,
      routes: [
        TypedGoRoute<PromoDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class PromosShellRoute extends ShellRouteData {
  const PromosShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return PromosShell(child: navigator);
  }
}

/// Promos list page route.
class PromosRoute extends GoRouteData with $PromosRoute {
  const PromosRoute();

  static const path = '/promos';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const PromosListPage();
  }
}

/// Promo detail page route.
class PromoDetailRoute extends GoRouteData with $PromoDetailRoute {
  const PromoDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PromoDetailPage(promoId: id);
  }
}
