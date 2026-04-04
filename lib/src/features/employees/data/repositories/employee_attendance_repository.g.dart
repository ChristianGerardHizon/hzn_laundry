// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_attendance_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the EmployeeAttendanceRepository instance.

@ProviderFor(employeeAttendanceRepository)
final employeeAttendanceRepositoryProvider =
    EmployeeAttendanceRepositoryProvider._();

/// Provides the EmployeeAttendanceRepository instance.

final class EmployeeAttendanceRepositoryProvider extends $FunctionalProvider<
    EmployeeAttendanceRepository,
    EmployeeAttendanceRepository,
    EmployeeAttendanceRepository> with $Provider<EmployeeAttendanceRepository> {
  /// Provides the EmployeeAttendanceRepository instance.
  EmployeeAttendanceRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'employeeAttendanceRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeeAttendanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmployeeAttendanceRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EmployeeAttendanceRepository create(Ref ref) {
    return employeeAttendanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployeeAttendanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployeeAttendanceRepository>(value),
    );
  }
}

String _$employeeAttendanceRepositoryHash() =>
    r'4726cf694a1ded32e8511f3368619f35754ef7a6';
