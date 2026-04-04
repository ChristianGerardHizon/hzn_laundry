// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the date range for the attendance report tab.

@ProviderFor(AttendanceReportDateRangeController)
final attendanceReportDateRangeControllerProvider =
    AttendanceReportDateRangeControllerProvider._();

/// Manages the date range for the attendance report tab.
final class AttendanceReportDateRangeControllerProvider
    extends $NotifierProvider<AttendanceReportDateRangeController,
        DateTimeRange<DateTime>> {
  /// Manages the date range for the attendance report tab.
  AttendanceReportDateRangeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'attendanceReportDateRangeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$attendanceReportDateRangeControllerHash();

  @$internal
  @override
  AttendanceReportDateRangeController create() =>
      AttendanceReportDateRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }
}

String _$attendanceReportDateRangeControllerHash() =>
    r'db80a35385b4389bcff15abc3b1a38214026ba86';

/// Manages the date range for the attendance report tab.

abstract class _$AttendanceReportDateRangeController
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

/// Manages the selected employee filter for the attendance report.

@ProviderFor(AttendanceReportEmployeeFilter)
final attendanceReportEmployeeFilterProvider =
    AttendanceReportEmployeeFilterProvider._();

/// Manages the selected employee filter for the attendance report.
final class AttendanceReportEmployeeFilterProvider
    extends $NotifierProvider<AttendanceReportEmployeeFilter, String?> {
  /// Manages the selected employee filter for the attendance report.
  AttendanceReportEmployeeFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'attendanceReportEmployeeFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$attendanceReportEmployeeFilterHash();

  @$internal
  @override
  AttendanceReportEmployeeFilter create() => AttendanceReportEmployeeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$attendanceReportEmployeeFilterHash() =>
    r'4ee6ac795cfd1ef8f6d9c514c6aeaf68cfb54e4d';

/// Manages the selected employee filter for the attendance report.

abstract class _$AttendanceReportEmployeeFilter extends $Notifier<String?> {
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

/// Fetches attendance report data for the selected date range and employee
/// filter.

@ProviderFor(attendanceReport)
final attendanceReportProvider = AttendanceReportProvider._();

/// Fetches attendance report data for the selected date range and employee
/// filter.

final class AttendanceReportProvider extends $FunctionalProvider<
        AsyncValue<AttendanceReportData>,
        AttendanceReportData,
        FutureOr<AttendanceReportData>>
    with
        $FutureModifier<AttendanceReportData>,
        $FutureProvider<AttendanceReportData> {
  /// Fetches attendance report data for the selected date range and employee
  /// filter.
  AttendanceReportProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'attendanceReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$attendanceReportHash();

  @$internal
  @override
  $FutureProviderElement<AttendanceReportData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AttendanceReportData> create(Ref ref) {
    return attendanceReport(ref);
  }
}

String _$attendanceReportHash() => r'3f66e5a9e3cacb3c27dfe7cf653ec2c507a61812';
