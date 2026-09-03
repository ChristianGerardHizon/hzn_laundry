import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../widgets/form_feedback.dart';
import '../../../features/machines/presentation/controllers/machines_controller.dart';
import '../../../features/machines/presentation/widgets/machine_form_dialog.dart';
import '../../../features/settings/presentation/widgets/product_category_detail_panel.dart';
import '../../../features/settings/presentation/widgets/quantity_unit_detail_panel.dart';
import '../../../features/settings/presentation/widgets/import_landing_panel.dart';
import '../../../features/settings/presentation/widgets/email_settings_panel.dart';
import '../../../features/settings/presentation/widgets/dialogs/product_category_form_dialog.dart';
import '../../../features/settings/presentation/widgets/dialogs/quantity_unit_form_dialog.dart';
import '../../../features/settings/presentation/controllers/product_categories_controller.dart';
import '../../../features/settings/presentation/controllers/quantity_units_controller.dart';
import '../../../features/pos/presentation/pages/cashier_groups_settings_page.dart';
import '../../../features/pos/presentation/widgets/cashier_group_detail_panel.dart';
import '../../../features/products/domain/product_category.dart';
import '../../../features/machines/presentation/widgets/machine_detail_panel.dart';
import '../../../features/management/presentation/pages/management_shell.dart';
import '../../../features/settings/domain/branch.dart';
import '../../../features/settings/presentation/controllers/branches_controller.dart';
import '../../../features/settings/presentation/widgets/dialogs/branch_form_dialog.dart';
import '../../../features/storages/domain/storage_location.dart';
import '../../../features/storages/presentation/controllers/storage_locations_controller.dart';
import '../../../features/storages/presentation/widgets/storage_location_form_dialog.dart';
import '../../../features/users/domain/user_tab.dart';
import '../../../features/users/presentation/controllers/paginated_users_controller.dart';
import '../../../features/users/presentation/controllers/user_roles_controller.dart';
import '../../../features/users/presentation/pages/user_detail_page.dart';
import '../../../features/users/presentation/widgets/dialogs/create_user_dialog.dart';
import '../../../features/users/presentation/widgets/dialogs/edit_role_dialog.dart';
import '../../../features/users/presentation/widgets/user_list_panel.dart';
import '../../../features/users/presentation/widgets/user_role_detail_panel.dart';
import '../../../features/users/presentation/widgets/user_role_list_panel.dart';
import '../../i18n/strings.g.dart';
import '../../utils/breakpoints.dart';

part 'management.routes.g.dart';

