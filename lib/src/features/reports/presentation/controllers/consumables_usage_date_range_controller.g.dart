// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumables_usage_date_range_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Date range for the Consumables report tab.

@ProviderFor(ConsumablesUsageDateRangeController)
final consumablesUsageDateRangeControllerProvider =
    ConsumablesUsageDateRangeControllerProvider._();

/// Date range for the Consumables report tab.
final class ConsumablesUsageDateRangeControllerProvider
    extends $NotifierProvider<ConsumablesUsageDateRangeController,
        DateTimeRange<DateTime>> {
  /// Date range for the Consumables report tab.
  ConsumablesUsageDateRangeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'consumablesUsageDateRangeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$consumablesUsageDateRangeControllerHash();

  @$internal
  @override
  ConsumablesUsageDateRangeController create() =>
      ConsumablesUsageDateRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }
}

String _$consumablesUsageDateRangeControllerHash() =>
    r'dc0228e06c40decf0a0362298e51a5c7ec3d3151';

/// Date range for the Consumables report tab.

abstract class _$ConsumablesUsageDateRangeController
    extends $Notifier<DateTimeRange<DateTime>> {
  DateTimeRange<DateTime> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<DateTimeRange<DateTime>, DateTimeRange<DateTime>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DateTimeRange<DateTime>, DateTimeRange<DateTime>>,
        DateTimeRange<DateTime>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
