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
import '../../domain/employee.dart';
import '../controllers/employees_controller.dart';

/// Shows a dialog form for creating or editing an employee.
void showEmployeeFormDialog(
  BuildContext context, {
  Employee? employee,
  ValueChanged<Employee>? onSaved,
}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => EmployeeFormDialog(
      employee: employee,
      onSaved: onSaved,
    ),
  );
}

/// Dialog for creating or editing an employee.
class EmployeeFormDialog extends HookConsumerWidget {
  const EmployeeFormDialog({
    super.key,
    this.employee,
    this.onSaved,
  });

  final Employee? employee;
  final ValueChanged<Employee>? onSaved;

  bool get isEditing => employee != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': employee!.name,
              'baseSalary': employee!.baseSalary.toString(),
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

      final salaryText = (values['baseSalary'] as String?)?.trim() ?? '0';
      final baseSalary = num.tryParse(salaryText) ?? 0;

      final employeeData = Employee(
        id: employee?.id ?? '',
        name: (values['name'] as String).trim(),
        baseSalary: baseSalary,
      );

      final controller = ref.read(employeesControllerProvider.notifier);

      Employee? savedEmployee;
      if (isEditing) {
        final success = await controller.updateEmployee(employeeData);
        if (success) savedEmployee = employeeData;
      } else {
        savedEmployee = await controller.createEmployee(employeeData);
      }

      if (savedEmployee == null) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save employee. Please try again.'],
          );
        }
        return;
      }

      onSaved?.call(savedEmployee);

      if (context.mounted) {
        isSaving.value = false;
        context.pop();
        showSuccessSnackBar(
          context,
          message: isEditing
              ? 'Employee updated successfully'
              : 'Employee created successfully',
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
                        isEditing ? 'Edit Employee' : 'New Employee',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: isSaving.value
                            ? null
                            : () async {
                                if (await dirtyGuard
                                    .confirmDiscard(context)) {
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
                        FormBuilderTextField(
                          name: 'name',
                          initialValue: employee?.name,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Name is required',
                          ),
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'baseSalary',
                          initialValue: employee?.baseSalary.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Base Salary',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.payments),
                            prefixText: '₱ ',
                          ),
                          enabled: !isSaving.value,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.numeric(
                              errorText: 'Please enter a valid number',
                            ),
                          ]),
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
    'baseSalary': 'Base Salary',
  };
}
