import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../domain/delivery_rate.dart';

/// Dialog to create or edit a branch delivery rate. Returns the edited
/// [DeliveryRate] (empty id when new), or null when cancelled.
///
/// No snackbars are shown inside this dialog, so the ScaffoldMessenger wrapper
/// is skipped; the caller reports save errors.
Future<DeliveryRate?> showDeliveryRateFormDialog(
  BuildContext context, {
  required String branchId,
  DeliveryRate? rate,
}) {
  return showDialog<DeliveryRate>(
    context: context,
    builder: (_) => _DeliveryRateFormDialog(branchId: branchId, rate: rate),
  );
}

class _DeliveryRateFormDialog extends StatelessWidget {
  const _DeliveryRateFormDialog({required this.branchId, this.rate});

  final String branchId;
  final DeliveryRate? rate;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    String numText(num? v) => (v == null || v == 0) ? '' : v.toString();

    void save() {
      if (!formKey.currentState!.saveAndValidate()) return;
      final v = formKey.currentState!.value;
      num parse(String key) => num.tryParse(v[key]?.toString() ?? '') ?? 0;
      Navigator.of(context).pop(
        DeliveryRate(
          id: rate?.id ?? '',
          branchId: branchId,
          name: (v['name'] as String).trim(),
          baseFee: parse('baseFee'),
          includedKm: parse('includedKm'),
          ratePerKm: parse('ratePerKm'),
          isDefault: rate?.isDefault ?? false,
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

    return AlertDialog(
      title: Text(rate == null ? 'New delivery rate' : 'Edit delivery rate'),
      content: SizedBox(
        width: 420,
        child: FormBuilder(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'name',
                  initialValue: rate?.name,
                  decoration: deco('Name *', Icons.sell_outlined,
                      helper: 'e.g. Standard, Far area, Express'),
                  validator: FormBuilderValidators.required(
                    errorText: 'Name is required',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'baseFee',
                  initialValue: numText(rate?.baseFee),
                  decoration: deco('Base fee (₱)', Icons.local_shipping_outlined),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator:
                      FormBuilderValidators.numeric(checkNullOrEmpty: false),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'includedKm',
                  initialValue: numText(rate?.includedKm),
                  decoration: deco('Included distance (km)', Icons.route,
                      helper: 'Covered by the base fee'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator:
                      FormBuilderValidators.numeric(checkNullOrEmpty: false),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'ratePerKm',
                  initialValue: numText(rate?.ratePerKm),
                  decoration: deco('Rate per km (₱)', Icons.attach_money,
                      helper: 'Charged for each km beyond the included distance'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator:
                      FormBuilderValidators.numeric(checkNullOrEmpty: false),
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
