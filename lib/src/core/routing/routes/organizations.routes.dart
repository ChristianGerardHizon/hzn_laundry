import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/organizations/presentation/pages/organization_detail_page.dart';
import '../../../features/organizations/presentation/pages/organizations_page.dart';

part 'organizations.routes.g.dart';

/// Organizations tab — memberships, invites, and org details.
@TypedGoRoute<OrganizationsRoute>(
  path: OrganizationsRoute.path,
  routes: [
    TypedGoRoute<OrganizationDetailRoute>(path: ':id'),
  ],
)
class OrganizationsRoute extends GoRouteData with $OrganizationsRoute {
  const OrganizationsRoute();

  static const path = '/organizations';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizationsPage();
  }
}

class OrganizationDetailRoute extends GoRouteData
    with $OrganizationDetailRoute {
  const OrganizationDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OrganizationDetailPage(organizationId: id);
  }
}
