import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../delivery/domain/customer_address.dart';
import '../../../delivery/domain/delivery_rate.dart';
import '../../../delivery/presentation/controllers/customer_addresses_controller.dart';
import '../../../delivery/presentation/controllers/delivery_rates_controller.dart';
import '../../../pos/domain/delivery_fee.dart';
import '../../../pos/domain/fulfillment_type.dart';
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
    this.rate,
    this.fillVersion = 0,
  });

  final FulfillmentType type;
  final String address;
  final String notes;

  /// Distance typed in by staff (or prefilled from a saved address).
  final num? distanceKm;

  /// Per-km rate typed for this order. Null = the selected rate's per-km rate.
  final num? ratePerKm;

  /// Manual fee. Null = use the calculated fee.
  final num? feeOverride;

  /// Selected branch delivery rate (the branch default unless changed).
  final DeliveryRate? rate;

  /// Bumped when a selection programmatically fills fields, so the text
  /// fields rebuild with the new initial values.
  final int fillVersion;

  bool get isDelivery => type.isDelivery;

  DeliveryDraft copyWith({
    FulfillmentType? type,
    String? address,
    String? notes,
    Object? distanceKm = _unset,
    Object? ratePerKm = _unset,
    Object? feeOverride = _unset,
    Object? rate = _unset,
    int? fillVersion,
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
        rate: identical(rate, _unset) ? this.rate : rate as DeliveryRate?,
        fillVersion: fillVersion ?? this.fillVersion,
      );

  static const _unset = Object();

  /// Per-km rate used for this order (typed rate, else the selected rate's).
  num effectiveRate() => ratePerKm ?? rate?.ratePerKm ?? 0;

  /// Fee calculated from the selected rate and this order's distance/rate.
  num calculatedFee() => DeliveryFee.calculate(
        distanceKm: distanceKm ?? 0,
        baseFee: rate?.baseFee ?? 0,
        includedKm: rate?.includedKm ?? 0,
        ratePerKm: effectiveRate(),
      );

  /// Final fee charged: 0 for pickup, the manual override if set, else the
  /// calculated fee.
  num fee() {
    if (!isDelivery) return 0;
    return feeOverride ?? calculatedFee();
  }
}

/// Pickup / Delivery toggle plus saved-address and rate pickers and the
/// delivery address, distance and fee fields.
class DeliveryOrderSection extends HookConsumerWidget {
  const DeliveryOrderSection({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.enabled,
    this.customerId,
  });

  final DeliveryDraft draft;
  final ValueChanged<DeliveryDraft> onChanged;
  final bool enabled;

  /// Selected customer; their saved addresses are offered.
  final String? customerId;

