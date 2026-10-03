import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../domain/customer_address.dart';
import '../../domain/delivery_rate.dart';

/// Dialog to create or edit a customer's saved delivery address. Returns the
/// edited [CustomerAddress] (empty id when new), or null when cancelled.
///
/// [rates] are the customer's branch delivery rates (empty hides the rate
/// picker). No snackbars are shown here, so the ScaffoldMessenger wrapper is
/// skipped; the caller reports save errors.
Future<CustomerAddress?> showCustomerAddressFormDialog(
  BuildContext context, {
  required String customerId,
  List<DeliveryRate> rates = const [],
  CustomerAddress? address,
}) {
  return showDialog<CustomerAddress>(
    context: context,
    builder: (_) => _CustomerAddressFormDialog(
      customerId: customerId,
      rates: rates,
      address: address,
    ),
  );
}

class _CustomerAddressFormDialog extends StatelessWidget {
  const _CustomerAddressFormDialog({
    required this.customerId,
    required this.rates,
    this.address,
  });

  final String customerId;
  final List<DeliveryRate> rates;
  final CustomerAddress? address;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    void save() {
      if (!formKey.currentState!.saveAndValidate()) return;
      final v = formKey.currentState!.value;
      String? text(String key) {
        final t = (v[key] as String?)?.trim() ?? '';
        return t.isEmpty ? null : t;
      }

      Navigator.of(context).pop(
        CustomerAddress(
          id: address?.id ?? '',
          customerId: customerId,
          label: text('label'),
          address: text('address')!,
          notes: text('notes'),
          distanceKm: num.tryParse(v['distanceKm']?.toString() ?? ''),
          deliveryRateId: v['deliveryRate'] as String?,
          isDefault: address?.isDefault ?? false,
        ),
      );
    }

    InputDecoration deco(String label, IconData icon, {String? helper}) =>
        InputDecoration(
          labelText: label,
          helperText: helper,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        );

    final validRateId = rates.any((r) => r.id == address?.deliveryRateId)
        ? address?.deliveryRateId
        : null;

    return AlertDialog(
      title: Text(address == null ? 'New delivery address' : 'Edit address'),
      content: SizedBox(
        width: 440,
        child: FormBuilder(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'label',
                  initialValue: address?.label,
                  decoration: deco('Label', Icons.label_outline,
                      helper: 'e.g. Home, Office'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'address',
                  initialValue: address?.address,
                  decoration: deco('Address *', Icons.location_on_outlined),
                  minLines: 1,
                  maxLines: 3,
                  validator: FormBuilderValidators.required(
                    errorText: 'Address is required',
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'distanceKm',
                  initialValue: address?.distanceKm?.toString(),
                  decoration: deco('Distance (km)', Icons.route,
                      helper: 'Prefills the distance on new orders'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator:
                      FormBuilderValidators.numeric(checkNullOrEmpty: false),
                ),
                if (rates.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  FormBuilderDropdown<String>(
                    name: 'deliveryRate',
                    initialValue: validRateId,
                    decoration: deco('Delivery rate', Icons.local_shipping_outlined,
                        helper: 'Optional. Empty = the branch default rate'),
                    items: [
                      for (final r in rates)
                        DropdownMenuItem(
                          value: r.id,
                          child: Text(r.isDefault ? '${r.name} (default)' : r.name),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'notes',
                  initialValue: address?.notes,
                  decoration: deco('Notes', Icons.sticky_note_2_outlined,
                      helper: 'Landmarks, gate code, contact person'),
                  minLines: 1,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: save, child: const Text('Save')),
      ],
    );
  }
}
