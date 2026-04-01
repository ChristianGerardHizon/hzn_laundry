import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../controllers/pos_groups_controller.dart';

/// Shows a dialog for creating or editing a POS group name.
Future<bool> showPosGroupFormDialog(
  BuildContext context, {
  String? groupId,
  String? initialName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _PosGroupFormDialog(
      groupId: groupId,
      initialName: initialName,
    ),
  );
  return result ?? false;
}

class _PosGroupFormDialog extends HookConsumerWidget {
  const _PosGroupFormDialog({
    this.groupId,
    this.initialName,
  });

  final String? groupId;
  final String? initialName;

  bool get isEditing => groupId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final name = formKey.currentState!.value['name'] as String;
      isSaving.value = true;

      final controller = ref.read(posGroupsControllerProvider.notifier);
      final String? error;

      if (isEditing) {
        error = await controller.updateGroup(groupId!, name);
      } else {
        error = await controller.createGroup(name);
      }

      isSaving.value = false;

      if (error == null && context.mounted) {
        Navigator.of(context).pop(true);
      } else if (context.mounted) {
        showErrorSnackBar(context,
            message: error ?? 'Unknown error', useRootMessenger: false);
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: Text(isEditing ? 'Edit Group' : 'New Group'),
          content: FormBuilder(
            key: formKey,
            child: FormBuilderTextField(
              name: 'name',
              initialValue: initialName,
              decoration: const InputDecoration(
                labelText: 'Group Name *',
                hintText: 'e.g., Detergents, Wash Services',
              ),
              autofocus: true,
              validator: FormBuilderValidators.required(),
              onSubmitted: (_) => handleSave(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
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
                  : Text(isEditing ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
