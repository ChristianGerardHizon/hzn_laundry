import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/employee_repository.dart';
import '../../domain/employee.dart';

part 'employees_controller.g.dart';

/// Controller for managing the list of employees.
@Riverpod(keepAlive: true)
class EmployeesController extends _$EmployeesController {
  EmployeeRepository get _repository => ref.read(employeeRepositoryProvider);

  @override
  Future<List<Employee>> build() async {
    final result = await _repository.fetchAll();

    return result.fold(
      (failure) => throw failure,
      (employees) => employees,
    );
  }

  /// Refreshes the employee list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchAll();

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (employees) => AsyncData(employees),
    );
  }

  /// Creates a new employee.
  Future<Employee?> createEmployee(Employee employee) async {
    final result = await _repository.create(employee);
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  /// Updates an existing employee.
  Future<bool> updateEmployee(Employee employee) async {
    final result = await _repository.update(employee);
    return result.fold(
      (failure) => false,
      (updated) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes an employee (soft delete).
  Future<bool> deleteEmployee(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
