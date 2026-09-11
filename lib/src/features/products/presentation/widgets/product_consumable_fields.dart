import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../domain/product.dart';

class ProductConsumableFields extends HookWidget {
  const ProductConsumableFields({
    super.key,
    required this.enabled,
    this.product,
  });

  final bool enabled;
  final Product? product;

  /// Reads consumable fields from a saved form. Extra settings are ignored
  /// (and stored as defaults) when Consumable is off.
  static ({
    bool isConsumable,
    bool countsTowardMaterialCost,
    num usageMin,
    num? usageMax,
    num? usageStep,
    num? defaultUsage,
  }) valuesFrom(Map<String, dynamic> values) {
    final isConsumable = values['isConsumable'] as bool? ?? false;
    if (!isConsumable) {
      return (
        isConsumable: false,
        countsTowardMaterialCost: false,
        usageMin: 0,
        usageMax: null,
        usageStep: null,
        defaultUsage: null,
      );
    }
    return (
      isConsumable: true,
      countsTowardMaterialCost:
          values['countsTowardMaterialCost'] as bool? ?? false,
      usageMin: _parseNum(values['usageMin']?.toString()) ?? 0,
      usageMax: _parseNum(values['usageMax']?.toString()),
      usageStep: _parseNum(values['usageStep']?.toString()),
      defaultUsage: _parseNum(values['defaultUsage']?.toString()),
    );
  }

  static num? _parseNum(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return num.tryParse(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isConsumable = useState(product?.isConsumable ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormBuilderSwitch(
          name: 'isConsumable',
          initialValue: product?.isConsumable ?? false,
          decoration: const InputDecoration(border: InputBorder.none),
          title: const Text('Consumable'),
          subtitle: const Text(
            'House supply used on orders (detergent, fabcon)',
          ),
          enabled: enabled,
          onChanged: (value) => isConsumable.value = value ?? false,
        ),
        if (isConsumable.value) ...[
          FormBuilderSwitch(
            name: 'countsTowardMaterialCost',
            initialValue: product?.countsTowardMaterialCost ?? false,
            decoration: const InputDecoration(border: InputBorder.none),
            title: const Text('Counts toward material cost'),
            subtitle: const Text(
              'Add-on sales of this product increase order usage and cost',
            ),
            enabled: enabled,
          ),
          const SizedBox(height: 8),
          FormBuilderTextField(
            name: 'usageMin',
            initialValue: '${product?.usageMin ?? 0}',
            decoration: const InputDecoration(
              labelText: 'Usage min',
              border: OutlineInputBorder(),
              helperText: 'Never below 0',
            ),
            enabled: enabled,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.numeric(
              checkNullOrEmpty: false,
              errorText: 'Must be a number',
            ),
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'usageMax',
            initialValue: product?.usageMax?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Usage max',
              border: OutlineInputBorder(),
              helperText: 'Leave empty for no cap',
            ),
            enabled: enabled,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.numeric(
              checkNullOrEmpty: false,
              errorText: 'Must be a number',
            ),
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'usageStep',
            initialValue: product?.usageStep?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Usage step',
              border: OutlineInputBorder(),
              helperText: 'Amount each + / − changes',
            ),
            enabled: enabled,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.numeric(
              checkNullOrEmpty: false,
              errorText: 'Must be a number',
            ),
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'defaultUsage',
            initialValue: product?.defaultUsage?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Default usage',
              border: OutlineInputBorder(),
            ),
            enabled: enabled,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.numeric(
              checkNullOrEmpty: false,
              errorText: 'Must be a number',
            ),
          ),
        ],
      ],
    );
  }
}
