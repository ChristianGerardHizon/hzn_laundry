import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/nav_permissions.dart';
import '../../../employees/presentation/controllers/attendance_controller.dart';
import '../../../employees/presentation/controllers/employees_controller.dart';
import '../../../employees/presentation/widgets/attendance_dialog.dart';
import '../../../users/domain/user_role.dart';

/// Dashboard section that shows a warning banner when today's attendance
/// has not been set.
///
/// The alert disappears once all employees have an attendance record
/// (either present or absent) for today.
class AttendanceAlertSection extends ConsumerWidget {
  const AttendanceAlertSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hide if user has no attendance permission
    final roleAsync = ref.watch(currentUserRoleProvider);
    final role = roleAsync.value;
    final canViewAttendance = role == null ||
        role.isAdmin ||
        role.hasPermission(Permissions.attendanceView) ||
        role.hasPermission(Permissions.attendanceCreate);
    if (!canViewAttendance) return const SizedBox.shrink();

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final employeesAsync = ref.watch(employeesControllerProvider);
    final attendanceAsync = ref.watch(attendanceControllerProvider(today));

    return employeesAsync.when(
      data: (employees) => attendanceAsync.when(
        data: (attendances) {
          if (employees.isEmpty) return const SizedBox.shrink();

          final markedIds = attendances.map((a) => a.employee).toSet();
          final unmarkedCount =
              employees.where((e) => !markedIds.contains(e.id)).length;

          // Hide alert if all employees have been marked
          if (unmarkedCount == 0) return const SizedBox.shrink();

          final totalCount = employees.length;
          final markedCount = totalCount - unmarkedCount;
          final theme = Theme.of(context);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => showAttendanceDialog(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance Not Complete',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$markedCount of $totalCount employees marked '
                              '($unmarkedCount remaining)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
