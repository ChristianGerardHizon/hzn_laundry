import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../controllers/sale_items_provider.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_service_items_provider.dart';

/// Dialog for editing a sale item (addon) or service item's quantity and price.
class EditItemDialog extends HookConsumerWidget {
  const EditItemDialog({
    super.key,
    required this.saleId,
    required this.itemId,
    required this.itemName,
    required this.currentQuantity,
    required this.currentUnitPrice,
    required this.isServiceItem,
  });

  final String saleId;
  final String itemId;
  final String itemName;
  final num currentQuantity;
  final num currentUnitPrice;
  final bool isServiceItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final currencyFormat =
        NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    // Live subtotal calculation
    final quantity = useState<num>(currentQuantity);
    final unitPrice = useState<num>(currentUnitPrice);
    final subtotal = quantity.value * unitPrice.value;

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      final newQty =
          num.tryParse(values['quantity']?.toString() ?? '') ?? currentQuantity;
      final newPrice = num.tryParse(values['unitPrice']?.toString() ?? '') ??
          currentUnitPrice;
      final newSubtotal = newQty * newPrice;

      isSaving.value = true;

      final repo = ref.read(salesRepositoryProvider);

      final result = isServiceItem
          ? await repo.updateSaleServiceItem(
              itemId,
              quantity: newQty,
              unitPrice: newPrice,
              subtotal: newSubtotal,
            )
          : await repo.updateSaleItem(
              itemId,
              quantity: newQty,
              unitPrice: newPrice,
              subtotal: newSubtotal,
            );

      // Recalculate sale total
      await repo.recalculateSaleTotal(saleId);

      isSaving.value = false;

      if (!context.mounted) return;

      final success = result.isRight();
      if (success) {
        ref.invalidate(saleProvider(saleId));
        ref.invalidate(saleItemsProvider(saleId));
        ref.invalidate(saleServiceItemsProvider(saleId));
        Navigator.of(context).pop(true);
        showSuccessSnackBar(context,
            message: 'Item updated successfully', useRootMessenger: false);
      } else {
        showErrorSnackBar(context,
            message: 'Failed to update item', useRootMessenger: false);
      }
    }

    final theme = Theme.of(context);

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: Text('Edit $itemName'),
          content: SizedBox(
            width: 360,
            child: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quantity field
                  FormBuilderTextField(
                    name: 'quantity',
                    initialValue: currentQuantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(0.01,
                          errorText: 'Quantity must be greater than 0'),
                    ]),
                    onChanged: (value) {
                      quantity.value = num.tryParse(value ?? '') ?? 0;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Unit price field
                  FormBuilderTextField(
                    name: 'unitPrice',
                    initialValue: currentUnitPrice.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price *',
                      prefixText: '₱ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(0,
                          errorText: 'Price cannot be negative'),
                    ]),
                    onChanged: (value) {
                      unitPrice.value = num.tryParse(value ?? '') ?? 0;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subtotal preview
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal:',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            currencyFormat.format(subtotal),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
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
            FilledButton.icon(
              onPressed: isSaving.value ? null : handleSave,
              icon: isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(isSaving.value ? 'Saving...' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the edit item dialog. Returns true if the item was updated.
Future<bool?> showEditItemDialog(
  BuildContext context, {
  required String saleId,
  required String itemId,
  required String itemName,
  required num currentQuantity,
  required num currentUnitPrice,
  required bool isServiceItem,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => EditItemDialog(
      saleId: saleId,
      itemId: itemId,
      itemName: itemName,
      currentQuantity: currentQuantity,
      currentUnitPrice: currentUnitPrice,
      isServiceItem: isServiceItem,
    ),
  );
}
