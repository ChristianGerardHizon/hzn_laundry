import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

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

enum _UsersPanelSection { members, invites }

/// User list panel with search header and infinite scroll.
///
/// Used in both mobile list page and tablet two-pane layout.
/// Managers also get a separate Invites section (Members | Invites).
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

    final searchController = useTextEditingController();
    final searchText = useState('');
    final section = useState(_UsersPanelSection.members);

    final searchFields = ref.watch(userSearchFieldsProvider);
    final activeFieldCount = searchFields.length;
    final paginatedController =
        ref.read(paginatedUsersControllerProvider.notifier);
    final isSearchActive = paginatedController.isSearchActive;

    final org = ref.watch(currentOrganizationControllerProvider).value;
    final canManage = org != null &&
        (ref
                .watch(currentOrganizationControllerProvider.notifier)
                .membershipFor(org.id)
                ?.canManageMembers ??
            false);

    // Keep invites loaded so the segment badge stays accurate.
    final invitesAsync = canManage
        ? ref.watch(orgPendingInvitesControllerProvider)
        : const AsyncValue.data(<OrganizationInvite>[]);
    final inviteCount = invitesAsync.value?.length ?? 0;

    // If manage permission is lost, fall back to members.
    useEffect(() {
      if (!canManage && section.value == _UsersPanelSection.invites) {
        section.value = _UsersPanelSection.members;
      }
      return null;
    }, [canManage]);

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

    final scrollController = useInfiniteScroll(
      onLoadMore: onLoadMore,
      hasMore: !paginatedState.hasReachedEnd,
      isLoading: paginatedState.isLoadingMore,
    );

    final showingInvites = canManage && section.value == _UsersPanelSection.invites;

    return Column(
      children: [
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
                      showingInvites
                          ? t.management.invitesSection
                          : t.navigation.users,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showingInvites
                          ? t.management.invitesSubtitle
                          : t.management.usersSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                showingInvites
                    ? '$inviteCount total'
                    : '${paginatedState.totalItems} total',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),

        if (canManage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_UsersPanelSection>(
                segments: [
                  ButtonSegment(
                    value: _UsersPanelSection.members,
                    label: Text(t.management.membersSection),
                    icon: const Icon(Icons.people_outline, size: 18),
                  ),
                  ButtonSegment(
                    value: _UsersPanelSection.invites,
                    label: Text(
                      inviteCount > 0
                          ? '${t.management.invitesSection} ($inviteCount)'
                          : t.management.invitesSection,
                    ),
                    icon: const Icon(Icons.mail_outline, size: 18),
                  ),
                ],
                selected: {section.value},
                onSelectionChanged: (next) {
                  section.value = next.first;
                },
              ),
            ),
          ),

        if (showingInvites)
          Expanded(
            child: _InvitesPanel(onRefresh: onRefresh),
          )
        else ...[
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: paginatedState.items.length + 1,
                itemBuilder: (context, index) {
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
      ],
    );
  }
}

class _InvitesPanel extends HookConsumerWidget {
  const _InvitesPanel({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final invitesAsync = ref.watch(orgPendingInvitesControllerProvider);

    return invitesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton(
          onPressed: () =>
              ref.read(orgPendingInvitesControllerProvider.notifier).refresh(),
          child: Text(t.common.retry),
        ),
      ),
      data: (invites) {
        if (invites.isEmpty) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.35,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t.management.noPendingInvites,
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.management.noPendingInvitesHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final dateFormat = DateFormat.yMMMd();

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: invites.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final invite = invites[index];
              return _PendingInviteTile(
                invite: invite,
                expiresLabel: dateFormat.format(invite.expiresAt.toLocal()),
              );
            },
          ),
        );
      },
    );
  }
}

class _PendingInviteTile extends HookConsumerWidget {
  const _PendingInviteTile({
    required this.invite,
    required this.expiresLabel,
  });

  final OrganizationInvite invite;
  final String expiresLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final isResending = useState(false);
    final isRevoking = useState(false);
    final busy = isResending.value || isRevoking.value;

    Future<void> handleResend() async {
      isResending.value = true;
      final result = await ref
          .read(orgPendingInvitesControllerProvider.notifier)
          .resend(invite.id);
      isResending.value = false;
      if (!context.mounted) return;
      switch (result) {
        case InviteResendResult.sent:
          showSuccessSnackBar(
            context,
            message: t.organizations.inviteResent,
          );
        case InviteResendResult.alreadyAccepted:
          showWarningSnackBar(
            context,
            message: t.organizations.inviteAlreadyAccepted,
          );
        case InviteResendResult.stale:
          showWarningSnackBar(
            context,
            message: t.organizations.inviteNoLongerPending,
          );
        case InviteResendResult.failed:
          showErrorSnackBar(
            context,
            message: t.organizations.inviteResendFailed,
          );
      }
    }

    Future<void> handleRevoke() async {
      isRevoking.value = true;
      final ok = await ref
          .read(orgPendingInvitesControllerProvider.notifier)
          .revoke(invite.id);
      isRevoking.value = false;
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
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
            child: const Icon(Icons.mail_outline, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  invite.email,
                  style: theme.textTheme.bodyLarge,
                  softWrap: true,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (invite.roleName.isNotEmpty) invite.roleName,
                    'Expires $expiresLabel',
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isResending.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: busy ? null : handleResend,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(t.organizations.resendInvite),
                      ),
                    TextButton(
                      onPressed: busy ? null : handleRevoke,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(t.organizations.revoke),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
