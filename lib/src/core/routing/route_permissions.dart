import '../../features/users/domain/user_role.dart';
import '../routing/routes/activities.routes.dart';
import '../routing/routes/customers.routes.dart';
import '../routing/routes/dashboard.routes.dart';
import '../routing/routes/employees.routes.dart';
import '../routing/routes/management.routes.dart';
import '../routing/routes/organizations.routes.dart';
import '../routing/routes/products.routes.dart';
import '../routing/routes/promos.routes.dart';
import '../routing/routes/reports.routes.dart';
import '../routing/routes/sales.routes.dart';
import '../routing/routes/sales_history.routes.dart';
import '../routing/routes/services.routes.dart';
import '../routing/routes/system.routes.dart';

/// Flat (unscoped) paths that belong under the org/branch AppRoot shell.
const List<String> scopedAppPaths = [
  DashboardRoute.path,
  SalesHistoryRoute.path,
  ProductsRoute.path,
  ServicesRoute.path,
  CustomersRoute.path,
  EmployeesRoute.path,
  ReportsRoute.path,
  ActivitiesRoute.path,
  ManagementRoute.path,
  OrganizationsRoute.path,
  PromosRoute.path,
  SystemRoute.path,
  SalesRoute.path, // /cashier — in shell, not in bottom nav
];

/// True when [location] is [path] or a nested path under it (`/path/...`).
bool matchesRoutePath(String location, String path) {
  if (path == DashboardRoute.path) {
    return location == path || location == DashboardRoute.path;
  }
  return location == path || location.startsWith('$path/');
}

/// Whether an unscoped [location] is allowed for [role].
bool canAccessPath(String location, UserRole? role) {
  if (location == DashboardRoute.path ||
      matchesRoutePath(location, OrganizationsRoute.path)) {
    return true;
  }

  // No role yet — allow through; AppRoot filters nav while loading.
  if (role == null) return true;
  if (role.isAdmin) return true;

  bool requires(String permission) => role.hasPermission(permission);

  if (matchesRoutePath(location, SalesHistoryRoute.path)) {
    return requires(Permissions.salesView);
  }
  if (matchesRoutePath(location, SalesRoute.path)) {
    return requires(Permissions.salesCreate) || requires(Permissions.salesView);
  }
  if (matchesRoutePath(location, ProductsRoute.path)) {
    return requires(Permissions.productsView);
  }
  if (matchesRoutePath(location, ServicesRoute.path)) {
    return requires(Permissions.servicesView);
  }
  if (matchesRoutePath(location, CustomersRoute.path)) {
    return requires(Permissions.customersView);
  }
  if (matchesRoutePath(location, EmployeesRoute.path)) {
    return requires(Permissions.employeesView);
  }
  if (matchesRoutePath(location, ReportsRoute.path)) {
    return requires(Permissions.reportsView);
  }
  if (matchesRoutePath(location, ActivitiesRoute.path)) {
    return requires(Permissions.systemAdmin);
  }
  if (matchesRoutePath(location, ManagementRoute.path)) {
    return requires(Permissions.branchesView);
  }
  if (matchesRoutePath(location, PromosRoute.path)) {
    return requires(Permissions.systemAdmin);
  }
  if (matchesRoutePath(location, SystemRoute.path)) {
    // Appearance is available to every signed-in user.
    if (location == SystemRoute.path ||
        location.startsWith('${SystemRoute.path}/appearance')) {
      return true;
    }
    return requires(Permissions.settingsView);
  }
  return true;
}

/// First allowed shell path for [role] (unscoped).
String fallbackPathFor(UserRole? role) {
  for (final path in scopedAppPaths) {
    if (path == SalesRoute.path) continue; // skip cashier as home fallback
    if (canAccessPath(path, role)) return path;
  }
  return DashboardRoute.path;
}
