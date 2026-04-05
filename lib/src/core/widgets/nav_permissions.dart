import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/users/domain/user_role.dart';
import '../../features/users/presentation/controllers/user_provider.dart';
import '../../features/users/presentation/controllers/user_role_provider.dart';

part 'nav_permissions.g.dart';

/// A navigation destination with its required permission.
class NavItem {
  const NavItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.requiredPermission,
  });

  /// Original route index in AppRoot._routes.
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// The permission key required to view this nav item.
  /// Null means always visible (e.g. dashboard).
  final String? requiredPermission;
}

/// All nav items with their permission requirements.
/// Order matches AppRoot._routePaths / _routes.
List<NavItem> buildAllNavItems(String Function(String key) t) => [
      NavItem(
        index: 0,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: t('dashboard'),
        // Dashboard is always visible
      ),
      NavItem(
        index: 1,
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        label: t('salesHistory'),
        requiredPermission: Permissions.salesView,
      ),
      NavItem(
        index: 2,
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: t('products'),
        requiredPermission: Permissions.productsView,
      ),
      NavItem(
        index: 3,
        icon: Icons.miscellaneous_services_outlined,
        selectedIcon: Icons.miscellaneous_services,
        label: t('services'),
        requiredPermission: Permissions.servicesView,
      ),
      NavItem(
        index: 4,
        icon: Icons.people_outlined,
        selectedIcon: Icons.people,
        label: t('customers'),
        requiredPermission: Permissions.customersView,
      ),
      NavItem(
        index: 5,
        icon: Icons.badge_outlined,
        selectedIcon: Icons.badge,
        label: t('employees'),
        requiredPermission: Permissions.employeesView,
      ),
      NavItem(
        index: 6,
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
        label: t('reports'),
        requiredPermission: Permissions.reportsView,
      ),
      NavItem(
        index: 7,
        icon: Icons.history_outlined,
        selectedIcon: Icons.history,
        label: t('activities'),
        requiredPermission: Permissions.systemAdmin,
      ),
      NavItem(
        index: 8,
        icon: Icons.business_outlined,
        selectedIcon: Icons.business,
        label: t('organization'),
        requiredPermission: Permissions.branchesView,
      ),
      NavItem(
        index: 9,
        icon: Icons.loyalty_outlined,
        selectedIcon: Icons.loyalty,
        label: 'Promos',
        requiredPermission: Permissions.systemAdmin,
      ),
      NavItem(
        index: 10,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: t('system'),
        requiredPermission: Permissions.settingsView,
      ),
    ];

/// Provides the current user's role (resolved from auth -> user -> role chain).
@riverpod
Future<UserRole?> currentUserRole(Ref ref) async {
  final auth = ref.watch(currentAuthProvider);
  if (auth == null) return null;

  final user = await ref.watch(userProvider(auth.user.id).future);
  if (user == null || user.roleId == null || user.roleId!.isEmpty) {
    return null;
  }

  return ref.watch(userRoleProvider(user.roleId!).future);
}

/// Filters nav items based on the user's permissions.
/// Admins see everything. Others see only items they have permission for.
List<NavItem> filterNavItems(List<NavItem> allItems, UserRole? role) {
  if (role == null) return allItems; // No role loaded yet, show all
  if (role.isAdmin) return allItems;

  return allItems.where((item) {
    if (item.requiredPermission == null) return true;
    return role.hasPermission(item.requiredPermission!);
  }).toList();
}