/// Organization shell route for 3-panel layout.
///
/// On tablet: Shows nav rail + list + detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<ManagementShellRoute>(
  routes: [
    TypedGoRoute<ManagementRoute>(
      path: ManagementRoute.path,
      routes: [
        TypedGoRoute<ManagementUsersRoute>(
          path: 'users',
          routes: [
            TypedGoRoute<ManagementUserDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<ManagementRolesRoute>(
          path: 'roles',
          routes: [
            TypedGoRoute<ManagementRoleDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<ManagementBranchesRoute>(
          path: 'branches',
          routes: [
            TypedGoRoute<ManagementBranchDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<ManagementMachinesRoute>(
          path: 'machines',
          routes: [
            TypedGoRoute<ManagementMachineDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<ManagementStoragesRoute>(
          path: 'storages',
          routes: [
            TypedGoRoute<ManagementStorageDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<ManagementProductCategoriesRoute>(
          path: 'product-categories',
          routes: [
            TypedGoRoute<ManagementProductCategoryDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<ManagementQuantityUnitsRoute>(
          path: 'quantity-units',
          routes: [
            TypedGoRoute<ManagementQuantityUnitDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<ManagementCashierGroupsRoute>(
          path: 'cashier-groups',
          routes: [
            TypedGoRoute<ManagementCashierGroupDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<ManagementImportRoute>(path: 'import'),
        TypedGoRoute<ManagementSettingsRoute>(path: 'settings'),
      ],
    ),
  ],
)
class ManagementShellRoute extends ShellRouteData {
  const ManagementShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return ManagementShell(child: navigator);
  }
}

/// Organization root route.
///
/// On tablet: Redirects to /management/users (3-panel layout)
/// On mobile: Shows landing page with Users/Roles options
class ManagementRoute extends GoRouteData with $ManagementRoute {
  const ManagementRoute();

  static const path = '/management';

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    // Only redirect on tablet - mobile shows landing page
    if (Breakpoints.isTabletOrLarger(context) && state.uri.path == path) {
      return '$path/users';
    }
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // Mobile: Show landing page with Users/Roles options
    return const _MobileManagementLandingPage();
  }
}

/// Organization users list route.
class ManagementUsersRoute extends GoRouteData with $ManagementUsersRoute {
  const ManagementUsersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show users list
    return const _ManagementUsersListPage();
  }
}

/// Organization user detail route.
class ManagementUserDetailRoute extends GoRouteData
    with $ManagementUserDetailRoute {
  const ManagementUserDetailRoute({required this.id, this.tab});

  final String id;
  final String? tab;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final tabName = state.uri.queryParameters['tab'];
    return UserDetailPage(
      userId: id,
      initialTab: UserTab.fromString(tabName),
    );
  }
}

/// Organization roles list route.
class ManagementRolesRoute extends GoRouteData with $ManagementRolesRoute {
  const ManagementRolesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show roles list
    return const _ManagementRolesListPage();
  }
}

/// Organization role detail route.
class ManagementRoleDetailRoute extends GoRouteData
    with $ManagementRoleDetailRoute {
  const ManagementRoleDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _RoleDetailWrapper(roleId: id);
  }
}

/// Organization branches list route.
class ManagementBranchesRoute extends GoRouteData
    with $ManagementBranchesRoute {
  const ManagementBranchesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show branches list
    return const _ManagementBranchesListPage();
  }
}

/// Organization branch detail route.
class ManagementBranchDetailRoute extends GoRouteData
    with $ManagementBranchDetailRoute {
  const ManagementBranchDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _BranchDetailWrapper(branchId: id);
  }
}

// ============================================================================
// Mobile Pages
// ============================================================================

/// Mobile landing page for organization with Users/Roles selection.
class _MobileManagementLandingPage extends StatelessWidget {
  const _MobileManagementLandingPage();

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.management),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ManagementOptionCard(
            icon: Icons.people,
            title: t.navigation.users,
            color: theme.colorScheme.primary,
            onTap: () => const ManagementUsersRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.admin_panel_settings,
            title: t.navigation.roles,
            color: theme.colorScheme.secondary,
            onTap: () => const ManagementRolesRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.store,
            title: t.navigation.branches,
            color: theme.colorScheme.tertiary,
            onTap: () => const ManagementBranchesRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.local_laundry_service,
            title: 'Machines',
            color: Colors.teal,
            onTap: () => const ManagementMachinesRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.inventory_2,
            title: 'Storages',
            color: Colors.indigo,
            onTap: () => const ManagementStoragesRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.category,
            title: 'Categories',
            color: Colors.orange,
            onTap: () => const ManagementProductCategoriesRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.straighten,
            title: 'Units',
            color: Colors.cyan,
            onTap: () => const ManagementQuantityUnitsRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.point_of_sale,
            title: 'Cashier',
            color: Colors.teal,
            onTap: () => const ManagementCashierGroupsRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.file_upload,
            title: 'Import',
            color: Colors.deepPurple,
            onTap: () => const ManagementImportRoute().go(context),
          ),
          const SizedBox(height: 16),
          _ManagementOptionCard(
            icon: Icons.tune,
            title: 'Settings',
            color: Colors.blueGrey,
            onTap: () => const ManagementSettingsRoute().go(context),
          ),
        ],
      ),
    );
  }
}

/// Card widget for organization option selection.
class _ManagementOptionCard extends StatelessWidget {
  const _ManagementOptionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile users list page for organization.
class _ManagementUsersListPage extends ConsumerWidget {
  const _ManagementUsersListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedAsync = ref.watch(paginatedUsersControllerProvider);
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.users),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: t.navigation.roles,
            onPressed: () => const ManagementRolesRoute().go(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'mgmt_users_fab',
        onPressed: () => showCreateUserDialog(context),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      body: paginatedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(paginatedUsersControllerProvider.notifier)
                    .refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (paginatedState) => UserListPanel(
          paginatedState: paginatedState,
          selectedId: null,
          onUserTap: (user) {
            ManagementUserDetailRoute(id: user.id).push(context);
          },
          onRefresh: () =>
              ref.read(paginatedUsersControllerProvider.notifier).refresh(),
          onLoadMore: () =>
              ref.read(paginatedUsersControllerProvider.notifier).loadMore(),
        ),
      ),
    );
  }
}

