import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/routing/routes/management.routes.dart';
import '../../../machines/presentation/controllers/machines_controller.dart';
import '../../../machines/presentation/widgets/machine_form_dialog.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/widgets/dialogs/branch_form_dialog.dart';
import '../../../storages/presentation/controllers/storage_locations_controller.dart';
import '../../../storages/presentation/widgets/storage_location_form_dialog.dart';
import '../../../users/presentation/controllers/paginated_users_controller.dart';
import '../../../users/presentation/controllers/user_roles_controller.dart';
import '../../../users/presentation/widgets/dialogs/create_user_dialog.dart';
import '../../../users/presentation/widgets/dialogs/edit_role_dialog.dart';
import '../../../users/presentation/widgets/user_list_panel.dart';
import '../../../users/presentation/widgets/user_role_list_panel.dart';
import 'empty_management_state.dart';
import 'management_nav_panel.dart';

/// Three-panel tablet layout for organization management.
///
/// Panel 1 (72px): Navigation rail for Users/Roles mode selection
/// Panel 2 (320px): List panel (users or roles based on current mode)
/// Panel 3 (expanded): Detail panel from router or empty state
class TabletManagementLayout extends ConsumerWidget {
  const TabletManagementLayout({
    super.key,
    required this.detailChild,
  });

  /// The detail panel content from the router.
  final Widget detailChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerState = GoRouterState.of(context);
    final path = routerState.uri.path;
    final selectedId = routerState.pathParameters['id'];

    // Determine current mode from path
    final ManagementMode currentMode;
    if (path.contains('/roles')) {
      currentMode = ManagementMode.roles;
    } else if (path.contains('/branches')) {
      currentMode = ManagementMode.branches;
    } else if (path.contains('/machines')) {
      currentMode = ManagementMode.machines;
    } else if (path.contains('/storages')) {
      currentMode = ManagementMode.storages;
    } else {
      currentMode = ManagementMode.users;
    }

    return Row(
      children: [
        // Panel 1: Navigation
        ManagementNavPanel(
          currentMode: currentMode,
          onModeChanged: (mode) {
            switch (mode) {
              case ManagementMode.users:
                const ManagementUsersRoute().go(context);
              case ManagementMode.roles:
                const ManagementRolesRoute().go(context);
              case ManagementMode.branches:
                const ManagementBranchesRoute().go(context);
              case ManagementMode.machines:
                const ManagementMachinesRoute().go(context);
              case ManagementMode.storages:
                const ManagementStoragesRoute().go(context);
            }
          },
        ),
        const VerticalDivider(width: 1),

        // Panel 2: List
        SizedBox(
          width: 320,
          child: switch (currentMode) {
            ManagementMode.users => _UsersListWrapper(selectedId: selectedId),
            ManagementMode.roles => _RolesListWrapper(selectedId: selectedId),
            ManagementMode.branches =>
              _BranchesListWrapper(selectedId: selectedId),
            ManagementMode.machines =>
              _MachinesListWrapper(selectedId: selectedId),
            ManagementMode.storages =>
              _StoragesListWrapper(selectedId: selectedId),
          },
        ),
        const VerticalDivider(width: 1),

        // Panel 3: Detail
        Expanded(
          child: selectedId != null
              ? detailChild
              : EmptyManagementState(mode: currentMode),
        ),
      ],
    );
  }
}

/// Wrapper for UserListPanel with organization-specific navigation.
class _UsersListWrapper extends ConsumerWidget {
  const _UsersListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(paginatedUsersControllerProvider);
    final usersController = ref.read(paginatedUsersControllerProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'mgmt_users_fab',
        onPressed: () => showCreateUserDialog(context),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      body: usersAsync.when(
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
                onPressed: () => usersController.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (paginatedState) => UserListPanel(
          paginatedState: paginatedState,
          selectedId: selectedId,
          onUserTap: (user) {
            ManagementUserDetailRoute(id: user.id).go(context);
          },
          onRefresh: () => usersController.refresh(),
          onLoadMore: () => usersController.loadMore(),
        ),
      ),
    );
  }
}

