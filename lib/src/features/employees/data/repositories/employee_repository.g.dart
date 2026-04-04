// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the EmployeeRepository instance.

@ProviderFor(employeeRepository)
final employeeRepositoryProvider = EmployeeRepositoryProvider._();

/// Provides the EmployeeRepository instance.

final class EmployeeRepositoryProvider extends $FunctionalProvider<
    EmployeeRepository,
    EmployeeRepository,
    EmployeeRepository> with $Provider<EmployeeRepository> {
  /// Provides the EmployeeRepository instance.
  EmployeeRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'employeeRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeeRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmployeeRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EmployeeRepository create(Ref ref) {
    return employeeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployeeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployeeRepository>(value),
    );
  }
}

String _$employeeRepositoryHash() =>
    r'7204cd7c3392c8f488b33f4178a1d0be1f725031';
