import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/products/domain/product_tab.dart';
import '../../../features/products/presentation/pages/product_detail_page.dart';
import '../../../features/products/presentation/pages/products_list_page.dart';
import '../../../features/products/presentation/pages/products_shell.dart';
import '../../utils/breakpoints.dart';

part 'products.routes.g.dart';

/// Products shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<ProductsShellRoute>(
  routes: [
    TypedGoRoute<ProductsRoute>(
      path: ProductsRoute.path,
      routes: [
        TypedGoRoute<ProductDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class ProductsShellRoute extends ShellRouteData {
  const ProductsShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return ProductsShell(child: navigator);
  }
}

/// Products list page route.
class ProductsRoute extends GoRouteData with $ProductsRoute {
  const ProductsRoute();

  static const path = '/products';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, this is handled by the shell - return empty container
    // On mobile, this shows the list page
    if (Breakpoints.isMultiColumnOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const ProductsListPage();
  }
}

/// Product detail page route.
class ProductDetailRoute extends GoRouteData with $ProductDetailRoute {
  const ProductDetailRoute({required this.id, this.tab});

  final String id;
  final String? tab;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final tabName = state.uri.queryParameters['tab'];
    return ProductDetailPage(
      productId: id,
      initialTab: ProductTab.fromString(tabName),
    );
  }
}
