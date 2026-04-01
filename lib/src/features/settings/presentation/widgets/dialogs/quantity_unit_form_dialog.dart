import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../quantity_units/domain/quantity_unit.dart';
import '../../controllers/quantity_units_controller.dart';

/// Dialog for creating or editing a quantity unit.
class QuantityUnitFormDialog extends HookConsumerWidget {
  const QuantityUnitFormDialog({
    super.key,
    this.unit,
  });

  final QuantityUnit? unit;

  bool get isEditing => unit != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': unit!.name,
              'shortSingular': unit!.shortSingular,
              'shortPlural': unit!.shortPlural,
              'longSingular': unit!.longSingular,
              'longPlural': unit!.longPlural,
            }
          : null,
    );

    // UI state
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

      final unitData = QuantityUnit(
        id: unit?.id ?? '',
        name: (values['name'] as String).trim(),
        shortSingular: (values['shortSingular'] as String).trim(),
        shortPlural: (values['shortPlural'] as String).trim(),
        longSingular: (values['longSingular'] as String).trim(),
        longPlural: (values['longPlural'] as String).trim(),
      );

      bool success;
      if (isEditing) {
        success = await ref
            .read(quantityUnitsControllerProvider.notifier)
            .updateUnit(unitData);
      } else {
        success = await ref
            .read(quantityUnitsControllerProvider.notifier)
            .createUnit(unitData);
      }

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save quantity unit. Please try again.'],
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
              ? 'Quantity unit updated successfully'
              : 'Quantity unit created successfully',
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
                        isEditing ? 'Edit Quantity Unit' : 'New Quantity Unit',
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
                          initialValue: unit?.name,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            hintText: 'e.g., kilograms',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Name is required',
                          ),
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),

                        // Short forms row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'shortSingular',
                                initialValue: unit?.shortSingular,
                                decoration: const InputDecoration(
                                  labelText: 'Short Singular *',
                                  hintText: 'e.g., kg',
                                  border: OutlineInputBorder(),
                                ),
                                enabled: !isSaving.value,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Required',
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'shortPlural',
                                initialValue: unit?.shortPlural,
                                decoration: const InputDecoration(
                                  labelText: 'Short Plural *',
                                  hintText: 'e.g., kg',
                                  border: OutlineInputBorder(),
                                ),
                                enabled: !isSaving.value,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Required',
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Long forms row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'longSingular',
                                initialValue: unit?.longSingular,
                                decoration: const InputDecoration(
                                  labelText: 'Long Singular *',
                                  hintText: 'e.g., kilogram',
                                  border: OutlineInputBorder(),
                                ),
                                enabled: !isSaving.value,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Required',
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'longPlural',
                                initialValue: unit?.longPlural,
                                decoration: const InputDecoration(
                                  labelText: 'Long Plural *',
                                  hintText: 'e.g., kilograms',
                                  border: OutlineInputBorder(),
                                ),
                                enabled: !isSaving.value,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Required',
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => handleSave(),
                              ),
                            ),
                          ],
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
    'shortSingular': 'Short Singular',
    'shortPlural': 'Short Plural',
    'longSingular': 'Long Singular',
    'longPlural': 'Long Plural',
  };
}

/// Shows the quantity unit form dialog.
void showQuantityUnitFormDialog(
  BuildContext context, {
  QuantityUnit? unit,
}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => QuantityUnitFormDialog(unit: unit),
  );
}
