import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/nav_permissions.dart';
import '../widgets/dialogs/create_organization_setup_dialog.dart';
import '../../../users/domain/user_role.dart';
import '../../../users/presentation/controllers/user_roles_controller.dart';
import '../../data/repositories/organization_invite_repository.dart';
import '../../data/repositories/organization_repository.dart';
import '../../domain/organization_invite.dart';
import '../../domain/organization_membership.dart';
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
    final selectedId = useState<String?>(currentOrg?.id);
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
    final orgInvites = useState<List<OrganizationInvite>>([]);

    Future<void> loadInvites() async {
      if (email.isNotEmpty) {
        final mine = await ref
            .read(organizationInviteRepositoryProvider)
            .listMine(email);
        mine.fold((_) {}, (list) => pendingInvites.value = list);
      }
      final orgId = selectedId.value ?? currentOrg?.id;
      if (orgId != null) {
        final forOrg = await ref
            .read(organizationInviteRepositoryProvider)
            .listForOrganization(orgId);
        forOrg.fold((_) {}, (list) => orgInvites.value = list);
      }
    }

    useEffect(() {
      loadInvites();
      return null;
    }, [email, selectedId.value, currentOrg?.id]);

    final selected = memberships.cast<OrganizationMembership?>().firstWhere(
          (m) => m?.organizationId == (selectedId.value ?? currentOrg?.id),
          orElse: () => memberships.isNotEmpty ? memberships.first : null,
        );

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
        error: (e, _) => Center(child: Text('$e')),
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
                final isSelected =
                    membership.organizationId == selected?.organizationId;
                return ListTile(
                  selected: isSelected,
                  title: Text(membership.organizationName),
                  subtitle: Text(
                    '${t.organizations.yourRole}: ${membership.roleName}',
                  ),
                  trailing: isCurrent
                      ? Chip(label: Text(t.organizations.current))
                      : TextButton(
                          onPressed: () {
                            ref
                                .read(
                                  currentOrganizationControllerProvider
                                      .notifier,
                                )
                                .switchOrganization(membership.organizationId);
                          },
                          child: Text(t.organizations.switchToThis),
                        ),
                  onTap: () => selectedId.value = membership.organizationId,
                );
              }),
              if (selected?.organization != null) ...[
                const Divider(),
                _OrgDetailsSection(
                  membership: selected!,
                  orgInvites: orgInvites.value,
                  onChanged: loadInvites,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OrgDetailsSection extends HookConsumerWidget {
  const _OrgDetailsSection({
    required this.membership,
    required this.orgInvites,
    required this.onChanged,
  });

  final OrganizationMembership membership;
  final List<OrganizationInvite> orgInvites;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final org = membership.organization!;
    final canManage = membership.canManageMembers;
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final rolesAsync = ref.watch(userRolesControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.organizations.details,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        FormBuilder(
          key: formKey,
          initialValue: {
            'name': org.name,
            'contactNumber': org.contactNumber ?? '',
            'address': org.address ?? '',
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'name',
                enabled: canManage,
                decoration: InputDecoration(labelText: t.fields.name),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'contactNumber',
                enabled: canManage,
                decoration: InputDecoration(labelText: t.fields.contactNumber),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'address',
                enabled: canManage,
                decoration: InputDecoration(labelText: t.fields.address),
                maxLines: 2,
              ),
              if (canManage) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.saveAndValidate() ?? false)) {
                        return;
                      }
                      final values = formKey.currentState!.value;
                      final result = await ref
                          .read(organizationRepositoryProvider)
                          .update(
                            org.id,
                            name: values['name'] as String,
                            contactNumber: values['contactNumber'] as String?,
                            address: values['address'] as String?,
                          );
                      if (!context.mounted) return;
                      result.fold(
                        (f) => showErrorSnackBar(
                          context,
                          message: f.messageString,
                        ),
                        (_) async {
                          showSuccessSnackBar(
                            context,
                            message: t.organizations.saveSuccess,
                          );
                          await ref
                              .read(currentOrganizationControllerProvider
                                  .notifier)
                              .refresh();
                        },
                      );
                    },
                    child: Text(t.organizations.saveDetails),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (canManage) ...[
          const SizedBox(height: 24),
          Text(
            t.organizations.invitePeople,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          rolesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (roles) => _InviteForm(
              orgId: org.id,
              roles: roles,
              onSent: onChanged,
            ),
          ),
          if (orgInvites.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t.organizations.pendingOrgInvites),
            ...orgInvites.map(
              (invite) => ListTile(
                title: Text(invite.email),
                subtitle: Text(invite.roleName),
                trailing: TextButton(
                  onPressed: () async {
                    final result = await ref
                        .read(organizationInviteRepositoryProvider)
                        .revoke(invite.id);
                    if (!context.mounted) return;
                    result.fold(
                      (f) => showErrorSnackBar(
                        context,
                        message: f.messageString,
                      ),
                      (_) {
                        showSuccessSnackBar(
                          context,
                          message: t.organizations.inviteRevoked,
                        );
                        onChanged();
                      },
                    );
                  },
                  child: Text(t.organizations.revoke),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _InviteForm extends HookConsumerWidget {
  const _InviteForm({
    required this.orgId,
    required this.roles,
    required this.onSent,
  });

  final String orgId;
  final List<UserRole> roles;
  final Future<void> Function() onSent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final t = Translations.of(context);

    return FormBuilder(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormBuilderTextField(
            name: 'email',
            decoration: InputDecoration(
              labelText: t.organizations.inviteEmail,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.email(),
            ]),
          ),
          const SizedBox(height: 12),
          FormBuilderDropdown<String>(
            name: 'role',
            decoration: InputDecoration(
              labelText: t.organizations.inviteRole,
            ),
            items: roles
                .map(
                  (role) => DropdownMenuItem(
                    value: role.id,
                    child: Text(role.name),
                  ),
                )
                .toList(),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.saveAndValidate() ?? false)) {
                  return;
                }
                final values = formKey.currentState!.value;
                final result =
                    await ref.read(organizationInviteRepositoryProvider).create(
                          organizationId: orgId,
                          email: values['email'] as String,
                          roleId: values['role'] as String,
                        );
                if (!context.mounted) return;
                result.fold(
                  (f) => showErrorSnackBar(context, message: f.messageString),
                  (_) {
                    showSuccessSnackBar(
                      context,
                      message: t.organizations.inviteSent,
                    );
                    formKey.currentState?.reset();
                    onSent();
                  },
                );
              },
              child: Text(t.organizations.sendInvite),
            ),
          ),
        ],
      ),
    );
  }
}
