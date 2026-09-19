import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/foundation/failure.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
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

    final orgId = ref.watch(currentOrganizationIdProvider);
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final branchesAsync = ref.watch(branchesControllerProvider);

    final initialBranchIds = useMemoized(() {
      if (isEditing) return List<String>.from(employee!.branchIds);
      if (currentBranchId != null && currentBranchId.isNotEmpty) {
        return [currentBranchId];
      }
      return <String>[];
    }, [employee?.id, currentBranchId]);

    final selectedBranchIds = useState<List<String>>(initialBranchIds);

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
      if (orgId == null || orgId.isEmpty) {
        showFormErrorDialog(
          context,
          errors: ['Select an organization before saving an employee.'],
        );
        return;
      }

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
        organizationId: isEditing ? employee!.organizationId : orgId,
        branchIds: selectedBranchIds.value,
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
                        const SizedBox(height: 16),
                        Text(
                          'Assigned Branches',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Leave empty to assign to all branches in this organization.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        branchesAsync.when(
                          data: (branches) => _BranchFilterChips(
                            branches: branches,
                            selectedIds: selectedBranchIds.value,
                            enabled: !isSaving.value,
                            onChanged: (ids) =>
                                selectedBranchIds.value = ids,
                          ),
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          ),
                          error: (error, _) => Text(
                            'Failed to load branches: ${Failure.displayErrorMessage(error)}',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
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

class _BranchFilterChips extends StatelessWidget {
  const _BranchFilterChips({
    required this.branches,
    required this.selectedIds,
    required this.onChanged,
    required this.enabled,
  });

  final List<Branch> branches;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) {
      return const Text('No branches in this organization.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: branches.map((branch) {
        final selected = selectedIds.contains(branch.id);
        return FilterChip(
          label: Text(branch.name),
          selected: selected,
          onSelected: enabled
              ? (value) {
                  final next = List<String>.from(selectedIds);
                  if (value) {
                    next.add(branch.id);
                  } else {
                    next.remove(branch.id);
                  }
                  onChanged(next);
                }
              : null,
        );
      }).toList(),
    );
  }
}
