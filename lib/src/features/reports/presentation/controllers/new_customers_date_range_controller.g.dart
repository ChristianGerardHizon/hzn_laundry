// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_customers_date_range_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the date range for the new customers report tab.

@ProviderFor(NewCustomersDateRangeController)
final newCustomersDateRangeControllerProvider =
    NewCustomersDateRangeControllerProvider._();

/// Manages the date range for the new customers report tab.
final class NewCustomersDateRangeControllerProvider extends $NotifierProvider<
    NewCustomersDateRangeController, DateTimeRange<DateTime>> {
  /// Manages the date range for the new customers report tab.
  NewCustomersDateRangeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'newCustomersDateRangeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$newCustomersDateRangeControllerHash();

  @$internal
  @override
  NewCustomersDateRangeController create() => NewCustomersDateRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }
}

String _$newCustomersDateRangeControllerHash() =>
    r'c880dd06d462ec8a830ee571452813140b863fb4';

/// Manages the date range for the new customers report tab.

abstract class _$NewCustomersDateRangeController
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
