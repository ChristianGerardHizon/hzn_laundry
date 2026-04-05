// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_report_date_range_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the date range for the employee report tab.

@ProviderFor(EmployeeReportDateRangeController)
final employeeReportDateRangeControllerProvider =
    EmployeeReportDateRangeControllerProvider._();

/// Manages the date range for the employee report tab.
final class EmployeeReportDateRangeControllerProvider extends $NotifierProvider<
    EmployeeReportDateRangeController, DateTimeRange<DateTime>> {
  /// Manages the date range for the employee report tab.
  EmployeeReportDateRangeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'employeeReportDateRangeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$employeeReportDateRangeControllerHash();

  @$internal
  @override
  EmployeeReportDateRangeController create() =>
      EmployeeReportDateRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }
}

String _$employeeReportDateRangeControllerHash() =>
    r'63589f07df26123a40d9b517f2fcc268fe1040a3';

/// Manages the date range for the employee report tab.

abstract class _$EmployeeReportDateRangeController
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

/// Manages the selected employee filter for incentive report.
/// null = all employees.

@ProviderFor(IncentiveEmployeeFilter)
final incentiveEmployeeFilterProvider = IncentiveEmployeeFilterProvider._();

/// Manages the selected employee filter for incentive report.
/// null = all employees.
final class IncentiveEmployeeFilterProvider
    extends $NotifierProvider<IncentiveEmployeeFilter, String?> {
  /// Manages the selected employee filter for incentive report.
  /// null = all employees.
  IncentiveEmployeeFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'incentiveEmployeeFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$incentiveEmployeeFilterHash();

  @$internal
  @override
  IncentiveEmployeeFilter create() => IncentiveEmployeeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$incentiveEmployeeFilterHash() =>
    r'06bd654ff3d3c51ff11cfd47cbc395294fe2eb34';

/// Manages the selected employee filter for incentive report.
/// null = all employees.

abstract class _$IncentiveEmployeeFilter extends $Notifier<String?> {
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
