import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../domain/deduction_type.dart';
import '../../domain/deduction_value_type.dart';
import '../../domain/employee_deduction.dart';
import '../controllers/employee_deductions_controller.dart';

/// Shows a dialog form for creating or editing an employee deduction.
void showDeductionFormDialog(
  BuildContext context, {
  required String employeeId,
  EmployeeDeduction? deduction,
}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => _DeductionFormDialog(
      employeeId: employeeId,
      deduction: deduction,
    ),
  );
}

class _DeductionFormDialog extends HookConsumerWidget {
  const _DeductionFormDialog({
    required this.employeeId,
    this.deduction,
  });

  final String employeeId;
  final EmployeeDeduction? deduction;

  bool get isEditing => deduction != null;

  static final _monthYearFormat = DateFormat('MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'type': deduction!.type,
              'valueType': deduction!.valueType,
              'value': deduction!.value.toString(),
              'name': deduction!.name ?? '',
              'isLifetime': deduction!.isLifetime,
            }
          : null,
    );

    final isSaving = useState(false);
    final selectedType = useState(deduction?.type ?? DeductionType.cashAdvance);
    final selectedValueType =
        useState(deduction?.valueType ?? DeductionValueType.fixed);
    final isLifetime = useState(deduction?.isLifetime ?? true);
    final startMonth = useState<DateTime?>(deduction?.startMonth);
    final endMonth = useState<DateTime?>(deduction?.endMonth);

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

      final valueText = (values['value'] as String?)?.trim() ?? '0';
      final deductionValue = num.tryParse(valueText) ?? 0;
      final customName = (values['name'] as String?)?.trim();

      final controller = ref.read(
        employeeDeductionsControllerProvider(employeeId).notifier,
      );

      bool success;
      if (isEditing) {
        success = await controller.updateDeduction(
          id: deduction!.id,
          type: selectedType.value,
          valueType: selectedValueType.value,
          value: deductionValue,
          name: customName,
          startMonth: startMonth.value,
          endMonth: isLifetime.value ? null : endMonth.value,
          isActive: deduction!.isActive,
        );
      } else {
        success = await controller.createDeduction(
          type: selectedType.value,
          valueType: selectedValueType.value,
          value: deductionValue,
          name: customName,
          startMonth: startMonth.value,
          endMonth: isLifetime.value ? null : endMonth.value,
        );
      }

      if (!success && context.mounted) {
        isSaving.value = false;
        showFormErrorDialog(
          context,
          errors: ['Failed to save deduction. Please try again.'],
        );
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();
        showSuccessSnackBar(
          context,
          message: isEditing
              ? 'Deduction updated successfully'
              : 'Deduction added successfully',
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
                        isEditing ? 'Edit Deduction' : 'New Deduction',
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

              // Form
              Expanded(
                child: FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // Deduction Type
                        FormBuilderDropdown<DeductionType>(
                          name: 'type',
                          initialValue: selectedType.value,
                          decoration: const InputDecoration(
                            labelText: 'Deduction Type *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Please select a type',
                          ),
                          items: DeductionType.values
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.displayName),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) selectedType.value = value;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Custom name (visible when type is "other")
                        if (selectedType.value == DeductionType.other) ...[
                          FormBuilderTextField(
                            name: 'name',
                            initialValue: deduction?.name,
                            decoration: const InputDecoration(
                              labelText: 'Deduction Name *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.label),
                            ),
                            enabled: !isSaving.value,
                            validator: selectedType.value == DeductionType.other
                                ? FormBuilderValidators.required(
                                    errorText: 'Name is required for custom deductions',
                                  )
                                : null,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Value Type (Fixed / Percentage)
                        FormBuilderDropdown<DeductionValueType>(
                          name: 'valueType',
                          initialValue: selectedValueType.value,
                          decoration: const InputDecoration(
                            labelText: 'Value Type *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.tune),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Please select a value type',
                          ),
                          items: DeductionValueType.values
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.displayName),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) selectedValueType.value = value;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Value
                        FormBuilderTextField(
                          name: 'value',
                          initialValue: deduction?.value.toString(),
                          decoration: InputDecoration(
                            labelText: selectedValueType.value ==
                                    DeductionValueType.percentage
                                ? 'Percentage *'
                                : 'Amount *',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              selectedValueType.value ==
                                      DeductionValueType.percentage
                                  ? Icons.percent
                                  : Icons.payments,
                            ),
                            prefixText: selectedValueType.value ==
                                    DeductionValueType.fixed
                                ? '₱ '
                                : null,
                            suffixText: selectedValueType.value ==
                                    DeductionValueType.percentage
                                ? '%'
                                : null,
                          ),
                          enabled: !isSaving.value,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Value is required',
                            ),
                            FormBuilderValidators.numeric(
                              errorText: 'Please enter a valid number',
                            ),
                          ]),
                        ),
                        const SizedBox(height: 24),

                        // Duration Section
                        Text(
                          'Duration',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Start Month
                        _MonthPickerField(
                          label: 'Start Month',
                          value: startMonth.value,
                          enabled: !isSaving.value,
                          onPicked: (v) => startMonth.value = v,
                          onClear: () => startMonth.value = null,
                        ),
                        const SizedBox(height: 16),

                        // Lifetime toggle
                        FormBuilderSwitch(
                          name: 'isLifetime',
                          initialValue: isLifetime.value,
                          title: Text(
                            'Lifetime (no end date)',
                            style: theme.textTheme.bodyMedium,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          enabled: !isSaving.value,
                          onChanged: (value) {
                            isLifetime.value = value ?? true;
                            if (value == true) endMonth.value = null;
                          },
                        ),

                        // End Month (only when not lifetime)
                        if (!isLifetime.value) ...[
                          const SizedBox(height: 16),
                          _MonthPickerField(
                            label: 'End Month',
                            value: endMonth.value,
                            enabled: !isSaving.value,
                            onPicked: (v) => endMonth.value = v,
                            onClear: () => endMonth.value = null,
                          ),
                        ],

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
    'type': 'Deduction Type',
    'valueType': 'Value Type',
    'value': 'Value',
    'name': 'Deduction Name',
  };
}

/// A tappable field that opens a month/year picker dialog.
class _MonthPickerField extends StatelessWidget {
  const _MonthPickerField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onPicked,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final bool enabled;
  final ValueChanged<DateTime> onPicked;
  final VoidCallback onClear;

  static final _monthYearFormat = DateFormat('MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? () => _pickMonth(context) : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_month),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: enabled ? onClear : null,
                )
              : null,
        ),
        child: Text(
          value != null ? _monthYearFormat.format(value!) : 'Not set',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: value != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(now.year, now.month),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (picked != null) {
      // Normalize to first of month
      onPicked(DateTime(picked.year, picked.month));
    }
  }
}
