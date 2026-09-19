import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/routing/router_utils.dart';
import '../../../../core/routing/routes/dashboard.routes.dart';
import '../../../../core/routing/routes/organizations.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/nav_permissions.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../widgets/dialogs/create_organization_setup_dialog.dart';
import '../../../users/domain/user_role.dart';
import '../../data/repositories/organization_invite_repository.dart';
import '../../domain/organization_invite.dart';
import '../controllers/current_organization_controller.dart';

class OrganizationsPage extends HookConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final memberships =
        ref.watch(currentOrganizationControllerProvider.notifier).memberships;
    final currentOrg = orgAsync.value;
    final role = ref.watch(currentUserRoleProvider).value;
    final canCreate =
        role?.hasPermission(Permissions.organizationsCreate) == true ||
            (role?.isAdmin ?? false);

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
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.organizations.noOrganizations),
                    const SizedBox(height: 8),
                    Text(
                      t.organizations.contactAdmin,
                      textAlign: TextAlign.center,
                    ),
                    if (canCreate) ...[
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: openCreateDialog,
                        child: Text(t.organizations.create),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingInvites.value.isNotEmpty) ...[
                Text(
                  t.organizations.pendingInvites,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...pendingInvites.value.map(
                  (invite) => ListTile(
                    title:
                        Text(invite.organizationName ?? invite.organizationId),
                    subtitle: Text('${invite.email} · ${invite.roleName}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                const Divider(),
              ],
              Text(
                t.organizations.yourOrganizations,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...memberships.map((membership) {
                final isCurrent = membership.organizationId == currentOrg?.id;
                return ListTile(
                  title: Text(membership.organizationName),
                  subtitle: Text(
                    '${t.organizations.yourRole}: ${membership.roleName}',
                  ),
                  trailing: isCurrent
                      ? Chip(label: Text(t.organizations.current))
                      : TextButton(
                          onPressed: () {
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
                                .switchOrganization(membership.organizationId)
                                .then((_) {
                              if (!context.mounted || targetOrg == null) {
                                return;
                              }
                              final slug = targetOrg.slug;
                              final target = isScoped
                                  ? RouterUtils.replaceScopeSegment(
                                      currentLocation,
                                      orgSlug: slug,
                                      branchSlug: allBranchesSlug,
                                    )
                                  : '/$slug/$allBranchesSlug${DashboardRoute.path}';
                              context.go(target);
                            });
                          },
                          child: Text(t.organizations.switchToThis),
                        ),
                  onTap: () => OrganizationDetailRoute(id: membership.organizationId)
                      .goScoped(context),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
