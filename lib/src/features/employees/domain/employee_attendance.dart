import 'package:dart_mappable/dart_mappable.dart';

part 'employee_attendance.mapper.dart';

/// Employee attendance record for a specific date.
@MappableClass()
class EmployeeAttendance with EmployeeAttendanceMappable {
  const EmployeeAttendance({
    required this.id,
    required this.employee,
    required this.date,
    this.isPresent = true,
    this.notes,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Employee ID (relation).
  final String employee;

  /// Attendance date.
  final DateTime date;

  /// Whether the employee was present.
  final bool isPresent;

  /// Optional notes for this attendance record.
  final String? notes;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