/// Mobile roles list page for organization.
class _ManagementRolesListPage extends ConsumerWidget {
  const _ManagementRolesListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesControllerProvider);
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.roles),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: t.navigation.users,
            onPressed: () => const ManagementUsersRoute().go(context),
          ),
        ],
      ),
      body: rolesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(userRolesControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (roles) => UserRoleListPanel(
          roles: roles,
          selectedId: null,
          onRefresh: () =>
              ref.read(userRolesControllerProvider.notifier).refresh(),
          onEdit: (role) => showEditRoleDialog(context, role),
          onDelete: (role) => _confirmDeleteRole(context, ref, role),
          onRoleTap: (role) {
            ManagementRoleDetailRoute(id: role.id).push(context);
          },
        ),
      ),
    );
  }

  void _confirmDeleteRole(BuildContext context, WidgetRef ref, role) {
    if (role.isSystem) {
      showErrorSnackBar(context, message: 'System roles cannot be deleted');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Role'),
        content:
            Text('Are you sure you want to delete the "${role.name}" role?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(userRolesControllerProvider.notifier)
                  .deleteRole(role.id);
              if (context.mounted) {
                if (success) {
                  showSuccessSnackBar(context, message: 'Role deleted');
                } else {
                  showErrorSnackBar(context, message: 'Failed to delete role');
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Wrapper to fetch and display role detail.
class _RoleDetailWrapper extends ConsumerWidget {
  const _RoleDetailWrapper({required this.roleId});

  final String roleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesControllerProvider);

    return rolesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
            ],
          ),
        ),
      ),
      data: (roles) {
        final role = roles.cast().firstWhere(
              (r) => r.id == roleId,
              orElse: () => null,
            );

        if (role == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Role not found'),
            ),
          );
        }

        return UserRoleDetailPanel(role: role);
      },
    );
  }
}

/// Organization machines list route.
class ManagementMachinesRoute extends GoRouteData
    with $ManagementMachinesRoute {
  const ManagementMachinesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const _ManagementMachinesListPage();
  }
}

/// Organization machine detail route.
class ManagementMachineDetailRoute extends GoRouteData
    with $ManagementMachineDetailRoute {
  const ManagementMachineDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MachineDetailPanel(machineId: id);
  }
}

/// Organization storages list route.
class ManagementStoragesRoute extends GoRouteData
    with $ManagementStoragesRoute {
  const ManagementStoragesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const _ManagementStoragesListPage();
  }
}

/// Organization storage detail route.
class ManagementStorageDetailRoute extends GoRouteData
    with $ManagementStorageDetailRoute {
  const ManagementStorageDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _StorageDetailWrapper(storageId: id);
  }
}

/// Product categories list route.
class ManagementProductCategoriesRoute extends GoRouteData
    with $ManagementProductCategoriesRoute {
  const ManagementProductCategoriesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const _ManagementProductCategoriesListPage();
  }
}

/// Product category detail route.
class ManagementProductCategoryDetailRoute extends GoRouteData
    with $ManagementProductCategoryDetailRoute {
  const ManagementProductCategoryDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProductCategoryDetailPanel(categoryId: id);
  }
}

/// Quantity units list route.
class ManagementQuantityUnitsRoute extends GoRouteData
    with $ManagementQuantityUnitsRoute {
  const ManagementQuantityUnitsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const _ManagementQuantityUnitsListPage();
  }
}

/// Quantity unit detail route.
class ManagementQuantityUnitDetailRoute extends GoRouteData
    with $ManagementQuantityUnitDetailRoute {
  const ManagementQuantityUnitDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return QuantityUnitDetailPanel(unitId: id);
  }
}

/// Cashier layout groups list route.
class ManagementCashierGroupsRoute extends GoRouteData
    with $ManagementCashierGroupsRoute {
  const ManagementCashierGroupsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const CashierGroupsSettingsPage();
  }
}

/// Cashier group detail route.
class ManagementCashierGroupDetailRoute extends GoRouteData
    with $ManagementCashierGroupDetailRoute {
  const ManagementCashierGroupDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CashierGroupDetailPanel(groupId: id);
  }
}

/// CSV product import route.
class ManagementImportRoute extends GoRouteData with $ManagementImportRoute {
  const ManagementImportRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Import Products')),
      body: const ImportLandingPanel(),
    );
  }
}

/// Org workflow / feature-flag settings route.
class ManagementSettingsRoute extends GoRouteData
    with $ManagementSettingsRoute {
  const ManagementSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const EmailSettingsPanel();
  }
}

