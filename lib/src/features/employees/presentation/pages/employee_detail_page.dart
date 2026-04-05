import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../controllers/employee_provider.dart';
import '../controllers/employees_controller.dart';
import '../widgets/employee_attendance_tab.dart';
import '../widgets/employee_deductions_tab.dart';
import '../widgets/employee_form_dialog.dart';

/// Employee detail page showing employee information and attendance.
class EmployeeDetailPage extends HookConsumerWidget {
  const EmployeeDetailPage({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeProvider(employeeId));
    final isTablet = Breakpoints.isTabletOrLarger(context);
    final currencyFormat =
        NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final tabController = useTabController(initialLength: 3);

    return employeeAsync.when(
      data: (employee) {
        if (employee == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Employee Not Found'),
              automaticallyImplyLeading: !isTablet,
            ),
            body: const Center(
              child: Text('The requested employee could not be found.'),
            ),
          );
        }

        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(employee.name),
            automaticallyImplyLeading: !isTablet,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(employeeProvider(employeeId));
                  showInfoSnackBar(
                    context,
                    message: 'Refreshing...',
                    duration: const Duration(seconds: 1),
                  );
                },
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    showEmployeeFormDialog(context, employee: employee),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, ref, value, employee.id),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Attendance'),
                Tab(text: 'Deductions'),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Information',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(label: 'Name', value: employee.name),
                          _InfoRow(
                            label: 'Base Salary',
                            value: currencyFormat.format(employee.baseSalary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              EmployeeAttendanceTab(employeeId: employeeId),
              EmployeeDeductionsTab(employeeId: employeeId),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    String id,
  ) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Employee'),
          content:
              const Text('Are you sure you want to delete this employee?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await ref
            .read(employeesControllerProvider.notifier)
            .deleteEmployee(id);
        if (success && context.mounted) {
          showSuccessSnackBar(context, message: 'Employee deleted');
          context.pop();
        } else if (context.mounted) {
          showErrorSnackBar(context, message: 'Failed to delete employee');
        }
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
