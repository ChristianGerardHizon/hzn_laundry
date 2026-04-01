import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/storage_location.dart';
import '../controllers/storage_locations_controller.dart';

/// Dialog for creating or editing a storage location.
class StorageLocationFormDialog extends HookConsumerWidget {
  const StorageLocationFormDialog({
    super.key,
    this.storage,
  });

  final StorageLocation? storage;

  bool get isEditing => storage != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': storage!.name,
              'isAvailable': storage!.isAvailable,
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
      isSaving.value = true;

      final storageData = StorageLocation(
        id: storage?.id ?? '',
        name: (values['name'] as String).trim(),
        branchId: storage?.branchId,
        isAvailable: values['isAvailable'] as bool? ?? true,
      );

      bool success;
      if (isEditing) {
        success = await ref
            .read(storageLocationsControllerProvider.notifier)
            .updateStorageLocation(storageData);
      } else {
        success = await ref
            .read(storageLocationsControllerProvider.notifier)
            .createStorageLocation(storageData);
      }

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save storage location. Please try again.'],
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
              ? 'Storage location updated successfully'
              : 'Storage location created successfully',
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
              // Header
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
                        isEditing
                            ? 'Edit Storage Location'
                            : 'New Storage Location',
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
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(t.common.save),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Expanded(
                child: FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // Name field
                        FormBuilderTextField(
                          name: 'name',
                          initialValue: storage?.name,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            hintText: 'e.g., Shelf A-1, Rack 3',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory_2),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Name is required',
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 16),

                        // Available switch
                        FormBuilderSwitch(
                          name: 'isAvailable',
                          initialValue: storage?.isAvailable ?? true,
                          title: const Text('Available'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          enabled: !isSaving.value,
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
  };
}

/// Shows the storage location form dialog.
void showStorageLocationFormDialog(BuildContext context,
    {StorageLocation? storage}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => StorageLocationFormDialog(storage: storage),
  );
}
