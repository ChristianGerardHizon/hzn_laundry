import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/employee_deduction_repository.dart';
import '../../domain/deduction_type.dart';
import '../../domain/deduction_value_type.dart';
import '../../domain/employee_deduction.dart';

part 'employee_deductions_controller.g.dart';

/// Controller for managing deductions for a specific employee.
@riverpod
class EmployeeDeductionsController extends _$EmployeeDeductionsController {
  EmployeeDeductionRepository get _repository =>
      ref.read(employeeDeductionRepositoryProvider);

  @override
  Future<List<EmployeeDeduction>> build(String employeeId) async {
    final result = await _repository.fetchForEmployee(employeeId);

    return result.fold(
      (failure) => throw failure,
      (deductions) => deductions,
    );
  }

  /// Refreshes the deductions list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchForEmployee(employeeId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (deductions) => AsyncData(deductions),
    );
  }

  /// Creates a new deduction.
  Future<bool> createDeduction({
    required DeductionType type,
    required DeductionValueType valueType,
    required num value,
    String? name,
    DateTime? startMonth,
    DateTime? endMonth,
  }) async {
    final result = await _repository.create(
      employeeId: employeeId,
      type: type,
      valueType: valueType,
      value: value,
      name: name,
      startMonth: startMonth,
      endMonth: endMonth,
    );

    return result.fold(
      (_) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  /// Updates an existing deduction.
  Future<bool> updateDeduction({
    required String id,
    required DeductionType type,
    required DeductionValueType valueType,
    required num value,
    String? name,
    DateTime? startMonth,
    DateTime? endMonth,
    required bool isActive,
  }) async {
    final result = await _repository.update(
      id: id,
      type: type,
      valueType: valueType,
      value: value,
      name: name,
      startMonth: startMonth,
      endMonth: endMonth,
      isActive: isActive,
    );

    return result.fold(
      (_) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes a deduction.
  Future<bool> deleteDeduction(String id) async {
    final result = await _repository.delete(id);

    return result.fold(
      (_) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
