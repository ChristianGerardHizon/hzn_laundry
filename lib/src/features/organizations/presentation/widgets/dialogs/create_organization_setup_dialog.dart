import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../users/domain/user_role.dart';
import '../../../../users/presentation/controllers/user_roles_controller.dart';
import '../../../data/repositories/organization_repository.dart';
import '../../../domain/organization_setup.dart';
import '../../controllers/current_organization_controller.dart';

/// Opens the create-organization setup wizard.
///
/// Returns `true` when an organization was created.
Future<bool?> showCreateOrganizationSetupDialog(BuildContext context) {
  return showConstrainedDialog<bool>(
    context: context,
    fullScreen: true,
    builder: (context) => ScaffoldMessenger(
      child: Builder(
        builder: (context) => const Scaffold(
          backgroundColor: Colors.transparent,
          body: CreateOrganizationSetupDialog(),
        ),
      ),
    ),
  );
}

class CreateOrganizationSetupDialog extends HookConsumerWidget {
  const CreateOrganizationSetupDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final step = useState(0);
    final isSaving = useState(false);
    final orgFormKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final branchFormKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final inviteFormKey = useMemoized(() => GlobalKey<FormBuilderState>());

    final orgDraft = useState<_OrgDraft?>(null);
    final branchDraft = useState<_BranchDraft?>(null);
    final queuedInvites = useState<List<OrganizationSetupInvite>>(const []);

    final rolesAsync = ref.watch(userRolesControllerProvider);

    bool formHasValue(GlobalKey<FormBuilderState> key) {
      final values = key.currentState?.instantValue ?? {};
      return values.values.any((value) {
        if (value == null) return false;
        if (value is String) return value.trim().isNotEmpty;
        return true;
      });
    }

    bool isDirty() {
      if (formHasValue(orgFormKey) || formHasValue(branchFormKey)) return true;
      if (queuedInvites.value.isNotEmpty) return true;
      return false;
    }

    Future<bool> confirmDiscard(BuildContext ctx) async {
      if (isSaving.value) return false;
      if (!isDirty()) return true;
      return showDiscardChangesDialog(ctx);
    }

    Future<void> close() async {
      if (await confirmDiscard(context) && context.mounted) {
        context.pop();
      }
    }

    _OrgDraft? readOrgDraft() {
      final state = orgFormKey.currentState;
      if (state == null) return orgDraft.value;
      state.save();
      final values = state.value;
      return _OrgDraft(
        name: (values['name'] as String?)?.trim() ?? '',
        contactNumber: (values['contactNumber'] as String?)?.trim() ?? '',
        address: (values['address'] as String?)?.trim() ?? '',
      );
    }

    _BranchDraft? readBranchDraft() {
      final state = branchFormKey.currentState;
      if (state == null) return branchDraft.value;
      state.save();
      final values = state.value;
      return _BranchDraft(
        name: (values['name'] as String?)?.trim() ?? '',
        address: (values['address'] as String?)?.trim() ?? '',
        contactNumber: (values['contactNumber'] as String?)?.trim() ?? '',
        operatingHours: (values['operatingHours'] as String?)?.trim() ?? '',
        cutOffTime: (values['cutOffTime'] as String?)?.trim() ?? '',
      );
    }

    bool validateCurrentStep() {
      if (step.value == 0) {
        if (!(orgFormKey.currentState?.saveAndValidate() ?? false)) {
          final errors = orgFormKey.currentState?.errors ?? {};
          final messages = formatFormErrors(errors, {
            'name': t.fields.name,
            'contactNumber': t.fields.contactNumber,
            'address': t.fields.address,
          });
          if (messages.isNotEmpty) {
            showFormErrorDialog(context, errors: messages);
          }
          return false;
        }
        orgDraft.value = readOrgDraft();
        return true;
      }

      if (step.value == 1) {
        if (!(branchFormKey.currentState?.saveAndValidate() ?? false)) {
          final errors = branchFormKey.currentState?.errors ?? {};
          final messages = formatFormErrors(errors, {
            'name': t.fields.name,
            'address': t.fields.address,
            'contactNumber': t.fields.contactNumber,
            'operatingHours': t.organizations.operatingHours,
            'cutOffTime': t.organizations.cutOffTime,
          });
          if (messages.isNotEmpty) {
            showFormErrorDialog(context, errors: messages);
          }
          return false;
        }
        branchDraft.value = readBranchDraft();
        return true;
      }

      return true;
    }

