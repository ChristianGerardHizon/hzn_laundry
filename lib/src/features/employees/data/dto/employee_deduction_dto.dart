import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/deduction_type.dart';
import '../../domain/deduction_value_type.dart';
import '../../domain/employee_deduction.dart';

part 'employee_deduction_dto.mapper.dart';

/// Data Transfer Object for EmployeeDeduction from PocketBase.
@MappableClass()
class EmployeeDeductionDto with EmployeeDeductionDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String employee;
  final String type;
  final String valueType;
  final num value;
  final String? name;
  final String? startMonth;
  final String? endMonth;
  final bool isActive;
  final String? created;
  final String? updated;

  const EmployeeDeductionDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.employee,
    required this.type,
    required this.valueType,
    required this.value,
    this.name,
    this.startMonth,
    this.endMonth,
    this.isActive = true,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory EmployeeDeductionDto.fromRecord(RecordModel record) {
    return EmployeeDeductionDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      employee: record.getStringValue('employee'),
      type: record.getStringValue('type'),
      valueType: record.getStringValue('valueType'),
      value: record.get<num>('value'),
      name: record.getStringValue('name'),
      startMonth: record.get<String>('startMonth'),
      endMonth: record.get<String>('endMonth'),
      isActive: record.get<bool>('isActive'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain EmployeeDeduction entity.
  EmployeeDeduction toEntity() {
    return EmployeeDeduction(
      id: id,
      employee: employee,
      type: DeductionTypeMapper.fromValue(type),
      valueType: DeductionValueTypeMapper.fromValue(valueType),
      value: value,
      name: name?.isNotEmpty == true ? name : null,
      startMonth: parseToLocal(startMonth),
      endMonth: parseToLocal(endMonth),
      isActive: isActive,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  /// Creates the body map for a PocketBase create operation.
  static Map<String, dynamic> toCreateBody({
    required String employeeId,
    required DeductionType type,
    required DeductionValueType valueType,
    required num value,
    String? name,
    DateTime? startMonth,
    DateTime? endMonth,
    bool isActive = true,
  }) {
    return {
      'employee': employeeId,
      'type': type.name,
      'valueType': valueType.name,
      'value': value,
      if (name != null && name.isNotEmpty) 'name': name,
      if (startMonth != null) 'startMonth': startMonth.toUtcIso8601(),
      if (endMonth != null) 'endMonth': endMonth.toUtcIso8601(),
      'isActive': isActive,
    };
  }
}
