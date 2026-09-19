import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/employee_repository.dart';
import '../../domain/employee.dart';

part 'employees_controller.g.dart';

/// Controller for managing the list of employees.
@Riverpod(keepAlive: true)
class EmployeesController extends _$EmployeesController {
  EmployeeRepository get _repository => ref.read(employeeRepositoryProvider);

  String? get _scopeFilter {
    return PBFilters.forEmployeeOrgAndBranch(
      organizationId: ref.read(currentOrganizationIdProvider),
      branchId: ref.read(currentBranchIdProvider),
    );
  }

  @override
  Future<List<Employee>> build() async {
    final orgId = ref.watch(currentOrganizationIdProvider);
    final branchId = ref.watch(currentBranchIdProvider);
    final filter = PBFilters.forEmployeeOrgAndBranch(
      organizationId: orgId,
      branchId: branchId,
    );
    if (filter == null) return [];

    final result = await _repository.fetchAll(filter: filter);

    return result.fold(
      (failure) => throw failure,
      (employees) => employees,
    );
  }

  /// Refreshes the employee list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final filter = _scopeFilter;
    if (filter == null) {
      state = const AsyncData([]);
      return;
    }

    final result = await _repository.fetchAll(filter: filter);

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