    Future<void> handleCreate() async {
      final orgValid = orgFormKey.currentState?.saveAndValidate() ?? false;
      if (!orgValid) {
        step.value = 0;
        return;
      }
      final branchValid =
          branchFormKey.currentState?.saveAndValidate() ?? false;
      if (!branchValid) {
        step.value = 1;
        return;
      }
      final org = readOrgDraft();
      final branch = readBranchDraft();
      if (org == null || org.name.isEmpty || branch == null) {
        step.value = org == null || org.name.isEmpty ? 0 : 1;
        return;
      }

      isSaving.value = true;
      final result = await ref.read(organizationRepositoryProvider).create(
            name: org.name,
            contactNumber: org.contactNumber,
            address: org.address,
            branch: OrganizationSetupBranch(
              name: branch.name,
              address: branch.address,
              contactNumber: branch.contactNumber,
              operatingHours:
                  branch.operatingHours.isEmpty ? null : branch.operatingHours,
              cutOffTime: branch.cutOffTime.isEmpty ? null : branch.cutOffTime,
            ),
            invites: queuedInvites.value,
          );
      isSaving.value = false;

      await result.fold(
        (failure) async {
          if (context.mounted) {
            showErrorSnackBar(
              context,
              message: failure.messageString,
              useRootMessenger: false,
            );
          }
        },
        (created) async {
          await ref
              .read(currentOrganizationControllerProvider.notifier)
              .selectOrganization(created.id);
          if (context.mounted) {
            context.pop(true);
          }
        },
      );
    }

    final stepTitles = [
      t.organizations.stepDetailsShort,
      t.organizations.stepBranchShort,
      t.organizations.stepInviteShort,
      t.organizations.stepReviewShort,
    ];

