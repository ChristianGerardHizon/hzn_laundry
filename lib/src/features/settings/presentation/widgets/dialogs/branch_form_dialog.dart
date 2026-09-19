import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/utils/slugify.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../domain/branch.dart';
import '../../controllers/branches_controller.dart';
import '../../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../controllers/current_branch_controller.dart';

/// Dialog for creating or editing a branch.
class BranchFormDialog extends HookConsumerWidget {
  const BranchFormDialog({
    super.key,
    this.branch,
    this.organizationId,
  });

  final Branch? branch;
  final String? organizationId;

  bool get isEditing => branch != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': branch!.name,
              'slug': branch!.slug,
              'address': branch!.address,
              'contactNumber': branch!.contactNumber,
              'operatingHours': branch!.operatingHours ?? '',
              'cutOffTime': branch!.cutOffTime ?? '',
            }
          : null,
    );

    final isSaving = useState(false);

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();

      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);

        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(context, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;
      final name = (values['name'] as String).trim();
      var slug = (values['slug'] as String?)?.trim().toLowerCase() ?? '';
      if (slug.isEmpty) slug = slugify(name);
      if (slug == allBranchesSlug) {
        showFormErrorDialog(
          context,
          errors: ['Branch slug "$allBranchesSlug" is reserved.'],
        );
        return;
      }

      isSaving.value = true;

      final branchData = Branch(
        id: branch?.id ?? '',
        organizationId: branch?.organizationId ??
            organizationId ??
            ref.read(currentOrganizationIdProvider),
        name: name,
        slug: slug,
        address: (values['address'] as String).trim(),
        contactNumber: (values['contactNumber'] as String).trim(),
        operatingHours: _nullIfEmpty(values['operatingHours'] as String?),
        cutOffTime: _nullIfEmpty(values['cutOffTime'] as String?),
      );

      final success = isEditing
          ? await ref
              .read(branchesControllerProvider.notifier)
              .updateBranch(branchData)
          : await ref
              .read(branchesControllerProvider.notifier)
              .createBranch(branchData);

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save branch. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();

        showSuccessSnackBar(
          context,
          message: isEditing
              ? 'Branch updated successfully'
              : 'Branch created successfully',
        );
      }
    }

    return DialogCloseHandler(
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
                                if (context.mounted) context.pop();
                              }
                            },
                    ),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Branch' : 'New Branch',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: isSaving.value
                            ? null
                            : () async {
                                if (await dirtyGuard.confirmDiscard(context)) {
                                  if (context.mounted) context.pop();
                                }
                              },
                        child: Text(t.common.cancel),
                      ),
                    ),
                    FilledButton(
                      onPressed: isSaving.value ? null : handleSave,
                      child: isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(t.common.save),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'name',
                          initialValue: branch?.name,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            hintText: 'Enter branch name (internal)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.store),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Name is required',
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            if (isEditing) return;
                            formKey.currentState?.fields['slug']
                                ?.didChange(slugify(value ?? ''));
                          },
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'slug',
                          initialValue: branch?.slug,
                          decoration: const InputDecoration(
                            labelText: 'Slug *',
                            hintText: 'url-safe-slug',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.link),
                            helperText:
                                'Used in URLs. Reserved value "all" is not allowed.',
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Slug is required',
                            ),
                            (value) {
                              final v = value?.trim().toLowerCase() ?? '';
                              if (v == allBranchesSlug) {
                                return 'Slug "$allBranchesSlug" is reserved';
                              }
                              if (!RegExp(r'^[a-z0-9-]+$').hasMatch(v)) {
                                return 'Use lowercase letters, numbers, hyphens';
                              }
                              return null;
                            },
                          ]),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'address',
                          initialValue: branch?.address,
                          decoration: const InputDecoration(
                            labelText: 'Address *',
                            hintText: 'Enter address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          enabled: !isSaving.value,
                          maxLines: 2,
                          validator: FormBuilderValidators.required(
                            errorText: 'Address is required',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'contactNumber',
                          initialValue: branch?.contactNumber,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number *',
                            hintText: 'Enter contact number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          enabled: !isSaving.value,
                          keyboardType: TextInputType.phone,
                          validator: FormBuilderValidators.required(
                            errorText: 'Contact number is required',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'operatingHours',
                          initialValue: branch?.operatingHours,
                          decoration: const InputDecoration(
                            labelText: 'Operating Hours',
                            hintText: 'e.g., Mon-Sat 8:00 AM - 5:00 PM',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          enabled: !isSaving.value,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'cutOffTime',
                          initialValue: branch?.cutOffTime,
                          decoration: const InputDecoration(
                            labelText: 'Cut-off Time',
                            hintText: 'e.g., 4:30 PM',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer_off),
                          ),
                          enabled: !isSaving.value,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _fieldLabels = {
    'name': 'Name',
    'slug': 'Slug',
    'address': 'Address',
    'contactNumber': 'Contact Number',
    'operatingHours': 'Operating Hours',
    'cutOffTime': 'Cut-off Time',
  };

  String? _nullIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

/// Shows the branch form dialog.
void showBranchFormDialog(
  BuildContext context, {
  Branch? branch,
  String? organizationId,
}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => BranchFormDialog(
      branch: branch,
      organizationId: organizationId,
    ),
  );
}
