// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_date_range_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the date range for the payments (Sales) report tab.

@ProviderFor(PaymentsDateRangeController)
final paymentsDateRangeControllerProvider =
    PaymentsDateRangeControllerProvider._();

/// Manages the date range for the payments (Sales) report tab.
final class PaymentsDateRangeControllerProvider extends $NotifierProvider<
    PaymentsDateRangeController, DateTimeRange<DateTime>> {
  /// Manages the date range for the payments (Sales) report tab.
  PaymentsDateRangeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'paymentsDateRangeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$paymentsDateRangeControllerHash();

  @$internal
  @override
  PaymentsDateRangeController create() => PaymentsDateRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }
}

String _$paymentsDateRangeControllerHash() =>
    r'30cf582ff66232ace786ff712366c94e1658dd9c';

/// Manages the date range for the payments (Sales) report tab.

abstract class _$PaymentsDateRangeController
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
