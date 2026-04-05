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
    r'd496fd7c1a352a402ba9dbdf61fcb8ab6fe38377';

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

/// Manages the selected salary period (full month, 1st half, 2nd half).

@ProviderFor(SalaryPeriodController)
final salaryPeriodControllerProvider = SalaryPeriodControllerProvider._();

/// Manages the selected salary period (full month, 1st half, 2nd half).
final class SalaryPeriodControllerProvider
    extends $NotifierProvider<SalaryPeriodController, SalaryPeriod> {
  /// Manages the selected salary period (full month, 1st half, 2nd half).
  SalaryPeriodControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salaryPeriodControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salaryPeriodControllerHash();

  @$internal
  @override
  SalaryPeriodController create() => SalaryPeriodController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SalaryPeriod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SalaryPeriod>(value),
    );
  }
}

String _$salaryPeriodControllerHash() =>
    r'cea75f2617da0d30e4453e4a6287918859610312';

/// Manages the selected salary period (full month, 1st half, 2nd half).

abstract class _$SalaryPeriodController extends $Notifier<SalaryPeriod> {
  SalaryPeriod build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SalaryPeriod, SalaryPeriod>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SalaryPeriod, SalaryPeriod>,
        SalaryPeriod,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Manages the selected employee filter for salary report.
/// null = all employees.

@ProviderFor(SalaryEmployeeFilter)
final salaryEmployeeFilterProvider = SalaryEmployeeFilterProvider._();

/// Manages the selected employee filter for salary report.
/// null = all employees.
final class SalaryEmployeeFilterProvider
    extends $NotifierProvider<SalaryEmployeeFilter, String?> {
  /// Manages the selected employee filter for salary report.
  /// null = all employees.
  SalaryEmployeeFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salaryEmployeeFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salaryEmployeeFilterHash();

  @$internal
  @override
  SalaryEmployeeFilter create() => SalaryEmployeeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$salaryEmployeeFilterHash() =>
    r'213742047a1e3b3e79d8877abd9ab9d1bfd476cc';

/// Manages the selected employee filter for salary report.
/// null = all employees.

abstract class _$SalaryEmployeeFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
