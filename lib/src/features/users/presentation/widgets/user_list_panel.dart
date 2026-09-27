import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../organizations/domain/organization_invite.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../domain/user.dart';
import '../controllers/org_pending_invites_controller.dart';
import '../controllers/paginated_users_controller.dart';
import '../controllers/user_search_controller.dart';
import 'dialogs/search_fields_dialog.dart';
import 'user_avatar.dart';

/// User list panel with search header and infinite scroll.
///
/// Used in both mobile list page and tablet two-pane layout.
class UserListPanel extends HookConsumerWidget {
  const UserListPanel({
    super.key,
    required this.paginatedState,
    required this.selectedId,
    required this.onUserTap,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final PaginatedState<User> paginatedState;
  final String? selectedId;
  final ValueChanged<User> onUserTap;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Local state using hooks
    final searchController = useTextEditingController();
    final searchText = useState('');

    // Watch providers
    final searchFields = ref.watch(userSearchFieldsProvider);
    final activeFieldCount = searchFields.length;
    final paginatedController =
        ref.read(paginatedUsersControllerProvider.notifier);

    // Search is active from the controller
    final isSearchActive = paginatedController.isSearchActive;

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) return;

      final fields = ref.read(userSearchFieldsProvider).toList();
      paginatedController.search(query, fields: fields);
    }

    void clearSearch() {
      searchController.clear();
      searchText.value = '';
      ref.read(userSearchFieldsProvider.notifier).reset();
      paginatedController.clearSearch();
    }

    // Infinite scroll hook
    final scrollController = useInfiniteScroll(
      onLoadMore: onLoadMore,
      hasMore: !paginatedState.hasReachedEnd,
      isLoading: paginatedState.isLoadingMore,
    );

    return Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.navigation.users,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.management.usersSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${paginatedState.totalItems} total',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Pending invites for this org (managers only)
          const _PendingInvitesSection(),

          // Search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isSearchActive
                ? _ActiveSearchChip(
                    query: paginatedController.currentSearchQuery ?? '',
                    fieldCount: activeFieldCount,
                    onClear: clearSearch,
                  )
                : _SearchInput(
                    controller: searchController,
                    fieldCount: activeFieldCount,
                    onSearch: performSearch,
                    onTextChanged: (text) => searchText.value = text,
                    searchText: searchText.value,
                  ),
          ),

          // User list
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // +1 for the end indicator
                itemCount: paginatedState.items.length + 1,
                itemBuilder: (context, index) {
                  // Last item is the end indicator
                  if (index == paginatedState.items.length) {
                    return EndOfListIndicator(
                      isLoadingMore: paginatedState.isLoadingMore,
                      hasReachedEnd: paginatedState.hasReachedEnd,
                    );
                  }

                  final user = paginatedState.items[index];
                  final isSelected = user.id == selectedId;

                  return ListTile(
                    leading: UserAvatar(user: user),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(user.displayRole),
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer,
                    trailing:
                        isSelected ? const Icon(Icons.chevron_right) : null,
                    onTap: () => onUserTap(user),
                  );
                },
              ),
            ),
          ),
        ],
      );
  }
}

class _PendingInvitesSection extends HookConsumerWidget {
  const _PendingInvitesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final org = ref.watch(currentOrganizationControllerProvider).value;
    if (org == null) return const SizedBox.shrink();

    final membership = ref
        .watch(currentOrganizationControllerProvider.notifier)
        .membershipFor(org.id);
    final canManage = membership?.canManageMembers ?? false;
    if (!canManage) return const SizedBox.shrink();

    final invitesAsync = ref.watch(orgPendingInvitesControllerProvider);

    return invitesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (invites) {
        if (invites.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                t.organizations.pendingOrgInvites,
                style: theme.textTheme.titleSmall,
              ),
            ),
            ...invites.map(
              (invite) => _PendingInviteTile(invite: invite),
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }
}

class _PendingInviteTile extends ConsumerWidget {
  const _PendingInviteTile({required this.invite});

  final OrganizationInvite invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);

    return ListTile(
      dense: true,
      title: Text(invite.email),
      subtitle: Text(invite.roleName),
      trailing: TextButton(
        onPressed: () async {
          final ok = await ref
              .read(orgPendingInvitesControllerProvider.notifier)
              .revoke(invite.id);
          if (!context.mounted) return;
          if (ok) {
            showSuccessSnackBar(
              context,
              message: t.organizations.inviteRevoked,
            );
          } else {
            showErrorSnackBar(
              context,
              message: 'Failed to revoke invite',
            );
          }
        },
        child: Text(t.organizations.revoke),
      ),
    );
  }
}

class _ActiveSearchChip extends StatelessWidget {
  const _ActiveSearchChip({
    required this.query,
    required this.fieldCount,
    required this.onClear,
  });

  final String query;
  final int fieldCount;
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
                if (fieldCount > 1) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$fieldCount fields',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
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

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.fieldCount,
    required this.onSearch,
    required this.onTextChanged,
    required this.searchText,
  });

  final TextEditingController controller;
  final int fieldCount;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final String searchText;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '${t.common.search}...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onTextChanged('');
                      },
                      tooltip: t.common.cancel,
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
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: fieldCount > 1,
          label: Text('$fieldCount'),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => showUserSearchFieldsDialog(context),
            tooltip: t.common.filter,
          ),
        ),
      ],
    );
  }
}
