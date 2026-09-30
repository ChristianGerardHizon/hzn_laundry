import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/list/list.dart';
import '../../../../core/widgets/state/empty_state.dart';
import '../../../organizations/domain/organization_invite.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../domain/user.dart';
import '../controllers/org_pending_invites_controller.dart';
import '../controllers/paginated_users_controller.dart';
import '../controllers/user_search_controller.dart';
import 'dialogs/search_fields_dialog.dart';
import 'user_avatar.dart';

enum _UsersPanelSection { members, invites }

/// User list panel with search toolbar and infinite scroll.
///
/// Used in both mobile list page and tablet two-pane layout.
/// Managers also get a separate Invites section (Members | Invites).
///
/// Set [showHeader] to false when the host already renders the title (e.g. the
/// mobile page's AppBar) so the title is not repeated.
class UserListPanel extends HookConsumerWidget {
  const UserListPanel({
    super.key,
    required this.paginatedState,
    required this.selectedId,
    required this.onUserTap,
    required this.onRefresh,
    required this.onLoadMore,
    this.showHeader = true,
  });

  final PaginatedState<User> paginatedState;
  final String? selectedId;
  final ValueChanged<User> onUserTap;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Keep invites loaded so the tab badge stays accurate.
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

    final showingInvites =
        canManage && section.value == _UsersPanelSection.invites;
    final items = paginatedState.items;
    final isEmpty = items.isEmpty && !paginatedState.isLoadingMore;

    return Column(
      children: [
        if (showHeader)
          ListPanelHeader(
            title: showingInvites
                ? t.management.invitesSection
                : t.navigation.users,
            count: showingInvites ? inviteCount : paginatedState.totalItems,
            subtitle: showingInvites
                ? t.management.invitesSubtitle
                : t.management.usersSubtitle,
          ),

        // Counts live inside the tabs, so no separate "N total" row is needed.
        if (canManage)
          ListSectionTabs<_UsersPanelSection>(
            selected: section.value,
            onChanged: (next) => section.value = next,
            tabs: [
              ListSectionTab(
                value: _UsersPanelSection.members,
                label: t.management.membersSection,
                count: paginatedState.totalItems,
              ),
              ListSectionTab(
                value: _UsersPanelSection.invites,
                label: t.management.invitesSection,
                count: inviteCount,
                highlightCount: true,
              ),
            ],
          ),

        if (showingInvites)
          Expanded(
            child: _InvitesPanel(onRefresh: onRefresh),
          )
        else ...[
          ListToolbar(
            controller: searchController,
            onSearch: performSearch,
            onTextChanged: (text) => searchText.value = text,
            activeQuery:
                isSearchActive ? paginatedController.currentSearchQuery ?? '' : null,
            onClear: clearSearch,
            filterCount: activeFieldCount > 1 ? activeFieldCount : 0,
            onFilterPressed: () => showUserSearchFieldsDialog(context),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          child: EmptyState(
                            icon: Icons.person_search_outlined,
                            iconSize: 56,
                            title: t.common.noResults,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return EndOfListIndicator(
                            isLoadingMore: paginatedState.isLoadingMore,
                            hasReachedEnd: paginatedState.hasReachedEnd,
                          );
                        }

                        final user = items[index];
                        return _UserTile(
                          user: user,
                          isSelected: user.id == selectedId,
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

/// Two-line member row: name + email, with the role as a tonal chip.
class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppListRow(
      leading: UserAvatar(user: user, radius: 22),
      title: Text(user.name),
      subtitle: user.email.isEmpty ? null : Text(user.email),
      trailing: RowChip(label: user.displayRole),
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}
class _InvitesPanel extends HookConsumerWidget {
  const _InvitesPanel({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
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
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  child: EmptyState(
                    icon: Icons.mail_outline,
                    iconSize: 56,
                    title: t.management.noPendingInvites,
                    subtitle: t.management.noPendingInvitesHint,
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
            radius: 22,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (invite.roleName.isNotEmpty) invite.roleName,
                    'Expires $expiresLabel',
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
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
                        foregroundColor: theme.colorScheme.error,
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
