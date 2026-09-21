import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/organizations/presentation/pages/select_organization_page.dart';
import '../../../features/organizations/presentation/pages/super_admin_page.dart';

part 'org_selection.routes.g.dart';

/// Post-login organization picker (1+ memberships).
@TypedGoRoute<SelectOrganizationRoute>(path: SelectOrganizationRoute.path)
class SelectOrganizationRoute extends GoRouteData
    with $SelectOrganizationRoute {
  const SelectOrganizationRoute();

  static const path = '/select-organization';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SelectOrganizationPage();
  }
}

/// Platform super-admin hub (outside org/branch scope).
@TypedGoRoute<SuperAdminRoute>(path: SuperAdminRoute.path)
class SuperAdminRoute extends GoRouteData with $SuperAdminRoute {
  const SuperAdminRoute();

  static const path = '/super-admin';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SuperAdminPage();
  }
}
