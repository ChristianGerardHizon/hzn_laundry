import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/organizations.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/widgets/dialogs/branch_form_dialog.dart';
import '../../../users/domain/user_role.dart';
import '../../../users/presentation/controllers/user_roles_controller.dart';
import '../../data/repositories/organization_invite_repository.dart';
import '../../data/repositories/organization_repository.dart';
import '../controllers/current_organization_controller.dart';

class OrganizationSetupWalkthroughPage extends HookConsumerWidget {
  const OrganizationSetupWalkthroughPage({super.key, required this.orgId});

  final String orgId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = useState(0);
    final isSaving = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final t = Translations.of(context);
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final org = orgAsync.value;
    final branchesAsync = ref.watch(branchesControllerProvider);
    final rolesAsync = ref.watch(userRolesControllerProvider);

    Future<void> saveDetailsAndNext() async {
      if (!(formKey.currentState?.saveAndValidate() ?? false)) return;
      final values = formKey.currentState!.value;
      isSaving.value = true;
      final result = await ref.read(organizationRepositoryProvider).update(
            orgId,
            name: (values['name'] as String).trim(),
            contactNumber: (values['contactNumber'] as String?)?.trim(),
            address: (values['address'] as String?)?.trim(),
          );
      isSaving.value = false;
      result.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(context, message: failure.messageString);
          }
        },
        (_) => step.value = 1,
      );
    }

    Future<void> finish() async {
      isSaving.value = true;
      final result = await ref.read(organizationRepositoryProvider).update(
            orgId,
            onboardingCompletedAt: DateTime.now().toUtc(),
          );
      isSaving.value = false;
      result.fold(
        (failure) {
          if (context.mounted) {
            showErrorSnackBar(context, message: failure.messageString);
          }
        },
        (_) async {
          await ref
              .read(currentOrganizationControllerProvider.notifier)
              .refresh();
          if (context.mounted) {
            showSuccessSnackBar(
              context,
              message: t.organizations.onboardingComplete,
            );
            const OrganizationsRoute().go(context);
          }
        },
      );
    }

    final titles = [
      t.organizations.stepDetails,
      t.organizations.stepBranch,
      t.organizations.stepInvite,
      t.organizations.stepReview,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.organizations.setupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${step.value + 1}/4  ${titles[step.value]}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: switch (step.value) {
                0 => FormBuilder(
                    key: formKey,
                    initialValue: {
                      'name': org?.name ?? '',
                      'contactNumber': org?.contactNumber ?? '',
                      'address': org?.address ?? '',
                    },
                    child: ListView(
                      children: [
                        FormBuilderTextField(
                          name: 'name',
                          decoration: InputDecoration(
                            labelText: '${t.fields.name} *',
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'contactNumber',
                          decoration: InputDecoration(
                            labelText: t.fields.contactNumber,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'address',
                          decoration: InputDecoration(
                            labelText: t.fields.address,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                1 => branchesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (branches) {
                      final orgBranches = branches
                          .where((b) => b.organizationId == orgId)
                          .toList();
                      return Column(
                        children: [
                          if (orgBranches.isEmpty)
                            Text(t.organizations.noBranchYet),
                          ...orgBranches.map((b) => ListTile(
                                leading: const Icon(Icons.store),
                                title: Text(b.name),
                                subtitle: Text(b.address),
                              )),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () => showBranchFormDialog(
                              context,
                              organizationId: orgId,
                            ),
                            icon: const Icon(Icons.add),
                            label: Text(t.organizations.addBranch),
                          ),
                        ],
                      );
                    },
                  ),
                2 => rolesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (roles) => _WalkthroughInviteForm(
                      orgId: orgId,
                      roles: roles,
                    ),
                  ),
                _ => orgAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (current) => ListView(
                      children: [
                        ListTile(
                          title: Text(t.fields.name),
                          subtitle: Text(current?.name ?? ''),
                        ),
                        ListTile(
                          title: Text(t.fields.contactNumber),
                          subtitle: Text(current?.contactNumber ?? '—'),
                        ),
                        ListTile(
                          title: Text(t.fields.address),
                          subtitle: Text(current?.address ?? '—'),
                        ),
                      ],
                    ),
                  ),
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (step.value > 0)
                  TextButton(
                    onPressed: () => step.value--,
                    child: Text(t.organizations.back),
                  ),
                const Spacer(),
                if (step.value == 2)
                  TextButton(
                    onPressed: () => step.value = 3,
                    child: Text(t.organizations.skip),
                  ),
                FilledButton(
                  onPressed: isSaving.value
                      ? null
                      : () {
                          if (step.value == 0) {
                            saveDetailsAndNext();
                            return;
                          }
                          if (step.value == 1) {
                            final branches =
                                ref.read(branchesControllerProvider).value ??
                                    [];
                            final hasBranch = branches.any(
                              (b) => b.organizationId == orgId,
                            );
                            if (!hasBranch) {
                              showErrorSnackBar(
                                context,
                                message: t.organizations.branchRequired,
                              );
                              return;
                            }
                            step.value = 2;
                            return;
                          }
                          if (step.value == 2) {
                            step.value = 3;
                            return;
                          }
                          finish();
                        },
                  child: Text(
                    step.value == 3
                        ? t.organizations.finish
                        : t.organizations.next,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkthroughInviteForm extends HookConsumerWidget {
  const _WalkthroughInviteForm({
    required this.orgId,
    required this.roles,
  });

  final String orgId;
  final List<UserRole> roles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final t = Translations.of(context);

    return FormBuilder(
      key: formKey,
      child: ListView(
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              if (!(formKey.currentState?.saveAndValidate() ?? false)) return;
              final values = formKey.currentState!.value;
              final result =
                  await ref.read(organizationInviteRepositoryProvider).create(
                        organizationId: orgId,
                        email: values['email'] as String,
                        roleId: values['role'] as String,
                      );
              if (!context.mounted) return;
              result.fold(
                (failure) =>
                    showErrorSnackBar(context, message: failure.messageString),
                (_) {
                  showSuccessSnackBar(
                    context,
                    message: t.organizations.inviteSent,
                  );
                  formKey.currentState?.fields['email']?.didChange('');
                },
              );
            },
            child: Text(t.organizations.sendInvite),
          ),
        ],
      ),
    );
  }
}
