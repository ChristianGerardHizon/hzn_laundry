import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/organizations/presentation/pages/create_organization_page.dart';
import '../../../features/organizations/presentation/pages/organization_setup_walkthrough_page.dart';
import '../../../features/organizations/presentation/pages/organizations_page.dart';

part 'organizations.routes.g.dart';

/// Organizations tab — memberships, invites, and org details.
@TypedGoRoute<OrganizationsRoute>(
  path: OrganizationsRoute.path,
  routes: [
    TypedGoRoute<CreateOrganizationRoute>(path: 'create'),
    TypedGoRoute<OrganizationSetupRoute>(path: 'setup/:id'),
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

class CreateOrganizationRoute extends GoRouteData
    with $CreateOrganizationRoute {
  const CreateOrganizationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CreateOrganizationPage();
  }
}

class OrganizationSetupRoute extends GoRouteData with $OrganizationSetupRoute {
  const OrganizationSetupRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OrganizationSetupWalkthroughPage(orgId: id);
  }
}
