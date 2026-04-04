import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/employee_attendance.dart';

part 'employee_attendance_dto.mapper.dart';

/// Data Transfer Object for EmployeeAttendance from PocketBase.
@MappableClass()
class EmployeeAttendanceDto with EmployeeAttendanceDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String employee;
  final String? date;
  final bool isPresent;
  final String? notes;
  final String? created;
  final String? updated;

  const EmployeeAttendanceDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.employee,
    this.date,
    this.isPresent = true,
    this.notes,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory EmployeeAttendanceDto.fromRecord(RecordModel record) {
    return EmployeeAttendanceDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      employee: record.getStringValue('employee'),
      date: record.get<String>('date'),
      isPresent: record.get<bool>('isPresent'),
      notes: record.getStringValue('notes'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain EmployeeAttendance entity.
  EmployeeAttendance toEntity() {
    return EmployeeAttendance(
      id: id,
      employee: employee,
      date: parseToLocal(date) ?? DateTime.now(),
      isPresent: isPresent,
      notes: notes != null && notes!.isNotEmpty ? notes : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
