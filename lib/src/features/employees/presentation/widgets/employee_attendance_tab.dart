import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/domain/user_role.dart';
import '../../../users/presentation/controllers/user_provider.dart';
import '../../../users/presentation/controllers/user_role_provider.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../data/repositories/employee_attendance_repository.dart';
import '../../domain/employee_attendance.dart';
import '../controllers/attendance_controller.dart';

/// Tab showing attendance calendar for a specific employee.
///
/// Admins (or users with attendance.edit permission) can tap a date
/// to toggle the employee's presence for that day.
class EmployeeAttendanceTab extends HookConsumerWidget {
  const EmployeeAttendanceTab({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  static final _monthYearFormat = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync =
        ref.watch(employeeAttendanceControllerProvider(employeeId));
    final focusedMonth = useState(DateTime(DateTime.now().year, DateTime.now().month));

    // Check if the current user can edit attendance
    final auth = ref.watch(currentAuthProvider);
    final fullUser = auth != null
        ? ref.watch(userProvider(auth.user.id)).value
        : null;
    final currentRole = (fullUser != null &&
            fullUser.roleId != null &&
            fullUser.roleId!.isNotEmpty)
        ? ref.watch(userRoleProvider(fullUser.roleId!)).value
        : null;
    final canEdit = currentRole != null &&
        (currentRole.isAdmin ||
            currentRole.hasPermission(Permissions.attendanceEdit));

    return attendanceAsync.when(
      data: (attendances) {
        // Build a map of date -> attendance record (normalize to date only)
        final attendanceMap = <DateTime, EmployeeAttendance>{};
        for (final a in attendances) {
          final dateKey = DateTime(a.date.year, a.date.month, a.date.day);
          attendanceMap[dateKey] = a;
        }

        return RefreshIndicator(
          onRefresh: () => ref
              .read(employeeAttendanceControllerProvider(employeeId).notifier)
              .refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _MonthNavigator(
                  month: focusedMonth.value,
                  onPrevious: () {
                    final m = focusedMonth.value;
                    focusedMonth.value = DateTime(m.year, m.month - 1);
                  },
                  onNext: () {
                    final m = focusedMonth.value;
                    final next = DateTime(m.year, m.month + 1);
                    // Don't navigate past current month
                    final now = DateTime.now();
                    if (next.isBefore(DateTime(now.year, now.month + 1))) {
                      focusedMonth.value = next;
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildLegend(context),
                const SizedBox(height: 12),
                _AttendanceCalendar(
                  month: focusedMonth.value,
                  attendanceMap: attendanceMap,
                  canEdit: canEdit,
                  employeeId: employeeId,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: Colors.green.withValues(alpha: 0.2),
          borderColor: Colors.green.shade800,
          label: 'Present',
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: Colors.red.withValues(alpha: 0.15),
          borderColor: Colors.red.shade700,
          label: 'Absent',
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: theme.colorScheme.surfaceContainerHighest,
          borderColor: theme.colorScheme.onSurfaceVariant,
          label: 'Not set',
        ),
      ],
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCurrentMonth =
        month.year == now.year && month.month == now.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          EmployeeAttendanceTab._monthYearFormat.format(month),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: isCurrentMonth ? null : onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AttendanceCalendar extends HookConsumerWidget {
  const _AttendanceCalendar({
    required this.month,
    required this.attendanceMap,
    required this.canEdit,
    required this.employeeId,
  });

  final DateTime month;
  final Map<DateTime, EmployeeAttendance> attendanceMap;
  final bool canEdit;
  final String employeeId;

  static final _dayFormat = DateFormat('d');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final firstDayOfMonth = DateTime(month.year, month.month);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday; // Monday = 1
    final leadingBlanks = startWeekday - 1;
    final totalCells = leadingBlanks + lastDayOfMonth.day;
    final rows = (totalCells / 7).ceil();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        // Calendar grid
        ...List.generate(rows, (rowIndex) {
          return Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNum = cellIndex - leadingBlanks + 1;

              if (dayNum < 1 || dayNum > lastDayOfMonth.day) {
                return const Expanded(child: SizedBox(height: 44));
              }

              final day = DateTime(month.year, month.month, dayNum);
              final isFuture = day.isAfter(today);
              final attendance = attendanceMap[day];
              final isToday = day == today;

              return Expanded(
                child: _DayCell(
                  day: day,
                  attendance: attendance,
                  isToday: isToday,
                  isFuture: isFuture,
                  canEdit: canEdit && !isFuture,
                  employeeId: employeeId,
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}

class _DayCell extends HookConsumerWidget {
  const _DayCell({
    required this.day,
    required this.attendance,
    required this.isToday,
    required this.isFuture,
    required this.canEdit,
    required this.employeeId,
  });

  final DateTime day;
  final EmployeeAttendance? attendance;
  final bool isToday;
  final bool isFuture;
  final bool canEdit;
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final theme = Theme.of(context);

    Color? bgColor;
    Color textColor = theme.colorScheme.onSurface;

    if (isFuture) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.25);
    } else if (attendance?.isPresent == true) {
      bgColor = Colors.green.withValues(alpha: 0.2);
      textColor = Colors.green.shade800;
    } else if (attendance?.isPresent == false) {
      bgColor = Colors.red.withValues(alpha: 0.15);
      textColor = Colors.red.shade700;
    }

    Future<void> handleTap() async {
      if (!canEdit || isLoading.value) return;

      // Cycle: no record -> present, present -> absent, absent -> present
      final bool newPresent;
      if (attendance == null) {
        newPresent = true;
      } else if (attendance!.isPresent) {
        newPresent = false;
      } else {
        newPresent = true;
      }

      isLoading.value = true;

      final repo = ref.read(employeeAttendanceRepositoryProvider);

      final result = attendance != null
          ? await repo.updateAttendance(
              id: attendance!.id,
              isPresent: newPresent,
            )
          : await repo.createAttendance(
              employeeId: employeeId,
              date: day,
              isPresent: newPresent,
            );

      if (context.mounted) {
        result.fold(
          (_) {
            showErrorSnackBar(
              context,
              message: 'Failed to update attendance',
            );
          },
          (_) {
            // Refresh the employee attendance list
            ref
                .read(
                    employeeAttendanceControllerProvider(employeeId).notifier)
                .refresh();
            showSuccessSnackBar(
              context,
              message: 'Marked as ${newPresent ? 'Present' : 'Absent'}',
            );
          },
        );
      }

      isLoading.value = false;
    }

    return GestureDetector(
      onTap: canEdit ? handleTap : null,
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: isLoading.value
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _AttendanceCalendar._dayFormat.format(day),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: isToday || attendance != null
                            ? FontWeight.w600
                            : null,
                      ),
                    ),
                    if (attendance != null && !isFuture)
                      Icon(
                        attendance!.isPresent
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 12,
                        color: attendance!.isPresent
                            ? Colors.green.shade700
                            : Colors.red.shade600,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
