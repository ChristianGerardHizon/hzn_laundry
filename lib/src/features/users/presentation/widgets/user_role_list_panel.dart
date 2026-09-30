import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/list/list.dart';
import '../../../../core/widgets/state/empty_state.dart';
import '../../domain/user_role.dart';
import 'dialogs/create_role_dialog.dart';

/// Role list panel with search and list selection.
///
/// Set [showHeader] to false when the host already renders the title (e.g. the
/// mobile page's AppBar).
class UserRoleListPanel extends HookConsumerWidget {
  const UserRoleListPanel({
    super.key,
    required this.roles,
    this.selectedId,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    this.onRoleTap,
    this.showHeader = true,
  });

  final List<UserRole> roles;
  final String? selectedId;
  final Future<void> Function() onRefresh;
  final void Function(UserRole) onEdit;
  final void Function(UserRole) onDelete;
  final void Function(UserRole)? onRoleTap;
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);

    final searchController = useTextEditingController();
    final appliedQuery = useState('');

    final isSearchActive = appliedQuery.value.isNotEmpty;
    final filteredRoles =
        isSearchActive ? _filterRoles(roles, appliedQuery.value) : roles;

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) return;
      appliedQuery.value = query;
    }

    void clearSearch() {
      searchController.clear();
      appliedQuery.value = '';
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'roles_panel_fab',
        onPressed: () => showCreateRoleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add role'),
      ),
      body: Column(
        children: [
          if (showHeader)
            ListPanelHeader(
              title: t.navigation.roles,
              count: filteredRoles.length,
            ),
          ListToolbar(
            controller: searchController,
            onSearch: performSearch,
            onTextChanged: (_) {},
            activeQuery: isSearchActive ? appliedQuery.value : null,
            onClear: clearSearch,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: filteredRoles.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          child: EmptyState(
                            icon: Icons.admin_panel_settings_outlined,
                            iconSize: 56,
                            title: isSearchActive
                                ? 'No roles match "${appliedQuery.value}"'
                                : 'No roles found',
                            subtitle: isSearchActive
                                ? 'Try a different search term'
                                : 'Create a role to get started',
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: filteredRoles.length,
                      itemBuilder: (context, index) {
                        final role = filteredRoles[index];
                        return _RoleListTile(
                          role: role,
                          isSelected: role.id == selectedId,
                          onEdit: () => onEdit(role),
                          onDelete: () => onDelete(role),
                          onTap: () => onRoleTap?.call(role),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleListTile extends StatelessWidget {
  const _RoleListTile({
    required this.role,
    required this.isSelected,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final UserRole role;
  final bool isSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final permissionCount = role.permissions.length;

    return AppListRow(
      isSelected: isSelected,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor:
            role.isAdmin ? scheme.primaryContainer : scheme.secondaryContainer,
        child: Icon(
          role.isAdmin ? Icons.admin_panel_settings : Icons.person,
          color: role.isAdmin
              ? scheme.onPrimaryContainer
              : scheme.onSecondaryContainer,
        ),
      ),
      title: Text(role.name),
      subtitle: Text(
        role.description ??
            '$permissionCount permission${permissionCount == 1 ? '' : 's'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (role.isSystem) const RowChip(label: 'System'),
          PopupMenuButton<String>(
            tooltip: 'Role actions',
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              if (!role.isSystem)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: scheme.error),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: scheme.error)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

List<UserRole> _filterRoles(List<UserRole> roles, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return roles;
  }

  return roles.where((role) {
    final nameMatch = role.name.toLowerCase().contains(normalizedQuery);
    final description = role.description ?? '';
    final descriptionMatch =
        description.toLowerCase().contains(normalizedQuery);
    return nameMatch || descriptionMatch;
  }).toList();
}