/// Wrapper for UserRoleListPanel with organization-specific navigation.
class _RolesListWrapper extends ConsumerWidget {
  const _RolesListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesControllerProvider);
    final rolesController = ref.read(userRolesControllerProvider.notifier);

    return rolesAsync.when(
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
              onPressed: () => rolesController.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (roles) => UserRoleListPanel(
        roles: roles,
        selectedId: selectedId,
        onRefresh: () => rolesController.refresh(),
        onEdit: (role) => showEditRoleDialog(context, role),
        onDelete: (role) => _confirmDeleteRole(context, ref, role),
        onRoleTap: (role) {
          ManagementRoleDetailRoute(id: role.id).go(context);
        },
      ),
    );
  }

  void _confirmDeleteRole(BuildContext context, WidgetRef ref, role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content:
            Text('Are you sure you want to delete the "${role.name}" role?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
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

/// Wrapper for BranchListPanel with organization-specific navigation.
class _BranchesListWrapper extends HookConsumerWidget {
  const _BranchesListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final branchesAsync = ref.watch(branchesControllerProvider);
    final controller = ref.read(branchesControllerProvider.notifier);

    // Search state
    final searchController = useTextEditingController();
    final searchText = useState('');
    final appliedQuery = useState('');

    final isSearchActive = appliedQuery.value.isNotEmpty;

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) return;
      appliedQuery.value = query;
    }

    void clearSearch() {
      searchController.clear();
      searchText.value = '';
      appliedQuery.value = '';
    }

    return Scaffold(
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
                onPressed: () => controller.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (branches) {
          final filteredBranches = isSearchActive
              ? _filterBranches(branches, appliedQuery.value)
              : branches;
          final totalCount = filteredBranches.length;

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Text('Branches', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    Text(
                      '$totalCount total',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: isSearchActive
                    ? _BranchActiveSearchChip(
                        query: appliedQuery.value,
                        onClear: clearSearch,
                      )
                    : _BranchSearchInput(
                        controller: searchController,
                        onSearch: performSearch,
                        onTextChanged: (text) => searchText.value = text,
                        searchText: searchText.value,
                        hintText: '${t.common.search}...',
                      ),
              ),

              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: filteredBranches.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Icon(
                              Icons.store_outlined,
                              size: 80,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isSearchActive
                                  ? 'No branches match "${appliedQuery.value}"'
                                  : 'No branches yet',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isSearchActive
                                  ? 'Try a different search term'
                                  : 'Tap + to add a branch',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredBranches.length,
                          itemBuilder: (context, index) {
                            final branch = filteredBranches[index];
                            final isSelected = branch.id == selectedId;

                            return _BranchListTile(
                              branch: branch,
                              isSelected: isSelected,
                              onTap: () =>
                                  ManagementBranchDetailRoute(id: branch.id)
                                      .go(context),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BranchListTile extends StatelessWidget {
  const _BranchListTile({
    required this.branch,
    required this.isSelected,
    required this.onTap,
  });

  final Branch branch;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.store_outlined,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
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

class _BranchActiveSearchChip extends StatelessWidget {
  const _BranchActiveSearchChip({
    required this.query,
    required this.onClear,
  });

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"$query"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BranchSearchInput extends StatelessWidget {
  const _BranchSearchInput({
    required this.controller,
    required this.onSearch,
    required this.onTextChanged,
    required this.searchText,
    required this.hintText,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final String searchText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onTextChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}

List<Branch> _filterBranches(List<Branch> branches, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return branches;
  }

  return branches.where((b) {
    final nameMatch = b.name.toLowerCase().contains(normalizedQuery);
    final addressMatch = b.address.toLowerCase().contains(normalizedQuery);
    return nameMatch || addressMatch;
  }).toList();
}

/// Wrapper for machines list with organization-specific navigation.
class _MachinesListWrapper extends HookConsumerWidget {
  const _MachinesListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final machinesAsync = ref.watch(machinesControllerProvider);
    final controller = ref.read(machinesControllerProvider.notifier);

    return Scaffold(
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
                onPressed: () => controller.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (machines) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Text('Machines', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    Text(
                      '${machines.length} total',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: machines.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Icon(
                              Icons.local_laundry_service_outlined,
                              size: 80,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No machines yet',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add a machine',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: machines.length,
                          itemBuilder: (context, index) {
                            final machine = machines[index];
                            final isSelected = machine.id == selectedId;

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: theme
                                  .colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.local_laundry_service,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onPrimaryContainer,
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
                              onTap: () =>
                                  ManagementMachineDetailRoute(id: machine.id)
                                      .go(context),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Wrapper for storages list with organization-specific navigation.
class _StoragesListWrapper extends HookConsumerWidget {
  const _StoragesListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storagesAsync = ref.watch(storageLocationsControllerProvider);
    final controller = ref.read(storageLocationsControllerProvider.notifier);

    return Scaffold(
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
                onPressed: () => controller.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (storages) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Text('Storage Locations',
                        style: theme.textTheme.titleLarge),
                    const Spacer(),
                    Text(
                      '${storages.length} total',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: storages.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No storage locations yet',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add a storage location',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: storages.length,
                          itemBuilder: (context, index) {
                            final storage = storages[index];
                            final isSelected = storage.id == selectedId;

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: theme
                                  .colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.inventory_2,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              title: Text(storage.name),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  ManagementStorageDetailRoute(id: storage.id)
                                      .go(context),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
