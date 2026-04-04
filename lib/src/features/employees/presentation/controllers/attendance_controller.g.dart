// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing attendance records for a specific date.

@ProviderFor(AttendanceController)
final attendanceControllerProvider = AttendanceControllerFamily._();

/// Controller for managing attendance records for a specific date.
final class AttendanceControllerProvider extends $AsyncNotifierProvider<
    AttendanceController, List<EmployeeAttendance>> {
  /// Controller for managing attendance records for a specific date.
  AttendanceControllerProvider._(
      {required AttendanceControllerFamily super.from,
      required DateTime super.argument})
      : super(
          retry: null,
          name: r'attendanceControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$attendanceControllerHash();

  @override
  String toString() {
    return r'attendanceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AttendanceController create() => AttendanceController();

  @override
  bool operator ==(Object other) {
    return other is AttendanceControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendanceControllerHash() =>
    r'958d11d93c6bd56a0d00214693f336e2c27dd000';

/// Controller for managing attendance records for a specific date.

final class AttendanceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            AttendanceController,
            AsyncValue<List<EmployeeAttendance>>,
            List<EmployeeAttendance>,
            FutureOr<List<EmployeeAttendance>>,
            DateTime> {
  AttendanceControllerFamily._()
      : super(
          retry: null,
          name: r'attendanceControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Controller for managing attendance records for a specific date.

  AttendanceControllerProvider call(
    DateTime date,
  ) =>
      AttendanceControllerProvider._(argument: date, from: this);

  @override
  String toString() => r'attendanceControllerProvider';
}

/// Controller for managing attendance records for a specific date.

abstract class _$AttendanceController
    extends $AsyncNotifier<List<EmployeeAttendance>> {
  late final _$args = ref.$arg as DateTime;
  DateTime get date => _$args;

  FutureOr<List<EmployeeAttendance>> build(
    DateTime date,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<EmployeeAttendance>>, List<EmployeeAttendance>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<EmployeeAttendance>>,
            List<EmployeeAttendance>>,
        AsyncValue<List<EmployeeAttendance>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

/// Controller for fetching attendance records for a specific employee.

@ProviderFor(EmployeeAttendanceController)
final employeeAttendanceControllerProvider =
    EmployeeAttendanceControllerFamily._();

/// Controller for fetching attendance records for a specific employee.
final class EmployeeAttendanceControllerProvider extends $AsyncNotifierProvider<
    EmployeeAttendanceController, List<EmployeeAttendance>> {
  /// Controller for fetching attendance records for a specific employee.
  EmployeeAttendanceControllerProvider._(
      {required EmployeeAttendanceControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'employeeAttendanceControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeeAttendanceControllerHash();

  @override
  String toString() {
    return r'employeeAttendanceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EmployeeAttendanceController create() => EmployeeAttendanceController();

  @override
  bool operator ==(Object other) {
    return other is EmployeeAttendanceControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$employeeAttendanceControllerHash() =>
    r'3c269a487cfdb96bbec43e9ac7c349d8ca9958af';

/// Controller for fetching attendance records for a specific employee.

final class EmployeeAttendanceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            EmployeeAttendanceController,
            AsyncValue<List<EmployeeAttendance>>,
            List<EmployeeAttendance>,
            FutureOr<List<EmployeeAttendance>>,
            String> {
  EmployeeAttendanceControllerFamily._()
      : super(
          retry: null,
          name: r'employeeAttendanceControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Controller for fetching attendance records for a specific employee.

  EmployeeAttendanceControllerProvider call(
    String employeeId,
  ) =>
      EmployeeAttendanceControllerProvider._(argument: employeeId, from: this);

  @override
  String toString() => r'employeeAttendanceControllerProvider';
}

/// Controller for fetching attendance records for a specific employee.

abstract class _$EmployeeAttendanceController
    extends $AsyncNotifier<List<EmployeeAttendance>> {
  late final _$args = ref.$arg as String;
  String get employeeId => _$args;

  FutureOr<List<EmployeeAttendance>> build(
    String employeeId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<EmployeeAttendance>>, List<EmployeeAttendance>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<EmployeeAttendance>>,
            List<EmployeeAttendance>>,
        AsyncValue<List<EmployeeAttendance>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
