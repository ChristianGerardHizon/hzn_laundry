import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/services/presentation/pages/service_detail_page.dart';
import '../../../features/services/presentation/pages/services_list_page.dart';
import '../../../features/services/presentation/pages/services_shell.dart';
import '../../utils/breakpoints.dart';

part 'services.routes.g.dart';

/// Services shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<ServicesShellRoute>(
  routes: [
    TypedGoRoute<ServicesRoute>(
      path: ServicesRoute.path,
      routes: [
        TypedGoRoute<ServiceDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class ServicesShellRoute extends ShellRouteData {
  const ServicesShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return ServicesShell(child: navigator);
  }
}

/// Services list page route.
class ServicesRoute extends GoRouteData with $ServicesRoute {
  const ServicesRoute();

  static const path = '/services';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, this is handled by the shell - return empty container
    // On mobile, this shows the list page
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const ServicesListPage();
  }
}

/// Service detail page route.
class ServiceDetailRoute extends GoRouteData with $ServiceDetailRoute {
  const ServiceDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ServiceDetailPage(serviceId: id);
  }
}