  num? _parse(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? null : num.tryParse(v);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branchId = ref.watch(currentBranchIdProvider) ?? '';
    final rates = ref.watch(deliveryRatesControllerProvider(branchId)).value ??
        const <DeliveryRate>[];
    final addresses = customerId == null || customerId!.isEmpty
        ? const <CustomerAddress>[]
        : (ref.watch(customerAddressesControllerProvider(customerId!)).value ??
            const <CustomerAddress>[]);

    DeliveryRate? defaultRate() {
      for (final r in rates) {
        if (r.isDefault) return r;
      }
      return rates.isEmpty ? null : rates.first;
    }

    DeliveryRate? rateById(String? id) {
      if (id == null) return null;
      for (final r in rates) {
        if (r.id == id) return r;
      }
      return null;
    }

    // Always apply changes to the newest draft. Several updates can happen in
    // one frame (default rate + default address), so each must build on the
    // previous one instead of the draft captured at build time.
    final latest = useRef(draft)..value = draft;

    void update(DeliveryDraft Function(DeliveryDraft) change) {
      latest.value = change(latest.value);
      onChanged(latest.value);
    }

    // Programmatic fill (saved address / rate picked): update the draft and
    // push the values into the form fields, which keep their own state.
    void fill(DeliveryDraft Function(DeliveryDraft) change) {
      update(change);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final d = latest.value;
        FormBuilder.of(context)?.patchValue({
          'deliveryAddress': d.address,
          'distanceKm': d.distanceKm?.toString() ?? '',
          'deliveryNotes': d.notes,
          'deliveryRatePerKm': d.effectiveRate().toString(),
          'deliveryFeeOverride': d.feeOverride?.toString() ?? '',
        });
      });
    }

    // Preselect the branch's default rate once rates load (or when the
    // selected rate no longer exists).
    useEffect(() {
      if (!draft.isDelivery || rates.isEmpty) return null;
      final stillValid =
          draft.rate != null && rates.any((r) => r.id == draft.rate!.id);
      if (!stillValid) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fill((d) => d.copyWith(
                rate: defaultRate(),
                ratePerKm: null,
                fillVersion: d.fillVersion + 1,
              ));
        });
      }
      return null;
    }, [rates, draft.isDelivery]);

    // Preselect the customer's default saved address once their addresses
    // load, but only while no address has been typed.
    useEffect(() {
      if (!draft.isDelivery || addresses.isEmpty) return null;
      if (latest.value.address.isNotEmpty) return null;
      final def = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (latest.value.address.isNotEmpty) return;
        fill((d) => _withAddress(d, def, rateById(def.deliveryRateId)));
      });
      return null;
    }, [customerId, addresses, draft.isDelivery]);

    final calculated = draft.calculatedFee();
    CustomerAddress? matchingSaved;
    for (final a in addresses) {
      if (a.address.trim().toLowerCase() ==
          draft.address.trim().toLowerCase()) {
        matchingSaved = a;
        break;
      }
    }

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
          // 12px between the chips and a 44px-tall touch target.
          spacing: 12,
          runSpacing: 8,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          options: [
            for (final t in FulfillmentType.values)
              FormBuilderChipOption(value: t, child: Text(t.displayName)),
          ],
          enabled: enabled,
          onChanged: (value) {
            if (value != null) update((d) => d.copyWith(type: value));
          },
        ),
        if (draft.isDelivery) ...[
          const SizedBox(height: 12),
          if (addresses.isNotEmpty) ...[
            FormBuilderDropdown<String>(
              key: ValueKey('saved-${matchingSaved?.id}-${addresses.length}'),
              name: 'savedAddress',
              initialValue: matchingSaved?.id,
              decoration: const InputDecoration(
                labelText: 'Saved addresses',
                helperText: 'Pick one, or type a different address below',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bookmark_outline),
              ),
              enabled: enabled,
              items: [
                for (final a in addresses)
                  DropdownMenuItem(
                    value: a.id,
                    child: Text(
                      a.isDefault
                          ? '${a.displayName} (default)'
                          : a.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                for (final a in addresses) {
                  if (a.id == id) {
                    fill((d) => _withAddress(d, a, rateById(a.deliveryRateId)));
                    break;
                  }
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          FormBuilderTextField(
            key: ValueKey('address-${draft.fillVersion}'),
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
            onChanged: (v) => update((d) => d.copyWith(address: v ?? '')),
          ),
          const SizedBox(height: 12),
          if (rates.isNotEmpty) ...[
            FormBuilderDropdown<String>(
              key: ValueKey('rate-pick-${draft.rate?.id}-${draft.fillVersion}'),
              name: 'deliveryRateId',
              initialValue: draft.rate?.id,
              decoration: const InputDecoration(
                labelText: 'Delivery rate',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_shipping_outlined),
              ),
              enabled: enabled,
              items: [
                for (final r in rates)
                  DropdownMenuItem(
                    value: r.id,
                    child: Text(
                      '${r.name}${r.isDefault ? ' (default)' : ''} · ${r.summary}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                final r = rateById(id);
                if (r != null) {
                  fill((d) => d.copyWith(
                        rate: r,
                        ratePerKm: null,
                        fillVersion: d.fillVersion + 1,
                      ));
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormBuilderTextField(
                  key: ValueKey('distance-${draft.fillVersion}'),
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
                      update((d) => d.copyWith(distanceKm: _parse(v))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FormBuilderTextField(
                  // Rebuild when a rate/address selection prefills this.
                  key: ValueKey('rate-${draft.fillVersion}-${draft.rate?.id}'),
                  name: 'deliveryRatePerKm',
                  initialValue: draft.effectiveRate().toString(),
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
                      update((d) => d.copyWith(ratePerKm: _parse(v))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            key: ValueKey('fee-${draft.fillVersion}'),
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: FormBuilderValidators.numeric(checkNullOrEmpty: false),
            onChanged: (v) =>
                update((d) => d.copyWith(feeOverride: _parse(v))),
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            key: ValueKey('notes-${draft.fillVersion}'),
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
            onChanged: (v) => update((d) => d.copyWith(notes: v ?? '')),
          ),
          const SizedBox(height: 8),
          Text(
            'Delivery fee added to total: ${draft.fee().toCurrency()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// Draft with [a]'s address, distance, notes and (when it has one) rate.
  DeliveryDraft _withAddress(
    DeliveryDraft d,
    CustomerAddress a,
    DeliveryRate? addressRate,
  ) =>
      d.copyWith(
        address: a.address,
        notes: a.notes ?? '',
        distanceKm: a.distanceKm,
        rate: addressRate ?? d.rate,
        ratePerKm: null,
        feeOverride: null,
        fillVersion: d.fillVersion + 1,
      );
}
