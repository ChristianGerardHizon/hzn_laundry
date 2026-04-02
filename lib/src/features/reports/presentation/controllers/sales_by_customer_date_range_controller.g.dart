// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_by_customer_date_range_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the date range for the sales by customer report tab.

@ProviderFor(SalesByCustomerDateRangeController)
final salesByCustomerDateRangeControllerProvider =
    SalesByCustomerDateRangeControllerProvider._();

/// Manages the date range for the sales by customer report tab.
final class SalesByCustomerDateRangeControllerProvider
    extends $NotifierProvider<SalesByCustomerDateRangeController,
        DateTimeRange<DateTime>> {
  /// Manages the date range for the sales by customer report tab.
  SalesByCustomerDateRangeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesByCustomerDateRangeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$salesByCustomerDateRangeControllerHash();

  @$internal
  @override
  SalesByCustomerDateRangeController create() =>
      SalesByCustomerDateRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }
}

String _$salesByCustomerDateRangeControllerHash() =>
    r'b73b0dba364395e0ad1eed058c0df267f83305e5';

/// Manages the date range for the sales by customer report tab.

abstract class _$SalesByCustomerDateRangeController
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
