import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import 'permission.dart';

part 'user_role.mapper.dart';

/// UserRole domain model.
///
/// Role definitions with permissions for access control.
/// Permissions are stored as a JSON array of permission keys in PocketBase.
@MappableClass()
class UserRole with UserRoleMappable {
  const UserRole({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const [],
    this.isSystem = false,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Role name (e.g., "Admin", "Manager", "Cashier", "Attendant").
  final String name;

  /// Role description.
  final String? description;

  /// List of permission keys (stored as JSON array in PocketBase).
  final List<String> permissions;

  /// Whether this is a system-defined role (cannot be deleted).
  final bool isSystem;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Check if role has a specific permission.
  bool hasPermission(String permission) => permissions.contains(permission);

  /// Check if role has admin permission.
  bool get isAdmin => permissions.contains('system.admin');

  /// Get permission count display.
  String get permissionCountDisplay =>
      '${permissions.length} permission${permissions.length == 1 ? '' : 's'}';

  /// Get the Permission objects for this role's permissions.
  List<Permission> get permissionObjects =>
      Permissions.getPermissions(permissions);

  /// Get permissions grouped by category.
  Map<String, List<Permission>> get permissionsByCategory {
    final map = <String, List<Permission>>{};
    for (final perm in permissionObjects) {
      map.putIfAbsent(perm.category, () => []).add(perm);
    }
    return map;
  }

  /// Check if role has all permissions in a category.
  bool hasAllInCategory(String category) {
    final categoryPerms = Permissions.allByCategory[category] ?? [];
    return categoryPerms.every((p) => permissions.contains(p));
  }

  /// Get the count of permissions in a specific category.
  int permissionCountInCategory(String category) {
    final categoryPerms = Permissions.allByCategory[category] ?? [];
    return categoryPerms.where((p) => permissions.contains(p)).length;
  }
}

/// Permission keys used in the system.
abstract class Permissions {
  // Customers permissions
  static const customersView = 'customers.view';
  static const customersCreate = 'customers.create';
  static const customersEdit = 'customers.edit';
  static const customersDelete = 'customers.delete';

  // Products permissions
  static const productsView = 'products.view';
  static const productsCreate = 'products.create';
  static const productsEdit = 'products.edit';
  static const productsDelete = 'products.delete';

  // Services permissions
  static const servicesView = 'services.view';
  static const servicesCreate = 'services.create';
  static const servicesEdit = 'services.edit';
  static const servicesDelete = 'services.delete';

  // Inventory permissions
  static const inventoryView = 'inventory.view';
  static const inventoryAdjust = 'inventory.adjust';

  // Sales permissions
  static const salesView = 'sales.view';
  static const salesCreate = 'sales.create';

  // Payments permissions
  static const paymentsEdit = 'payments.edit';
  static const paymentsVoid = 'payments.void';

  // Machines permissions
  static const machinesView = 'machines.view';
  static const machinesCreate = 'machines.create';
  static const machinesEdit = 'machines.edit';
  static const machinesDelete = 'machines.delete';

  // Storages permissions
  static const storagesView = 'storages.view';
  static const storagesCreate = 'storages.create';
  static const storagesEdit = 'storages.edit';
  static const storagesDelete = 'storages.delete';

  // Employees permissions
  static const employeesView = 'employees.view';
  static const employeesCreate = 'employees.create';
  static const employeesEdit = 'employees.edit';
  static const employeesDelete = 'employees.delete';

  // Attendance permissions
  static const attendanceView = 'attendance.view';
  static const attendanceCreate = 'attendance.create';
  static const attendanceEdit = 'attendance.edit';

  // Reports permissions
  static const reportsView = 'reports.view';

  // Users permissions
  static const usersView = 'users.view';
  static const usersCreate = 'users.create';
  static const usersEdit = 'users.edit';
  static const usersDelete = 'users.delete';

  // Roles permissions
  static const rolesView = 'roles.view';
  static const rolesCreate = 'roles.create';
  static const rolesEdit = 'roles.edit';
  static const rolesDelete = 'roles.delete';

  // Branches permissions
  static const branchesView = 'branches.view';
  static const branchesCreate = 'branches.create';
  static const branchesEdit = 'branches.edit';
  static const branchesDelete = 'branches.delete';

  // Settings permissions
  static const settingsView = 'settings.view';
  static const settingsEdit = 'settings.edit';

  // Incentive permissions
  static const incentiveView = 'incentive.view';

  // Dashboard permissions
  static const dashboardDateOverride = 'dashboard.dateOverride';

  // System permissions
  static const systemAdmin = 'system.admin';

  /// All permissions grouped by category (keys only).
  static const Map<String, List<String>> allByCategory = {
    'Customers': [
      customersView,
      customersCreate,
      customersEdit,
      customersDelete,
    ],
    'Products': [productsView, productsCreate, productsEdit, productsDelete],
    'Services': [servicesView, servicesCreate, servicesEdit, servicesDelete],
    'Inventory': [inventoryView, inventoryAdjust],
    'Sales': [salesView, salesCreate],
    'Payments': [paymentsEdit, paymentsVoid],
    'Machines': [machinesView, machinesCreate, machinesEdit, machinesDelete],
    'Storages': [storagesView, storagesCreate, storagesEdit, storagesDelete],
    'Employees': [
      employeesView,
      employeesCreate,
      employeesEdit,
      employeesDelete,
    ],
    'Attendance': [attendanceView, attendanceCreate, attendanceEdit],
    'Reports': [reportsView],
    'Users': [usersView, usersCreate, usersEdit, usersDelete],
    'Roles': [rolesView, rolesCreate, rolesEdit, rolesDelete],
    'Branches': [branchesView, branchesCreate, branchesEdit, branchesDelete],
    'Settings': [settingsView, settingsEdit],
    'Incentive': [incentiveView],
    'Dashboard': [dashboardDateOverride],
    'System': [systemAdmin],
  };

  /// All permissions with full metadata.
  static final List<Permission> all = _buildPermissionList();

  /// Permissions grouped by category as Permission objects.
  static final Map<String, List<Permission>> allPermissionsByCategory =
      _buildPermissionsByCategory();

  /// Get a Permission by its key.
  static Permission? getByKey(String key) {
    try {
      return all.firstWhere((p) => p.key == key);
    } catch (_) {
      return null;
    }
  }

  /// Get all Permission objects for a list of keys.
  static List<Permission> getPermissions(List<String> keys) {
    return keys.map(getByKey).whereType<Permission>().toList();
  }

  /// Get display name for a permission key.
  static String displayName(String permission) {
    // First try to get from Permission object
    final perm = getByKey(permission);
    if (perm != null) return perm.name;

    // Fallback to computed display name
    final parts = permission.split('.');
    if (parts.length != 2) return permission;
    final action = parts[1];
    return action[0].toUpperCase() + action.substring(1);
  }

  /// Private: Build the full permission list with metadata.
  static List<Permission> _buildPermissionList() {
    return [
      // Customers
      const Permission(
        key: customersView,
        name: 'View Customers',
        category: 'Customers',
        description: 'View customer profiles and information',
        icon: Icons.visibility,
      ),
      const Permission(
        key: customersCreate,
        name: 'Create Customers',
        category: 'Customers',
        description: 'Register new customers',
        icon: Icons.person_add,
      ),
      const Permission(
        key: customersEdit,
        name: 'Edit Customers',
        category: 'Customers',
        description: 'Modify existing customer information',
        icon: Icons.edit,
      ),
      const Permission(
        key: customersDelete,
        name: 'Delete Customers',
        category: 'Customers',
        description: 'Remove customer records (soft delete)',
        icon: Icons.delete,
      ),
      // Products
      const Permission(
        key: productsView,
        name: 'View Products',
        category: 'Products',
        description: 'View product catalog',
        icon: Icons.visibility,
      ),
      const Permission(
        key: productsCreate,
        name: 'Create Products',
        category: 'Products',
        description: 'Add new products to catalog',
        icon: Icons.add,
      ),
      const Permission(
        key: productsEdit,
        name: 'Edit Products',
        category: 'Products',
        description: 'Modify product information',
        icon: Icons.edit,
      ),
      const Permission(
        key: productsDelete,
        name: 'Delete Products',
        category: 'Products',
        description: 'Remove products from catalog',
        icon: Icons.delete,
      ),
      // Services
      const Permission(
        key: servicesView,
        name: 'View Services',
        category: 'Services',
        description: 'View laundry service catalog',
        icon: Icons.visibility,
      ),
      const Permission(
        key: servicesCreate,
        name: 'Create Services',
        category: 'Services',
        description: 'Add new laundry services',
        icon: Icons.add,
      ),
      const Permission(
        key: servicesEdit,
        name: 'Edit Services',
        category: 'Services',
        description: 'Modify service information and pricing',
        icon: Icons.edit,
      ),
      const Permission(
        key: servicesDelete,
        name: 'Delete Services',
        category: 'Services',
        description: 'Remove services (soft delete)',
        icon: Icons.delete,
      ),
      // Inventory
      const Permission(
        key: inventoryView,
        name: 'View Inventory',
        category: 'Inventory',
        description: 'View inventory levels and stock',
        icon: Icons.visibility,
      ),
      const Permission(
        key: inventoryAdjust,
        name: 'Adjust Inventory',
        category: 'Inventory',
        description: 'Make inventory adjustments',
        icon: Icons.tune,
      ),
      // Sales
      const Permission(
        key: salesView,
        name: 'View Sales',
        category: 'Sales',
        description: 'View sales history and reports',
        icon: Icons.visibility,
      ),
      const Permission(
        key: salesCreate,
        name: 'Create Sales',
        category: 'Sales',
        description: 'Process sales transactions',
        icon: Icons.add,
      ),
      // Payments
      const Permission(
        key: paymentsEdit,
        name: 'Edit Payments',
        category: 'Payments',
        description: 'Edit payment details including date',
        icon: Icons.edit,
      ),
      const Permission(
        key: paymentsVoid,
        name: 'Void Payments',
        category: 'Payments',
        description: 'Void recorded payments without deleting their history',
        icon: Icons.block,
      ),
      // Machines
      const Permission(
        key: machinesView,
        name: 'View Machines',
        category: 'Machines',
        description: 'View laundry machines and availability',
        icon: Icons.visibility,
      ),
      const Permission(
        key: machinesCreate,
        name: 'Create Machines',
        category: 'Machines',
        description: 'Add new laundry machines',
        icon: Icons.add,
      ),
      const Permission(
        key: machinesEdit,
        name: 'Edit Machines',
        category: 'Machines',
        description: 'Modify machine information and status',
        icon: Icons.edit,
      ),
      const Permission(
        key: machinesDelete,
        name: 'Delete Machines',
        category: 'Machines',
        description: 'Remove machines (soft delete)',
        icon: Icons.delete,
      ),
      // Storages
      const Permission(
        key: storagesView,
        name: 'View Storages',
        category: 'Storages',
        description: 'View storage locations',
        icon: Icons.visibility,
      ),
      const Permission(
        key: storagesCreate,
        name: 'Create Storages',
        category: 'Storages',
        description: 'Add new storage locations',
        icon: Icons.add,
      ),
      const Permission(
        key: storagesEdit,
        name: 'Edit Storages',
        category: 'Storages',
        description: 'Modify storage location information',
        icon: Icons.edit,
      ),
      const Permission(
        key: storagesDelete,
        name: 'Delete Storages',
        category: 'Storages',
        description: 'Remove storage locations (soft delete)',
        icon: Icons.delete,
      ),
      // Employees
      const Permission(
        key: employeesView,
        name: 'View Employees',
        category: 'Employees',
        description: 'View employee profiles and information',
        icon: Icons.visibility,
      ),
      const Permission(
        key: employeesCreate,
        name: 'Create Employees',
        category: 'Employees',
        description: 'Add new employees',
        icon: Icons.person_add,
      ),
      const Permission(
        key: employeesEdit,
        name: 'Edit Employees',
        category: 'Employees',
        description: 'Modify employee information',
        icon: Icons.edit,
      ),
      const Permission(
        key: employeesDelete,
        name: 'Delete Employees',
        category: 'Employees',
        description: 'Remove employee records (soft delete)',
        icon: Icons.delete,
      ),
      // Attendance
      const Permission(
        key: attendanceView,
        name: 'View Attendance',
        category: 'Attendance',
        description: 'View employee attendance records',
        icon: Icons.visibility,
      ),
      const Permission(
        key: attendanceCreate,
        name: 'Create Attendance',
        category: 'Attendance',
        description: 'Record employee attendance (clock in/out)',
        icon: Icons.add,
      ),
      const Permission(
        key: attendanceEdit,
        name: 'Edit Attendance',
        category: 'Attendance',
        description: 'Modify attendance records',
        icon: Icons.edit,
      ),
      // Reports
      const Permission(
        key: reportsView,
        name: 'View Reports',
        category: 'Reports',
        description: 'View sales reports and analytics',
        icon: Icons.bar_chart,
      ),
      // Users
      const Permission(
        key: usersView,
        name: 'View Users',
        category: 'Users',
        description: 'View user accounts',
        icon: Icons.visibility,
      ),
      const Permission(
        key: usersCreate,
        name: 'Create Users',
        category: 'Users',
        description: 'Create new user accounts',
        icon: Icons.person_add,
      ),
      const Permission(
        key: usersEdit,
        name: 'Edit Users',
        category: 'Users',
        description: 'Modify user account details',
        icon: Icons.edit,
      ),
      const Permission(
        key: usersDelete,
        name: 'Delete Users',
        category: 'Users',
        description: 'Deactivate user accounts',
        icon: Icons.person_remove,
      ),
      // Roles
      const Permission(
        key: rolesView,
        name: 'View Roles',
        category: 'Roles',
        description: 'View role definitions',
        icon: Icons.visibility,
      ),
      const Permission(
        key: rolesCreate,
        name: 'Create Roles',
        category: 'Roles',
        description: 'Create new roles',
        icon: Icons.add,
      ),
      const Permission(
        key: rolesEdit,
        name: 'Edit Roles',
        category: 'Roles',
        description: 'Modify role permissions',
        icon: Icons.edit,
      ),
      const Permission(
        key: rolesDelete,
        name: 'Delete Roles',
        category: 'Roles',
        description: 'Remove roles (non-system only)',
        icon: Icons.delete,
      ),
      // Branches
      const Permission(
        key: branchesView,
        name: 'View Branches',
        category: 'Branches',
        description: 'View branch locations',
        icon: Icons.visibility,
      ),
      const Permission(
        key: branchesCreate,
        name: 'Create Branches',
        category: 'Branches',
        description: 'Add new branch locations',
        icon: Icons.add,
      ),
      const Permission(
        key: branchesEdit,
        name: 'Edit Branches',
        category: 'Branches',
        description: 'Modify branch information',
        icon: Icons.edit,
      ),
      const Permission(
        key: branchesDelete,
        name: 'Delete Branches',
        category: 'Branches',
        description: 'Remove branch locations',
        icon: Icons.delete,
      ),
      // Settings
      const Permission(
        key: settingsView,
        name: 'View Settings',
        category: 'Settings',
        description: 'View system settings',
        icon: Icons.visibility,
      ),
      const Permission(
        key: settingsEdit,
        name: 'Edit Settings',
        category: 'Settings',
        description: 'Modify system settings',
        icon: Icons.edit,
      ),
      // Incentive
      const Permission(
        key: incentiveView,
        name: 'View Incentive',
        category: 'Incentive',
        description: "View today's incentive KPI and incentive breakdown on the dashboard",
        icon: Icons.payments,
      ),
      // Dashboard
      const Permission(
        key: dashboardDateOverride,
        name: 'Date Override',
        category: 'Dashboard',
        description:
            'Change the dashboard date to view and post sales on a different date',
        icon: Icons.date_range,
      ),
      // System
      const Permission(
        key: systemAdmin,
        name: 'System Admin',
        category: 'System',
        description: 'Full administrative access to all system features',
        icon: Icons.admin_panel_settings,
      ),
    ];
  }

  /// Private: Build permissions grouped by category.
  static Map<String, List<Permission>> _buildPermissionsByCategory() {
    final map = <String, List<Permission>>{};
    for (final permission in all) {
      map.putIfAbsent(permission.category, () => []).add(permission);
    }
    return map;
  }
}
