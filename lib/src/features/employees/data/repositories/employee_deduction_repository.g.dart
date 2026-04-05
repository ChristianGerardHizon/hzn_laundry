// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_deduction_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the EmployeeDeductionRepository instance.

@ProviderFor(employeeDeductionRepository)
final employeeDeductionRepositoryProvider =
    EmployeeDeductionRepositoryProvider._();

/// Provides the EmployeeDeductionRepository instance.

final class EmployeeDeductionRepositoryProvider extends $FunctionalProvider<
    EmployeeDeductionRepository,
    EmployeeDeductionRepository,
    EmployeeDeductionRepository> with $Provider<EmployeeDeductionRepository> {
  /// Provides the EmployeeDeductionRepository instance.
  EmployeeDeductionRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'employeeDeductionRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeeDeductionRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmployeeDeductionRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EmployeeDeductionRepository create(Ref ref) {
    return employeeDeductionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployeeDeductionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployeeDeductionRepository>(value),
    );
  }
}

String _$employeeDeductionRepositoryHash() =>
    r'91dbbf6b0bedc7c8eba627013e923c00593741f7';
