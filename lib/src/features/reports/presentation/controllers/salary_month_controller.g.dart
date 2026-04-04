// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_month_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the selected month for the salary report tab.
///
/// Stores the first day of the selected month. The date range is
/// computed as first-of-month to last-of-month.

@ProviderFor(SalaryMonthController)
final salaryMonthControllerProvider = SalaryMonthControllerProvider._();

/// Manages the selected month for the salary report tab.
///
/// Stores the first day of the selected month. The date range is
/// computed as first-of-month to last-of-month.
final class SalaryMonthControllerProvider
    extends $NotifierProvider<SalaryMonthController, DateTime> {
  /// Manages the selected month for the salary report tab.
  ///
  /// Stores the first day of the selected month. The date range is
  /// computed as first-of-month to last-of-month.
  SalaryMonthControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salaryMonthControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salaryMonthControllerHash();

  @$internal
  @override
  SalaryMonthController create() => SalaryMonthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$salaryMonthControllerHash() =>
    r'6d750610e8602f68167e214eee350a895f080cab';

/// Manages the selected month for the salary report tab.
///
/// Stores the first day of the selected month. The date range is
/// computed as first-of-month to last-of-month.

abstract class _$SalaryMonthController extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DateTime, DateTime>, DateTime, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
