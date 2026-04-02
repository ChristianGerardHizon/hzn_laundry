// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_detail_date_range_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the date range for the sales detail (Orders) report tab.

@ProviderFor(SalesDetailDateRangeController)
final salesDetailDateRangeControllerProvider =
    SalesDetailDateRangeControllerProvider._();

/// Manages the date range for the sales detail (Orders) report tab.
final class SalesDetailDateRangeControllerProvider extends $NotifierProvider<
    SalesDetailDateRangeController, DateTimeRange<DateTime>> {
  /// Manages the date range for the sales detail (Orders) report tab.
  SalesDetailDateRangeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesDetailDateRangeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salesDetailDateRangeControllerHash();

  @$internal
  @override
  SalesDetailDateRangeController create() => SalesDetailDateRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }
}

String _$salesDetailDateRangeControllerHash() =>
    r'358d1ef6a89c5a57a7bc9bab9138419ca993973b';

/// Manages the date range for the sales detail (Orders) report tab.

abstract class _$SalesDetailDateRangeController
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
