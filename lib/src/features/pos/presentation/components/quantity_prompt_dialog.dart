import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Shows a dialog to enter a quantity for a service.
///
/// Returns the entered quantity, or `null` if cancelled.
///
/// If [unitLabel] is provided, it will be shown as a suffix in the input field
/// (e.g., "kg" for kilograms).
///
/// When [allowExcess] is true and [maxQuantity] is set, the user can enter
/// quantities above the max. Excess will be split into multiple cart lines.
Future<int?> showQuantityPromptDialog(
  BuildContext context, {
  required String serviceName,
  int? maxQuantity,
  bool allowExcess = false,
  int initialQuantity = 1,
  String? unitLabel,
}) async {
  final formKey = GlobalKey<FormBuilderState>();

  // Treat 0 or null as no max limit
  final effectiveMax = (maxQuantity == null || maxQuantity <= 0) ? null : maxQuantity;

  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enter Quantity'),
      content: FormBuilder(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serviceName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (effectiveMax != null) ...[
              const SizedBox(height: 4),
              Text(
                allowExcess
                    ? 'Max per line: $effectiveMax${unitLabel != null && unitLabel.isNotEmpty ? ' $unitLabel' : ''} (excess splits into multiple lines)'
                    : 'Max: $effectiveMax${unitLabel != null && unitLabel.isNotEmpty ? ' $unitLabel' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'quantity',
              initialValue: initialQuantity.toString(),
              decoration: InputDecoration(
                labelText: 'Quantity *',
                border: const OutlineInputBorder(),
                hintText: effectiveMax != null && !allowExcess
                    ? 'Enter quantity (1-$effectiveMax)'
                    : 'Enter quantity',
                suffixText: unitLabel != null && unitLabel.isNotEmpty ? unitLabel : null,
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Quantity is required',
                ),
                FormBuilderValidators.integer(
                  errorText: 'Must be a whole number',
                ),
                FormBuilderValidators.min(
                  1,
                  errorText: 'Quantity must be at least 1',
                ),
                // Only enforce max when allowExcess is false
                if (effectiveMax != null && !allowExcess)
                  FormBuilderValidators.max(
                    effectiveMax,
                    errorText: 'Maximum quantity is $effectiveMax',
                  ),
              ]),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.saveAndValidate() ?? false) {
              final quantity = int.tryParse(
                formKey.currentState?.fields['quantity']?.value ?? '',
              );
              if (quantity != null && quantity >= 1) {
                Navigator.pop(context, quantity);
              }
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
