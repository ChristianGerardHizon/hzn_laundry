import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../domain/load_rule.dart';
import '../controllers/load_rules_controller.dart';

/// Dialog for creating or editing a machine load rule (a weight tier).
class LoadRuleFormDialog extends HookConsumerWidget {
  const LoadRuleFormDialog({
    super.key,
    required this.machineId,
    this.rule,
  });

  final String machineId;
  final LoadRule? rule;

  bool get isEditing => rule != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      final minWeight =
          double.tryParse((values['minWeight'] as String?)?.trim() ?? '');
      final maxRaw = (values['maxWeight'] as String?)?.trim() ?? '';
      final maxWeight = maxRaw.isEmpty ? null : double.tryParse(maxRaw);
      final loadCount =
          int.tryParse((values['loadCount'] as String?)?.trim() ?? '') ?? 0;

      // Guard: max must be >= min when both are provided.
      if (minWeight != null && maxWeight != null && maxWeight < minWeight) {
        showErrorSnackBar(
          context,
          message: 'Max weight must be greater than or equal to min weight',
          useRootMessenger: false,
        );
        return;
      }

      isSaving.value = true;

      final ruleData = LoadRule(
        id: rule?.id ?? '',
        machineId: machineId,
        loadCount: loadCount,
        minWeight: minWeight,
        maxWeight: maxWeight,
      );

      final controller =
          ref.read(loadRulesControllerProvider(machineId).notifier);
      final success = isEditing
          ? await controller.updateRule(ruleData)
          : await controller.createRule(ruleData);

      if (!context.mounted) return;
      isSaving.value = false;

      if (success) {
        Navigator.of(context).pop();
        showSuccessSnackBar(
          context,
          message: isEditing ? 'Load rule updated' : 'Load rule added',
          useRootMessenger: false,
        );
      } else {
        showErrorSnackBar(
          context,
          message: 'Failed to save load rule. Please try again.',
          useRootMessenger: false,
        );
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: Text(isEditing ? 'Edit Load Rule' : 'New Load Rule'),
          content: FormBuilder(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'minWeight',
                          initialValue: rule?.minWeight?.toString() ?? '0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Min kg *',
                            hintText: '0',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            FormBuilderValidators.min(0),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'maxWeight',
                          initialValue: rule?.maxWeight?.toString() ?? '',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Max kg',
                            hintText: 'and up',
                            helperText: 'Leave blank for no upper limit',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.numeric(
                              errorText: 'Enter a number',
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'loadCount',
                    initialValue: rule?.loadCount.toString() ?? '1',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Loads *',
                      hintText: 'e.g., 1',
                      prefixIcon: Icon(Icons.local_laundry_service),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.integer(),
                      FormBuilderValidators.min(1),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  isSaving.value ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSaving.value ? null : handleSave,
              child: isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the load rule form dialog for [machineId].
void showLoadRuleFormDialog(
  BuildContext context, {
  required String machineId,
  LoadRule? rule,
}) {
  showDialog(
    context: context,
    builder: (context) => LoadRuleFormDialog(machineId: machineId, rule: rule),
  );
}
