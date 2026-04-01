import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/promo.dart';
import '../controllers/promos_controller.dart';

/// Shows the promo create/edit dialog.
///
/// Returns `true` if a promo was created or updated.
Future<bool?> showPromoFormDialog(
  BuildContext context, {
  Promo? promo,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _PromoFormDialog(promo: promo),
  );
}

class _PromoFormDialog extends HookConsumerWidget {
  const _PromoFormDialog({this.promo});

  final Promo? promo;

  bool get isEditing => promo != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      isSaving.value = true;

      final branchId = ref.read(currentBranchIdProvider);

      final promoData = Promo(
        id: promo?.id ?? '',
        name: values['name'] as String,
        description: values['description'] as String?,
        startDate: values['startDate'] as DateTime,
        endDate: values['endDate'] as DateTime,
        requiredOrders: int.tryParse(values['requiredOrders'].toString()) ?? 0,
        rewardFreeWeight:
            num.tryParse(values['rewardFreeWeight'].toString()) ?? 0,
        isActive: values['isActive'] as bool? ?? true,
        branch: branchId,
      );

      bool success;
      if (isEditing) {
        success = await ref
            .read(promosControllerProvider.notifier)
            .updatePromo(promoData);
      } else {
        final created = await ref
            .read(promosControllerProvider.notifier)
            .createPromo(promoData);
        success = created != null;
      }

      isSaving.value = false;

      if (!context.mounted) return;

      if (success) {
        showSuccessSnackBar(
          context,
          message: isEditing ? 'Promo updated' : 'Promo created',
          useRootMessenger: false,
        );
        Navigator.of(context).pop(true);
      } else {
        showErrorSnackBar(
          context,
          message: 'Failed to ${isEditing ? 'update' : 'create'} promo',
          useRootMessenger: false,
        );
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: Text(isEditing ? 'Edit Promo' : 'Create Promo'),
          content: SizedBox(
            width: 400,
            child: FormBuilder(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'name',
                      initialValue: promo?.name,
                      decoration:
                          const InputDecoration(labelText: 'Promo Name *'),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'description',
                      initialValue: promo?.description,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    FormBuilderDateTimePicker(
                      name: 'startDate',
                      initialValue: promo?.startDate,
                      inputType: InputType.date,
                      decoration:
                          const InputDecoration(labelText: 'Start Date *'),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderDateTimePicker(
                      name: 'endDate',
                      initialValue: promo?.endDate,
                      inputType: InputType.date,
                      decoration:
                          const InputDecoration(labelText: 'End Date *'),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'requiredOrders',
                      initialValue: promo?.requiredOrders.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Required Orders *',
                        helperText: 'Orders needed to earn the reward',
                      ),
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(1),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'rewardFreeWeight',
                      initialValue: promo?.rewardFreeWeight.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Free Weight Reward (kg) *',
                        helperText: 'e.g. 1 for free 1kg',
                        suffixText: 'kg',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(0.1),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderSwitch(
                      name: 'isActive',
                      initialValue: promo?.isActive ?? true,
                      title: const Text('Active'),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
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
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
