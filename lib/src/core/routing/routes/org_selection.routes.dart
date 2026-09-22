import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/organizations/presentation/pages/select_organization_page.dart';
import '../../../features/organizations/presentation/pages/super_admin_page.dart';
import '../../../features/organizations/presentation/pages/super_admin_shell.dart';
import '../../../features/subscriptions/presentation/widgets/billing_settings_tab.dart';
import '../../../features/subscriptions/presentation/widgets/packages_tab.dart';
import '../../../features/subscriptions/presentation/widgets/payments_tab.dart';

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

/// Platform super-admin hub shell (outside org/branch scope).
@TypedShellRoute<SuperAdminShellRoute>(
  routes: [
    TypedGoRoute<SuperAdminRoute>(
      path: SuperAdminRoute.path,
      routes: [
        TypedGoRoute<SuperAdminPackagesRoute>(
          path: SuperAdminPackagesRoute.relativePath,
        ),
        TypedGoRoute<SuperAdminPaymentsRoute>(
          path: SuperAdminPaymentsRoute.relativePath,
        ),
        TypedGoRoute<SuperAdminBillingRoute>(
          path: SuperAdminBillingRoute.relativePath,
        ),
      ],
    ),
  ],
)
class SuperAdminShellRoute extends ShellRouteData {
  const SuperAdminShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return SuperAdminShell(child: navigator);
  }
}

/// Super Admin dashboard (org KPIs + list).
class SuperAdminRoute extends GoRouteData with $SuperAdminRoute {
  const SuperAdminRoute();

  static const path = '/super-admin';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SuperAdminPage();
  }
}

/// Super Admin subscription packages.
class SuperAdminPackagesRoute extends GoRouteData
    with $SuperAdminPackagesRoute {
  const SuperAdminPackagesRoute();

  static const relativePath = 'packages';
  static const path = '${SuperAdminRoute.path}/$relativePath';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PackagesTab();
  }
}

/// Super Admin pending subscription payments.
class SuperAdminPaymentsRoute extends GoRouteData
    with $SuperAdminPaymentsRoute {
  const SuperAdminPaymentsRoute();

  static const relativePath = 'payments';
  static const path = '${SuperAdminRoute.path}/$relativePath';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PaymentsTab();
  }
}

/// Super Admin billing settings.
class SuperAdminBillingRoute extends GoRouteData with $SuperAdminBillingRoute {
  const SuperAdminBillingRoute();

  static const relativePath = 'billing';
  static const path = '${SuperAdminRoute.path}/$relativePath';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BillingSettingsTab();
  }
}
