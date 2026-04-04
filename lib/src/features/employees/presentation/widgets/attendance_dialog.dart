import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../domain/employee.dart';
import '../../domain/employee_attendance.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/employees_controller.dart';

/// Shows the attendance dialog from the dashboard.
///
/// Displays a list of employees. Each can be toggled between
/// Present and Absent for the selected date.
void showAttendanceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const _AttendanceDialog(),
  );
}

class _AttendanceDialog extends HookConsumerWidget {
  const _AttendanceDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final today = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final employeesAsync = ref.watch(employeesControllerProvider);
    final attendanceAsync = ref.watch(attendanceControllerProvider(today));
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Employee Attendance'),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                selectedDate.value = picked;
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(selectedDate.value),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        height: 400,
        child: employeesAsync.when(
          data: (employees) => attendanceAsync.when(
            data: (attendances) {
              if (employees.isEmpty) {
                return const Center(
                  child: Text('No employees found.'),
                );
              }

              // Build a map of employeeId -> attendance record
              final attendanceMap = <String, EmployeeAttendance>{};
              for (final a in attendances) {
                attendanceMap[a.employee] = a;
              }

              return ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  final record = attendanceMap[employee.id];

                  return _EmployeeAttendanceTile(
                    employee: employee,
                    attendance: record,
                    date: today,
                  );
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _EmployeeAttendanceTile extends HookConsumerWidget {
  const _EmployeeAttendanceTile({
    required this.employee,
    required this.attendance,
    required this.date,
  });

  final Employee employee;
  final EmployeeAttendance? attendance;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final theme = Theme.of(context);

    // Three states: no record yet, present, absent
    final hasRecord = attendance != null;
    final isPresent = attendance?.isPresent ?? false;

    Future<void> markAs(bool present) async {
      isLoading.value = true;

      final controller =
          ref.read(attendanceControllerProvider(date).notifier);

      final success = await controller.toggleAttendance(
        employeeId: employee.id,
        isPresent: present,
        existingId: attendance?.id,
      );

      if (success && context.mounted) {
        showSuccessSnackBar(
          context,
          message:
              '${employee.name} marked as ${present ? 'In' : 'Out'}',
        );
      } else if (!success && context.mounted) {
        showErrorSnackBar(
          context,
          message: 'Failed to update attendance',
        );
      }

      isLoading.value = false;
    }

    // Status display
    final Color statusColor;
    final String statusText;
    final IconData statusIcon;
    if (!hasRecord) {
      statusColor = theme.colorScheme.onSurfaceVariant;
      statusText = 'Not set';
      statusIcon = Icons.remove_circle_outline;
    } else if (isPresent) {
      statusColor = Colors.green;
      statusText = 'In';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = theme.colorScheme.onSurfaceVariant;
      statusText = 'Out';
      statusIcon = Icons.cancel;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          // In button
          IconButton(
            onPressed: isLoading.value || (hasRecord && isPresent)
                ? null
                : () => markAs(true),
            icon: const Icon(Icons.check),
            color: Colors.green,
            tooltip: 'Mark In',
            style: IconButton.styleFrom(
              backgroundColor: hasRecord && isPresent
                  ? Colors.green.withValues(alpha: 0.15)
                  : null,
            ),
          ),
          const SizedBox(width: 4),
          // Out button
          IconButton(
            onPressed: isLoading.value || (hasRecord && !isPresent)
                ? null
                : () => markAs(false),
            icon: const Icon(Icons.close),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: 'Mark Out',
            style: IconButton.styleFrom(
              backgroundColor: hasRecord && !isPresent
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
