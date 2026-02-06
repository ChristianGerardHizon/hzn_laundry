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
import '../../domain/machine.dart';
import '../../domain/machine_type.dart';
import '../controllers/machines_controller.dart';

/// Dialog for creating or editing a machine.
class MachineFormDialog extends HookConsumerWidget {
  const MachineFormDialog({
    super.key,
    this.machine,
  });

  final Machine? machine;

  bool get isEditing => machine != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': machine!.name,
              'type': machine!.type,
              'isAvailable': machine!.isAvailable,
              'strictSingleUse': machine!.strictSingleUse,
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

      final machineData = Machine(
        id: machine?.id ?? '',
        name: (values['name'] as String).trim(),
        type: values['type'] as MachineType,
        branchId: machine?.branchId,
        isAvailable: values['isAvailable'] as bool? ?? true,
        strictSingleUse: values['strictSingleUse'] as bool? ?? false,
      );

      bool success;
      if (isEditing) {
        success = await ref
            .read(machinesControllerProvider.notifier)
            .updateMachine(machineData);
      } else {
        success = await ref
            .read(machinesControllerProvider.notifier)
            .createMachine(machineData);
      }

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save machine. Please try again.'],
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
              ? 'Machine updated successfully'
              : 'Machine created successfully',
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
                        isEditing ? 'Edit Machine' : 'New Machine',
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
                          initialValue: machine?.name,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            hintText: 'e.g., Washer #1',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_laundry_service),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Name is required',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Type dropdown
                        FormBuilderDropdown<MachineType>(
                          name: 'type',
                          initialValue:
                              machine?.type ?? MachineType.washer,
                          decoration: const InputDecoration(
                            labelText: 'Type *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Type is required',
                          ),
                          items: MachineType.values
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.displayName),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),

                        // Available switch
                        FormBuilderSwitch(
                          name: 'isAvailable',
                          initialValue: machine?.isAvailable ?? true,
                          title: const Text('Available'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          enabled: !isSaving.value,
                        ),
                        const SizedBox(height: 16),

                        // Strict Single Use switch
                        FormBuilderSwitch(
                          name: 'strictSingleUse',
                          initialValue: machine?.strictSingleUse ?? false,
                          title: const Text('Strict Single Use'),
                          subtitle: Text(
                            'Show warning when assigning to a machine already processing an order',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
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
    'type': 'Type',
  };
}

/// Shows the machine form dialog.
void showMachineFormDialog(BuildContext context, {Machine? machine}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => MachineFormDialog(machine: machine),
  );
}
