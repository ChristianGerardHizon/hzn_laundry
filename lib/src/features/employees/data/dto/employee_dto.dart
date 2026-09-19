import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/employee.dart';

part 'employee_dto.mapper.dart';

/// Data Transfer Object for Employee from PocketBase.
@MappableClass()
class EmployeeDto with EmployeeDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String organizationId;
  final List<String> branchIds;
  final num baseSalary;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const EmployeeDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.organizationId = '',
    this.branchIds = const [],
    this.baseSalary = 0,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory EmployeeDto.fromRecord(RecordModel record) {
    return EmployeeDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      name: record.getStringValue('name'),
      organizationId: record.getStringValue('organization'),
      branchIds: record.getListValue<String>('branches'),
      baseSalary: record.get<num>('baseSalary'),
      isDeleted: record.get<bool>('isDeleted'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain Employee entity.
  Employee toEntity() {
    return Employee(
      id: id,
      name: name,
      organizationId: organizationId,
      branchIds: branchIds,
      baseSalary: baseSalary,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
