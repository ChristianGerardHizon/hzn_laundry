// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single employee by ID.

@ProviderFor(employee)
final employeeProvider = EmployeeFamily._();

/// Provider for a single employee by ID.

final class EmployeeProvider extends $FunctionalProvider<AsyncValue<Employee?>,
        Employee?, FutureOr<Employee?>>
    with $FutureModifier<Employee?>, $FutureProvider<Employee?> {
  /// Provider for a single employee by ID.
  EmployeeProvider._(
      {required EmployeeFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'employeeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeeHash();

  @override
  String toString() {
    return r'employeeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Employee?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Employee?> create(Ref ref) {
    final argument = this.argument as String;
    return employee(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EmployeeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$employeeHash() => r'486cfe308082f9d1e89f4155aea4a11b57de6782';

/// Provider for a single employee by ID.

final class EmployeeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Employee?>, String> {
  EmployeeFamily._()
      : super(
          retry: null,
          name: r'employeeProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a single employee by ID.

  EmployeeProvider call(
    String id,
  ) =>
      EmployeeProvider._(argument: id, from: this);

  @override
  String toString() => r'employeeProvider';
}
