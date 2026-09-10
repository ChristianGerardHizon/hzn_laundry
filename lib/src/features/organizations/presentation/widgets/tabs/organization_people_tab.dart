import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../users/domain/user_role.dart';
import '../../../../users/presentation/controllers/user_roles_controller.dart';
import '../../../data/repositories/organization_invite_repository.dart';
import '../../../data/repositories/organization_membership_repository.dart';
import '../../../domain/organization_invite.dart';
import '../../../domain/organization_membership.dart';
import '../../controllers/current_organization_controller.dart';

class OrganizationPeopleTab extends HookConsumerWidget {
  const OrganizationPeopleTab({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final membership = ref
        .watch(currentOrganizationControllerProvider.notifier)
        .membershipFor(organizationId);
    final canManage = membership?.canManageMembers ?? false;
    final members = useState<List<OrganizationMembership>>([]);
    final orgInvites = useState<List<OrganizationInvite>>([]);
    final rolesAsync = ref.watch(userRolesControllerProvider);

    Future<void> load() async {
      final membersResult = await ref
          .read(organizationMembershipRepositoryProvider)
          .listForOrganization(organizationId);
      membersResult.fold((_) {}, (list) => members.value = list);

      final invitesResult = await ref
          .read(organizationInviteRepositoryProvider)
          .listForOrganization(organizationId);
      invitesResult.fold((_) {}, (list) => orgInvites.value = list);
    }

    useEffect(() {
      load();
      return null;
    }, [organizationId]);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t.organizations.members,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (members.value.isEmpty)
          Text(t.organizations.noMembers)
        else
          ...members.value.map(
            (m) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(m.roleName.isEmpty ? m.userId : m.roleName),
              subtitle: Text(m.userId),
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
              orgId: organizationId,
              roles: roles,
              onSent: load,
            ),
          ),
          if (orgInvites.value.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t.organizations.pendingOrgInvites),
            ...orgInvites.value.map(
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
                        load();
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