/// Mobile branches list page for organization.
class _ManagementBranchesListPage extends ConsumerWidget {
  const _ManagementBranchesListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesControllerProvider);
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.branches),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: t.navigation.users,
            onPressed: () => const ManagementUsersRoute().go(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'branch_fab',
        onPressed: () => showBranchFormDialog(context),
        tooltip: 'Add Branch',
        child: const Icon(Icons.add),
      ),
      body: branchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(branchesControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (branches) {
          if (branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No branches yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a branch',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(branchesControllerProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return _MobileBranchListTile(
                  branch: branch,
                  onTap: () =>
                      ManagementBranchDetailRoute(id: branch.id).push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MobileBranchListTile extends StatelessWidget {
  const _MobileBranchListTile({
    required this.branch,
    required this.onTap,
  });

  final Branch branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.store_outlined,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(branch.name),
      subtitle: Text(
        branch.address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Wrapper to display branch detail with organization navigation.
class _BranchDetailWrapper extends ConsumerWidget {
  const _BranchDetailWrapper({required this.branchId});

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branchesAsync = ref.watch(branchesControllerProvider);

    // Find the branch from the list
    final branches = branchesAsync.value;
    final branch = branches?.cast<Branch?>().firstWhere(
          (b) => b?.id == branchId,
          orElse: () => null,
        );

    if (branchesAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (branch == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Branch not found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _ManagementBranchDetailPage(branch: branch);
  }
}

/// Read-only branch detail page for organization section (mobile).
class _ManagementBranchDetailPage extends ConsumerWidget {
  const _ManagementBranchDetailPage({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(branch.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => showBranchFormDialog(context, branch: branch),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _handleDelete(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.store,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Details section
            Text(
              'Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      theme,
                      icon: Icons.store,
                      label: 'Name',
                      value: branch.name,
                    ),
                    _buildDetailRow(
                      theme,
                      icon: Icons.location_on,
                      label: 'Address',
                      value: branch.address,
                    ),
                    _buildDetailRow(
                      theme,
                      icon: Icons.phone,
                      label: 'Contact Number',
                      value: branch.contactNumber,
                    ),
                    if (branch.operatingHours != null &&
                        branch.operatingHours!.isNotEmpty)
                      _buildDetailRow(
                        theme,
                        icon: Icons.schedule,
                        label: 'Operating Hours',
                        value: branch.operatingHours!,
                      ),
                    if (branch.cutOffTime != null &&
                        branch.cutOffTime!.isNotEmpty)
                      _buildDetailRow(
                        theme,
                        icon: Icons.timer_off,
                        label: 'Cut-off Time',
                        value: branch.cutOffTime!,
                      ),
                    if (branch.created != null)
                      _buildDetailRow(
                        theme,
                        icon: Icons.calendar_today,
                        label: 'Created',
                        value: dateFormat.format(branch.created!.toLocal()),
                      ),
                    if (branch.updated != null)
                      _buildDetailRow(
                        theme,
                        icon: Icons.update,
                        label: 'Last Updated',
                        value: dateFormat.format(branch.updated!.toLocal()),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete "${branch.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(branchesControllerProvider.notifier)
        .deleteBranch(branch.id);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context, message: 'Branch deleted successfully');
        context.pop();
      } else {
        showErrorSnackBar(context,
            message: 'Failed to delete branch. Please try again.');
      }
    }
  }
}

// ============================================================================
// Machines Pages
// ============================================================================

/// Mobile machines list page for organization.
class _ManagementMachinesListPage extends ConsumerWidget {
  const _ManagementMachinesListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machinesAsync = ref.watch(machinesControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Machines'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'machine_fab',
        onPressed: () => showMachineFormDialog(context),
        tooltip: 'Add Machine',
        child: const Icon(Icons.add),
      ),
      body: machinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(machinesControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (machines) {
          if (machines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_laundry_service_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No machines yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a machine',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(machinesControllerProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: machines.length,
              itemBuilder: (context, index) {
                final machine = machines[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.local_laundry_service,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Row(
                    children: [
                      Flexible(child: Text(machine.name)),
                      if (machine.strictSingleUse) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.lock,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(machine.type.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ManagementMachineDetailRoute(id: machine.id)
                      .push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ManagementStoragesListPage extends ConsumerWidget {
  const _ManagementStoragesListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storagesAsync = ref.watch(storageLocationsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Locations'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'storage_fab',
        onPressed: () => showStorageLocationFormDialog(context),
        tooltip: 'Add Storage',
        child: const Icon(Icons.add),
      ),
      body: storagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(storageLocationsControllerProvider.notifier)
                    .refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (storages) {
          if (storages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No storage locations yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a storage location',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(storageLocationsControllerProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: storages.length,
              itemBuilder: (context, index) {
                final storage = storages[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.inventory_2,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(storage.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ManagementStorageDetailRoute(id: storage.id)
                      .push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Wrapper to display storage detail.
class _StorageDetailWrapper extends ConsumerWidget {
  const _StorageDetailWrapper({required this.storageId});

  final String storageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storagesAsync = ref.watch(storageLocationsControllerProvider);

    final storages = storagesAsync.value;
    final storage = storages?.cast<StorageLocation?>().firstWhere(
          (s) => s?.id == storageId,
          orElse: () => null,
        );

    if (storagesAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (storage == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Storage location not found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _ManagementStorageDetailPage(storage: storage);
  }
}

/// Storage detail page for organization section.
class _ManagementStorageDetailPage extends ConsumerWidget {
  const _ManagementStorageDetailPage({required this.storage});

  final StorageLocation storage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(storage.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () =>
                showStorageLocationFormDialog(context, storage: storage),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _handleDelete(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.inventory_2,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        storage.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: storage.isAvailable
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        storage.isAvailable ? 'Available' : 'Unavailable',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              storage.isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _detailRow(theme,
                        icon: Icons.inventory_2,
                        label: 'Name',
                        value: storage.name),
                    if (storage.created != null)
                      _detailRow(theme,
                          icon: Icons.calendar_today,
                          label: 'Created',
                          value: dateFormat.format(storage.created!.toLocal())),
                    if (storage.updated != null)
                      _detailRow(theme,
                          icon: Icons.update,
                          label: 'Last Updated',
                          value: dateFormat.format(storage.updated!.toLocal())),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Storage Location'),
        content: Text('Are you sure you want to delete "${storage.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(storageLocationsControllerProvider.notifier)
        .deleteStorageLocation(storage.id);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context,
            message: 'Storage location deleted successfully');
        context.pop();
      } else {
        showErrorSnackBar(context,
            message: 'Failed to delete storage location. Please try again.');
      }
    }
  }
}

/// Mobile product categories list.
class _ManagementProductCategoriesListPage extends ConsumerWidget {
  const _ManagementProductCategoriesListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);
    final controller = ref.read(productCategoriesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_category_fab',
        onPressed: () => showProductCategoryFormDialog(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a category',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          final rootCategories = categories.where((c) => !c.hasParent).toList();
          final childCategories = categories.where((c) => c.hasParent).toList();

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              itemCount: rootCategories.length,
              itemBuilder: (context, index) {
                final category = rootCategories[index];
                final children = childCategories
                    .where((c) => c.parentId == category.id)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ManagementCategoryListTile(
                      category: category,
                      isChild: false,
                      onTap: () =>
                          ManagementProductCategoryDetailRoute(id: category.id)
                              .push(context),
                    ),
                    ...children.map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: _ManagementCategoryListTile(
                          category: child,
                          isChild: true,
                          onTap: () =>
                              ManagementProductCategoryDetailRoute(id: child.id)
                                  .push(context),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ManagementCategoryListTile extends StatelessWidget {
  const _ManagementCategoryListTile({
    required this.category,
    required this.isChild,
    required this.onTap,
  });

  final ProductCategory category;
  final bool isChild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isChild
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.primaryContainer,
        child: Icon(
          isChild ? Icons.subdirectory_arrow_right : Icons.inventory_2_outlined,
          color: isChild
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(category.name),
      subtitle: category.hasParent && category.parentName != null
          ? Text('Parent: ${category.parentName}')
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Mobile quantity units list.
class _ManagementQuantityUnitsListPage extends ConsumerWidget {
  const _ManagementQuantityUnitsListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(quantityUnitsControllerProvider);
    final controller = ref.read(quantityUnitsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantity Units'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'quantity_unit_fab',
        onPressed: () => showQuantityUnitFormDialog(context),
        tooltip: 'Add Unit',
        child: const Icon(Icons.add),
      ),
      body: unitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (units) {
          if (units.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.straighten_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No quantity units yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a unit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.straighten,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(unit.name),
                  subtitle: Text(unit.shortPlural),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ManagementQuantityUnitDetailRoute(id: unit.id)
                      .push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
