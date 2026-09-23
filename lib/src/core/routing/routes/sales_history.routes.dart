import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/sales/presentation/pages/sale_detail_page.dart';
import '../../../features/sales/presentation/pages/sales_list_page.dart';
import '../../../features/sales/presentation/pages/sales_shell.dart';
import '../../utils/breakpoints.dart';

part 'sales_history.routes.g.dart';

/// Sales shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<SalesShellRoute>(
  routes: [
    TypedGoRoute<SalesHistoryRoute>(
      path: SalesHistoryRoute.path,
      routes: [
        TypedGoRoute<SaleDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class SalesShellRoute extends ShellRouteData {
  const SalesShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return SalesShell(child: navigator);
  }
}

/// Sales list page route.
class SalesHistoryRoute extends GoRouteData with $SalesHistoryRoute {
  const SalesHistoryRoute();

  static const path = '/sales';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, this is handled by the shell - return empty container
    // On mobile, this shows the list page
    if (Breakpoints.isMultiColumnOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const SalesListPage();
  }
}

/// Sale detail page route.
class SaleDetailRoute extends GoRouteData with $SaleDetailRoute {
  const SaleDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SaleDetailPage(saleId: id);
  }
}