    return DialogCloseHandler(
      onClose: confirmDiscard,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (await confirmDiscard(context) && context.mounted) {
            context.pop();
          }
        },
        child: ConstrainedDialogContent(
          fullScreen: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: t.common.cancel,
                      onPressed: isSaving.value ? null : close,
                    ),
                    Expanded(
                      child: Text(
                        t.organizations.setupTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (!isSaving.value)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: TextButton(
                          onPressed: close,
                          child: Text(t.common.cancel),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _StepIndicator(
                  currentStep: step.value,
                  steps: stepTitles,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    [
                      t.organizations.stepDetails,
                      t.organizations.stepBranch,
                      t.organizations.stepInvite,
                      t.organizations.stepReview,
                    ][step.value],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: IndexedStack(
                  index: step.value,
                  children: [
                    _DetailsStep(formKey: orgFormKey, enabled: !isSaving.value),
                    _BranchStep(
                      formKey: branchFormKey,
                      enabled: !isSaving.value,
                    ),
                    rolesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => ErrorState.fromError(e),
                      data: (roles) => _InviteStep(
                        formKey: inviteFormKey,
                        roles: roles,
                        queued: queuedInvites.value,
                        enabled: !isSaving.value,
                        onQueuedChanged: (value) => queuedInvites.value = value,
                      ),
                    ),
                    _ReviewStep(
                      org: orgDraft.value,
                      branch: branchDraft.value,
                      inviteCount: queuedInvites.value.length,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    if (step.value > 0)
                      TextButton(
                        onPressed: isSaving.value ? null : () => step.value--,
                        child: Text(t.organizations.back),
                      ),
                    const Spacer(),
                    if (step.value == 2)
                      TextButton(
                        onPressed: isSaving.value ? null : () => step.value = 3,
                        child: Text(t.organizations.skip),
                      ),
                    FilledButton(
                      onPressed: isSaving.value
                          ? null
                          : () {
                              if (step.value < 3) {
                                if (validateCurrentStep()) {
                                  step.value++;
                                }
                                return;
                              }
                              handleCreate();
                            },
                      child: isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              step.value == 3
                                  ? t.organizations.finish
                                  : t.organizations.next,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrgDraft {
  const _OrgDraft({
    required this.name,
    required this.contactNumber,
    required this.address,
  });

  final String name;
  final String contactNumber;
  final String address;
}

class _BranchDraft {
  const _BranchDraft({
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.operatingHours,
    required this.cutOffTime,
  });

  final String name;
  final String address;
  final String contactNumber;
  final String operatingHours;
  final String cutOffTime;
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= currentStep
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= currentStep
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
                child: Center(
                  child: i < currentStep
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        )
                      : Text(
                          '${i + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: i == currentStep
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: i <= currentStep
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      i == currentStep ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.formKey,
    required this.enabled,
  });

  final GlobalKey<FormBuilderState> formKey;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return FormBuilder(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          FormBuilderTextField(
            name: 'name',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: '${t.fields.name} *',
              border: const OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.required(),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'contactNumber',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: t.fields.contactNumber,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'address',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: t.fields.address,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _BranchStep extends StatelessWidget {
  const _BranchStep({
    required this.formKey,
    required this.enabled,
  });

  final GlobalKey<FormBuilderState> formKey;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return FormBuilder(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          FormBuilderTextField(
            name: 'name',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: '${t.fields.name} *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.store),
            ),
            validator: FormBuilderValidators.required(),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'address',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: '${t.fields.address} *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.location_on),
            ),
            maxLines: 2,
            validator: FormBuilderValidators.required(),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'contactNumber',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: '${t.fields.contactNumber} *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: FormBuilderValidators.required(),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'operatingHours',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: t.organizations.operatingHours,
              hintText: 'e.g., Mon-Sat 8:00 AM - 5:00 PM',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.schedule),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'cutOffTime',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: t.organizations.cutOffTime,
              hintText: 'e.g., 4:30 PM',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.timer_off),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteStep extends StatelessWidget {
  const _InviteStep({
    required this.formKey,
    required this.roles,
    required this.queued,
    required this.enabled,
    required this.onQueuedChanged,
  });

  final GlobalKey<FormBuilderState> formKey;
  final List<UserRole> roles;
  final List<OrganizationSetupInvite> queued;
  final bool enabled;
  final ValueChanged<List<OrganizationSetupInvite>> onQueuedChanged;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return FormBuilder(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          FormBuilderTextField(
            name: 'email',
            enabled: enabled,
            decoration: InputDecoration(
              labelText: t.organizations.inviteEmail,
              border: const OutlineInputBorder(),
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
            enabled: enabled,
            decoration: InputDecoration(
              labelText: t.organizations.inviteRole,
              border: const OutlineInputBorder(),
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
            onPressed: enabled
                ? () {
                    if (!(formKey.currentState?.saveAndValidate() ?? false)) {
                      return;
                    }
                    final values = formKey.currentState!.value;
                    final email =
                        (values['email'] as String).trim().toLowerCase();
                    final roleId = values['role'] as String;
                    if (queued.any((i) => i.email == email)) {
                      showErrorSnackBar(
                        context,
                        message: t.organizations.inviteAlreadyQueued,
                        useRootMessenger: false,
                      );
                      return;
                    }
                    final roleName = roles
                        .cast<UserRole?>()
                        .firstWhere(
                          (r) => r?.id == roleId,
                          orElse: () => null,
                        )
                        ?.name;
                    onQueuedChanged([
                      ...queued,
                      OrganizationSetupInvite(
                        email: email,
                        roleId: roleId,
                        roleName: roleName,
                      ),
                    ]);
                    formKey.currentState?.fields['email']?.didChange('');
                    showSuccessSnackBar(
                      context,
                      message: t.organizations.inviteQueued,
                      useRootMessenger: false,
                    );
                  }
                : null,
            child: Text(t.organizations.addInvite),
          ),
          const SizedBox(height: 24),
          Text(
            t.organizations.queuedInvites,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (queued.isEmpty)
            Text(t.organizations.noInvitesQueued)
          else
            ...queued.map(
              (invite) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mail_outline),
                title: Text(invite.email),
                subtitle: Text(invite.roleName ?? ''),
                trailing: IconButton(
                  tooltip: t.organizations.removeInvite,
                  onPressed: enabled
                      ? () => onQueuedChanged(
                            queued
                                .where((i) => i.email != invite.email)
                                .toList(),
                          )
                      : null,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.org,
    required this.branch,
    required this.inviteCount,
  });

  final _OrgDraft? org;
  final _BranchDraft? branch;
  final int inviteCount;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final none = t.organizations.reviewNone;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        ListTile(
          title: Text(t.organizations.stepDetails),
          subtitle: Text(org?.name.isNotEmpty == true ? org!.name : none),
        ),
        ListTile(
          title: Text(t.fields.contactNumber),
          subtitle: Text(
            org?.contactNumber.isNotEmpty == true ? org!.contactNumber : none,
          ),
        ),
        ListTile(
          title: Text(t.fields.address),
          subtitle: Text(
            org?.address.isNotEmpty == true ? org!.address : none,
          ),
        ),
        const Divider(),
        ListTile(
          title: Text(t.organizations.stepBranch),
          subtitle: Text(
            branch?.name.isNotEmpty == true ? branch!.name : none,
          ),
        ),
        ListTile(
          title: Text(t.fields.address),
          subtitle: Text(
            branch?.address.isNotEmpty == true ? branch!.address : none,
          ),
        ),
        const Divider(),
        ListTile(
          title: Text(t.organizations.stepInvite),
          subtitle: Text(t.organizations.reviewInviteCount(n: inviteCount)),
        ),
      ],
    );
  }
}
