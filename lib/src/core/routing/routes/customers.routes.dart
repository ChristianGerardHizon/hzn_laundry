import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../../features/customers/presentation/pages/customers_list_page.dart';
import '../../../features/customers/presentation/pages/customers_shell.dart';
import '../../utils/breakpoints.dart';

part 'customers.routes.g.dart';

/// Customers shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<CustomersShellRoute>(
  routes: [
    TypedGoRoute<CustomersRoute>(
      path: CustomersRoute.path,
      routes: [
        TypedGoRoute<CustomerDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class CustomersShellRoute extends ShellRouteData {
  const CustomersShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return CustomersShell(child: navigator);
  }
}

/// Customers list page route.
class CustomersRoute extends GoRouteData with $CustomersRoute {
  const CustomersRoute();

  static const path = '/customers';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, this is handled by the shell - return empty container
    // On mobile, this shows the list page
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const CustomersListPage();
  }
}

/// Customer detail page route.
class CustomerDetailRoute extends GoRouteData with $CustomerDetailRoute {
  const CustomerDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CustomerDetailPage(customerId: id);
  }
}
