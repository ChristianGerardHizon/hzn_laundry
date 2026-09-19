import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../controllers/employees_controller.dart';
import '../widgets/employee_list_panel.dart';

/// Employees list page for mobile view.
class EmployeesListPage extends ConsumerWidget {
  const EmployeesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesControllerProvider);

    return employeesAsync.when(
      data: (employees) => EmployeeListPanel(employees: employees),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(employeesControllerProvider),
      )
    );
  }
}
