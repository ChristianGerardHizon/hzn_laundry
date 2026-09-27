import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/routing/router_utils.dart';
import '../../../../core/routing/routes/dashboard.routes.dart';
import '../../../../core/routing/routes/org_selection.routes.dart';
import '../../../../core/routing/routes/organizations.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/nav_permissions.dart';
import '../../../../core/widgets/organization_letter_mark.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../users/domain/user_role.dart';
import '../../data/repositories/organization_invite_repository.dart';
import '../../domain/organization_invite.dart';
import '../../domain/organization_membership.dart';
import '../controllers/current_organization_controller.dart';
import '../widgets/dialogs/create_organization_setup_dialog.dart';

class OrganizationsPage extends HookConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final memberships =
        ref.watch(currentOrganizationControllerProvider.notifier).memberships;
    final currentOrg = orgAsync.value;
    final role = ref.watch(currentUserRoleProvider).value;
    final isSystemAdmin = role?.isAdmin ?? false;
    final canCreate =
        role?.hasPermission(Permissions.organizationsCreate) == true ||
            isSystemAdmin;

    Future<void> openCreateDialog() async {
      final created = await showCreateOrganizationSetupDialog(context);
      if (created == true && context.mounted) {
        showSuccessSnackBar(
          context,
          message: t.organizations.onboardingComplete,
        );
      }
    }

    final pb = ref.watch(pocketbaseProvider);
    final email =
        (pb.authStore.record?.toJson()['email'] as String?)?.trim() ?? '';

    final pendingInvites = useState<List<OrganizationInvite>>([]);

    Future<void> loadInvites() async {
      if (email.isEmpty) return;
      final mine =
          await ref.read(organizationInviteRepositoryProvider).listMine(email);
      mine.fold((_) {}, (list) => pendingInvites.value = list);
    }

    useEffect(() {
      loadInvites();
      return null;
    }, [email]);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.organizations.title),
        actions: [
          if (isSystemAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: t.organizations.superAdmin,
              onPressed: () => const SuperAdminRoute().go(context),
            ),
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add_business),
              tooltip: t.organizations.create,
              onPressed: openCreateDialog,
            ),
        ],
      ),
      body: orgAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState.fromError(e),
        data: (_) {
          if (memberships.isEmpty && pendingInvites.value.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: 56,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.organizations.noOrganizations,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.organizations.contactAdmin,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (canCreate) ...[
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: openCreateDialog,
                          icon: const Icon(Icons.add_business),
                          label: Text(t.organizations.create),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (pendingInvites.value.isNotEmpty) ...[
                Text(
                  t.organizations.pendingInvites,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...pendingInvites.value.map(
                  (invite) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colors.secondaryContainer,
                              child: Icon(
                                Icons.mail_outline_rounded,
                                color: colors.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    invite.organizationName ??
                                        invite.organizationId,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${invite.email} · ${invite.roleName}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final result = await ref
                                    .read(organizationInviteRepositoryProvider)
                                    .accept(invite.id);
                                if (!context.mounted) return;
                                result.fold(
                                  (f) => showErrorSnackBar(
                                    context,
                                    message: f.messageString,
                                  ),
                                  (_) async {
                                    showSuccessSnackBar(
                                      context,
                                      message: t.organizations.inviteAccepted,
                                    );
                                    await ref
                                        .read(
                                          currentOrganizationControllerProvider
                                              .notifier,
                                        )
                                        .refresh();
                                    await loadInvites();
                                  },
                                );
                              },
                              child: Text(t.organizations.accept),
                            ),
                            TextButton(
                              onPressed: () async {
                                final result = await ref
                                    .read(organizationInviteRepositoryProvider)
                                    .decline(invite.id);
                                if (!context.mounted) return;
                                result.fold(
                                  (f) => showErrorSnackBar(
                                    context,
                                    message: f.messageString,
                                  ),
                                  (_) {
                                    showSuccessSnackBar(
                                      context,
                                      message: t.organizations.inviteDeclined,
                                    );
                                    loadInvites();
                                  },
                                );
                              },
                              child: Text(t.organizations.decline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                t.organizations.yourOrganizations,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...memberships.map((membership) {
                final isCurrent = membership.organizationId == currentOrg?.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MembershipCard(
                    membership: membership,
                    isCurrent: isCurrent,
                    onOpen: () => OrganizationDetailRoute(
                      id: membership.organizationId,
                    ).goScoped(context),
                    onSwitch: isCurrent
                        ? null
                        : () {
                            final targetOrg = membership.organization;
                            final routerState = GoRouterState.of(context);
                            final isScoped =
                                routerState.pathParameters['orgSlug'] != null;
                            final currentLocation = routerState.uri.path;
                            ref
                                .read(
                                  currentOrganizationControllerProvider
                                      .notifier,
                                )
                                .switchOrganization(
                              membership.organizationId,
                              afterSelect: () async {
                                if (!context.mounted || targetOrg == null) {
                                  return;
                                }
                                final slug = targetOrg.slug;
                                final branchSlug = await ref
                                    .read(
                                      currentBranchControllerProvider.notifier,
                                    )
                                    .defaultBranchSlug();
                                if (!context.mounted) return;
                                final target = isScoped
                                    ? RouterUtils.pathAfterOrganizationSwitch(
                                        currentLocation,
                                        orgSlug: slug,
                                        branchSlug: branchSlug,
                                      )
                                    : '/$slug/$branchSlug${DashboardRoute.path}';
                                context.go(target);
                              },
                            );
                          },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.membership,
    required this.isCurrent,
    required this.onOpen,
    this.onSwitch,
  });

  final OrganizationMembership membership;
  final bool isCurrent;
  final VoidCallback onOpen;
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final org = membership.organization;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              OrganizationLetterMark(
                name: membership.organizationName,
                logoUrl: org?.logoUrl,
                size: 44,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.organizationName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t.organizations.yourRole}: ${membership.roleName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isCurrent)
                Chip(
                  label: Text(t.organizations.current),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                  backgroundColor: colors.primaryContainer,
                  labelStyle: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (onSwitch != null)
                TextButton(
                  onPressed: onSwitch,
                  child: Text(t.organizations.switchToThis),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
