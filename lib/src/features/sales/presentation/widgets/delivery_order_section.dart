import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../pos/domain/delivery_fee.dart';
import '../../../pos/domain/fulfillment_type.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

/// In-progress delivery details for an order being created.
///
/// Only used when the `delivery` feature is enabled; otherwise orders are
/// always pickup and none of this is shown.
class DeliveryDraft {
  const DeliveryDraft({
    this.type = FulfillmentType.pickup,
    this.address = '',
    this.notes = '',
    this.distanceKm,
    this.ratePerKm,
    this.feeOverride,
  });

  final FulfillmentType type;
  final String address;
  final String notes;

  /// Distance typed in by staff.
  final num? distanceKm;

  /// Per-km rate for this order. Null = use the branch default.
  final num? ratePerKm;

  /// Manual fee. Null = use the calculated fee.
  final num? feeOverride;

  bool get isDelivery => type.isDelivery;

  DeliveryDraft copyWith({
    FulfillmentType? type,
    String? address,
    String? notes,
    Object? distanceKm = _unset,
    Object? ratePerKm = _unset,
    Object? feeOverride = _unset,
  }) =>
      DeliveryDraft(
        type: type ?? this.type,
        address: address ?? this.address,
        notes: notes ?? this.notes,
        distanceKm: identical(distanceKm, _unset)
            ? this.distanceKm
            : distanceKm as num?,
        ratePerKm:
            identical(ratePerKm, _unset) ? this.ratePerKm : ratePerKm as num?,
        feeOverride: identical(feeOverride, _unset)
            ? this.feeOverride
            : feeOverride as num?,
      );

  static const _unset = Object();

  /// Rate used for this order (order rate, else the branch default).
  num effectiveRate(Branch? branch) => ratePerKm ?? branch?.deliveryRatePerKm ?? 0;

  /// Fee calculated from the branch defaults and this order's distance/rate.
  num calculatedFee(Branch? branch) => DeliveryFee.calculate(
        distanceKm: distanceKm ?? 0,
        baseFee: branch?.deliveryBaseFee ?? 0,
        includedKm: branch?.deliveryIncludedKm ?? 0,
        ratePerKm: effectiveRate(branch),
      );

  /// Final fee charged: 0 for pickup, the manual override if set, else the
  /// calculated fee.
  num fee(Branch? branch) {
    if (!isDelivery) return 0;
    return feeOverride ?? calculatedFee(branch);
  }
}

/// Pickup / Delivery toggle plus delivery address, distance and fee fields.
class DeliveryOrderSection extends ConsumerWidget {
  const DeliveryOrderSection({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.enabled,
  });

  final DeliveryDraft draft;
  final ValueChanged<DeliveryDraft> onChanged;
  final bool enabled;

  num? _parse(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? null : num.tryParse(v);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branchId = ref.watch(currentBranchIdProvider);
    final branch =
        branchId == null ? null : ref.watch(branchProvider(branchId)).value;

    final calculated = draft.calculatedFee(branch);
    final defaultRate = branch?.deliveryRatePerKm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Fulfillment',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        FormBuilderChoiceChips<FulfillmentType>(
          name: 'fulfillmentType',
          initialValue: draft.type,
          decoration: const InputDecoration(border: InputBorder.none),
          options: [
            for (final t in FulfillmentType.values)
              FormBuilderChipOption(value: t, child: Text(t.displayName)),
          ],
          enabled: enabled,
          onChanged: (value) {
            if (value != null) onChanged(draft.copyWith(type: value));
          },
        ),
        if (draft.isDelivery) ...[
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'deliveryAddress',
            initialValue: draft.address,
            decoration: const InputDecoration(
              labelText: 'Delivery address *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            enabled: enabled,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.next,
            onChanged: (v) => onChanged(draft.copyWith(address: v ?? '')),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'distanceKm',
                  initialValue: draft.distanceKm?.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Distance (km)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.route),
                  ),
                  enabled: enabled,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: FormBuilderValidators.numeric(
                    checkNullOrEmpty: false,
                  ),
                  onChanged: (v) =>
                      onChanged(draft.copyWith(distanceKm: _parse(v))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FormBuilderTextField(
                  // Rebuild when the branch default loads so it can prefill.
                  key: ValueKey('rate-${defaultRate ?? 'none'}'),
                  name: 'deliveryRatePerKm',
                  initialValue:
                      (draft.ratePerKm ?? defaultRate)?.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Rate per km (₱)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  enabled: enabled,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: FormBuilderValidators.numeric(
                    checkNullOrEmpty: false,
                  ),
                  onChanged: (v) =>
                      onChanged(draft.copyWith(ratePerKm: _parse(v))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'deliveryFeeOverride',
            initialValue: draft.feeOverride?.toString(),
            decoration: InputDecoration(
              labelText: 'Delivery fee (₱)',
              helperText:
                  'Calculated: ${calculated.toCurrency()} — leave empty to use it',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.local_shipping_outlined),
            ),
            enabled: enabled,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            validator: FormBuilderValidators.numeric(checkNullOrEmpty: false),
            onChanged: (v) => onChanged(draft.copyWith(feeOverride: _parse(v))),
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'deliveryNotes',
            initialValue: draft.notes,
            decoration: const InputDecoration(
              labelText: 'Delivery notes',
              hintText: 'Landmarks, preferred time, contact person',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sticky_note_2_outlined),
            ),
            enabled: enabled,
            minLines: 1,
            maxLines: 3,
            onChanged: (v) => onChanged(draft.copyWith(notes: v ?? '')),
          ),
          const SizedBox(height: 8),
          Text(
            'Delivery fee added to total: ${draft.fee(branch).toCurrency()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
