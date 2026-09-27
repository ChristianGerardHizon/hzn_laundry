import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/foundation/failure.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../organizations/data/repositories/organization_invite_repository.dart';
import '../../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../controllers/org_pending_invites_controller.dart';
import '../../controllers/user_roles_controller.dart';

/// Invite a staff member to the current organization by email + role.
class InviteUserDialog extends HookConsumerWidget {
  const InviteUserDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(formKey: formKey);
    final isSaving = useState(false);
    final rolesAsync = ref.watch(userRolesControllerProvider);
    final org = ref.watch(currentOrganizationControllerProvider).value;

    Future<void> handleInvite() async {
      if (!(formKey.currentState?.saveAndValidate() ?? false)) return;
      if (org == null) {
        showErrorSnackBar(
          context,
          message: 'No organization selected',
          useRootMessenger: false,
        );
        return;
      }

      final values = formKey.currentState!.value;
      isSaving.value = true;

      final result = await ref.read(organizationInviteRepositoryProvider).create(
            organizationId: org.id,
            email: (values['email'] as String).trim().toLowerCase(),
            roleId: values['role'] as String,
          );

      if (!context.mounted) return;
      isSaving.value = false;

      result.fold(
        (f) => showErrorSnackBar(
          context,
          message: f.messageString,
          useRootMessenger: false,
        ),
        (_) async {
          await ref.read(orgPendingInvitesControllerProvider.notifier).refresh();
          if (!context.mounted) return;
          showSuccessSnackBar(
            context,
            message: t.organizations.inviteSent,
            useRootMessenger: false,
          );
          context.pop();
        },
      );
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => DialogCloseHandler(
          onClose: (ctx) => dirtyGuard.confirmDiscard(ctx),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: dirtyGuard.onPopInvokedWithResult,
            child: ConstrainedDialogContent(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: isSaving.value
                              ? null
                              : () async {
                                  if (await dirtyGuard.confirmDiscard(context)) {
                                    if (context.mounted) {
                                      context.pop();
                                    }
                                  }
                                },
                        ),
                        Expanded(
                          child: Text(
                            t.organizations.invitePeople,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: isSaving.value ? null : handleInvite,
                          child: isSaving.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(t.organizations.sendInvite),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: rolesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text(Failure.displayErrorMessage(e)),
                      ),
                      data: (roles) => SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: FormBuilder(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                t.management.usersSubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showInviteUserDialog(BuildContext context) {
  showConstrainedDialog(
    context: context,
    builder: (context) => const InviteUserDialog(),
  );
}
