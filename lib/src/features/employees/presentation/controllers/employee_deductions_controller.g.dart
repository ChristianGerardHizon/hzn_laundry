// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_deductions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing deductions for a specific employee.

@ProviderFor(EmployeeDeductionsController)
final employeeDeductionsControllerProvider =
    EmployeeDeductionsControllerFamily._();

/// Controller for managing deductions for a specific employee.
final class EmployeeDeductionsControllerProvider extends $AsyncNotifierProvider<
    EmployeeDeductionsController, List<EmployeeDeduction>> {
  /// Controller for managing deductions for a specific employee.
  EmployeeDeductionsControllerProvider._(
      {required EmployeeDeductionsControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'employeeDeductionsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeeDeductionsControllerHash();

  @override
  String toString() {
    return r'employeeDeductionsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EmployeeDeductionsController create() => EmployeeDeductionsController();

  @override
  bool operator ==(Object other) {
    return other is EmployeeDeductionsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$employeeDeductionsControllerHash() =>
    r'07e711545a2cd15ff2e4bccbdeab62438c963336';

/// Controller for managing deductions for a specific employee.

final class EmployeeDeductionsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            EmployeeDeductionsController,
            AsyncValue<List<EmployeeDeduction>>,
            List<EmployeeDeduction>,
            FutureOr<List<EmployeeDeduction>>,
            String> {
  EmployeeDeductionsControllerFamily._()
      : super(
          retry: null,
          name: r'employeeDeductionsControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Controller for managing deductions for a specific employee.

  EmployeeDeductionsControllerProvider call(
    String employeeId,
  ) =>
      EmployeeDeductionsControllerProvider._(argument: employeeId, from: this);

  @override
  String toString() => r'employeeDeductionsControllerProvider';
}

/// Controller for managing deductions for a specific employee.

abstract class _$EmployeeDeductionsController
    extends $AsyncNotifier<List<EmployeeDeduction>> {
  late final _$args = ref.$arg as String;
  String get employeeId => _$args;

  FutureOr<List<EmployeeDeduction>> build(
    String employeeId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<EmployeeDeduction>>, List<EmployeeDeduction>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<EmployeeDeduction>>,
            List<EmployeeDeduction>>,
        AsyncValue<List<EmployeeDeduction>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
