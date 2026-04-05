import 'package:dart_mappable/dart_mappable.dart';

import 'deduction_type.dart';
import 'deduction_value_type.dart';

part 'employee_deduction.mapper.dart';

/// A recurring deduction applied to an employee's salary.
///
/// Can be a fixed amount or a percentage of the base salary.
/// Has an optional duration defined by [startMonth] and [endMonth].
/// If [endMonth] is null, the deduction is lifetime (ongoing).
@MappableClass()
class EmployeeDeduction with EmployeeDeductionMappable {
  const EmployeeDeduction({
    required this.id,
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

  /// PocketBase record ID.
  final String id;

  /// Employee ID (relation).
  final String employee;

  /// Type of deduction.
  final DeductionType type;

  /// Whether this is a fixed amount or percentage.
  final DeductionValueType valueType;

  /// The deduction value (amount in pesos or percentage).
  final num value;

  /// Optional custom name (used when type is "other").
  final String? name;

  /// Start month for the deduction (inclusive). Null means from the beginning.
  final DateTime? startMonth;

  /// End month for the deduction (inclusive). Null means lifetime/ongoing.
  final DateTime? endMonth;

  /// Whether the deduction is currently active.
  final bool isActive;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Display name combining type and custom name.
  String get displayName {
    if (type == DeductionType.other && name != null && name!.isNotEmpty) {
      return name!;
    }
    return type.displayName;
  }

  /// Whether this deduction has no end date (lifetime).
  bool get isLifetime => endMonth == null;

  /// Calculates the actual deduction amount given a base salary.
  num computeAmount(num baseSalary) {
    if (valueType == DeductionValueType.percentage) {
      return (baseSalary * value / 100);
    }
    return value;
  }

  /// Whether this deduction is applicable for a given month.
  bool isApplicableFor(DateTime month) {
    final monthStart = DateTime(month.year, month.month);

    if (startMonth != null) {
      final start = DateTime(startMonth!.year, startMonth!.month);
      if (monthStart.isBefore(start)) return false;
    }

    if (endMonth != null) {
      final end = DateTime(endMonth!.year, endMonth!.month);
      if (monthStart.isAfter(end)) return false;
    }

    return isActive;
  }
}
