// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employees_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the list of employees.

@ProviderFor(EmployeesController)
final employeesControllerProvider = EmployeesControllerProvider._();

/// Controller for managing the list of employees.
final class EmployeesControllerProvider
    extends $AsyncNotifierProvider<EmployeesController, List<Employee>> {
  /// Controller for managing the list of employees.
  EmployeesControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'employeesControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeesControllerHash();

  @$internal
  @override
  EmployeesController create() => EmployeesController();
}

String _$employeesControllerHash() =>
    r'87c2f3daba1254ca1bd6360c483ed6b59c52d72d';

/// Controller for managing the list of employees.

abstract class _$EmployeesController extends $AsyncNotifier<List<Employee>> {
  FutureOr<List<Employee>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Employee>>, List<Employee>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Employee>>, List<Employee>>,
        AsyncValue<List<Employee>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
