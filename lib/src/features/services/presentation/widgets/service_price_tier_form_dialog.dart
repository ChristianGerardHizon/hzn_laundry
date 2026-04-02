import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/service_price_tier.dart';
import '../controllers/service_price_tiers_provider.dart';

/// Shows a dialog for creating or editing a service price tier.
///
/// Returns `true` if the tier was saved successfully.
Future<bool?> showServicePriceTierFormDialog(
  BuildContext context, {
  required String serviceId,
  ServicePriceTier? tier,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _ServicePriceTierFormDialog(
      serviceId: serviceId,
      tier: tier,
    ),
  );
}

class _ServicePriceTierFormDialog extends HookConsumerWidget {
  const _ServicePriceTierFormDialog({
    required this.serviceId,
    this.tier,
  });

  final String serviceId;
  final ServicePriceTier? tier;

  bool get isEditing => tier != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final minQty = num.parse(values['minQuantity'].toString());
      final maxQtyStr = values['maxQuantity']?.toString();
      final maxQty =
          (maxQtyStr != null && maxQtyStr.isNotEmpty) ? num.parse(maxQtyStr) : null;
      final price = num.parse(values['pricePerUnit'].toString());

      // Validate min < max if max is provided
      if (maxQty != null && maxQty > 0 && maxQty < minQty) {
        formKey.currentState?.fields['maxQuantity']
            ?.invalidate('Must be greater than min quantity');
        isSaving.value = false;
        return;
      }

      final body = <String, dynamic>{
        'service': serviceId,
        'minQuantity': minQty,
        'maxQuantity': maxQty ?? 0,
        'pricePerUnit': price,
      };

      try {
        final pb = ref.read(pocketbaseProvider);
        final collection =
            pb.collection(PocketBaseCollections.servicePriceTiers);

        if (isEditing) {
          await collection.update(tier!.id, body: body);
        } else {
          await collection.create(body: body);
        }

        ref.invalidate(servicePriceTiersProvider(serviceId));

        if (context.mounted) {
          showSuccessSnackBar(
            context,
            message: isEditing ? 'Tier updated' : 'Tier added',
            useRootMessenger: false,
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (context.mounted) {
          showErrorSnackBar(
            context,
            message: 'Failed to save tier: $e',
            useRootMessenger: false,
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: Text(isEditing ? 'Edit Price Tier' : 'Add Price Tier'),
          content: FormBuilder(
            key: formKey,
            initialValue: {
              'minQuantity': tier?.minQuantity.toString() ?? '',
              'maxQuantity':
                  (tier?.maxQuantity != null && tier!.maxQuantity! > 0)
                      ? tier!.maxQuantity.toString()
                      : '',
              'pricePerUnit': tier?.pricePerUnit.toString() ?? '',
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'minQuantity',
                        decoration:
                            const InputDecoration(labelText: 'Min Qty *'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                          FormBuilderValidators.min(0),
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'maxQuantity',
                        decoration: const InputDecoration(
                          labelText: 'Max Qty',
                          hintText: 'No limit',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final parsed = num.tryParse(value);
                          if (parsed == null) return 'Must be a number';
                          if (parsed < 0) return 'Must be >= 0';
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'pricePerUnit',
                  decoration: const InputDecoration(
                    labelText: 'Price *',
                    prefixText: '₱ ',
                    hintText: 'Total price for this range',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.min(0),
                  ]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
