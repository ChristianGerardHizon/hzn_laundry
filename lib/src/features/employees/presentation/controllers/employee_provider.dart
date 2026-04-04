import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/employee_repository.dart';
import '../../domain/employee.dart';

part 'employee_provider.g.dart';

/// Provider for a single employee by ID.
@riverpod
Future<Employee?> employee(Ref ref, String id) async {
  final repository = ref.read(employeeRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold(
    (failure) => null,
    (employee) => employee,
  );
}
