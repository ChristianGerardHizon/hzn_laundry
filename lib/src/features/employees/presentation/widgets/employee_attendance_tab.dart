import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/attendance_controller.dart';

/// Tab showing attendance history for a specific employee.
class EmployeeAttendanceTab extends ConsumerWidget {
  const EmployeeAttendanceTab({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync =
        ref.watch(employeeAttendanceControllerProvider(employeeId));
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return attendanceAsync.when(
      data: (attendances) {
        if (attendances.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No attendance records yet',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref
              .read(employeeAttendanceControllerProvider(employeeId).notifier)
              .refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendances.length,
            itemBuilder: (context, index) {
              final attendance = attendances[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: attendance.isPresent
                        ? Colors.green.withValues(alpha: 0.2)
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      attendance.isPresent
                          ? Icons.check
                          : Icons.close,
                      color: attendance.isPresent
                          ? Colors.green
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(dateFormat.format(attendance.date)),
                  subtitle: attendance.notes != null
                      ? Text(attendance.notes!)
                      : null,
                  trailing: Text(
                    attendance.isPresent ? 'In' : 'Out',
                    style: TextStyle(
                      color: attendance.isPresent
                          ? Colors.green
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
