import 'package:dart_mappable/dart_mappable.dart';

part 'employee.mapper.dart';

/// Employee domain model.
///
/// Represents an employee of the laundry business.
@MappableClass()
class Employee with EmployeeMappable {
  const Employee({
    required this.id,
    required this.name,
    this.organizationId = '',
    this.branchIds = const [],
    this.baseSalary = 0,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Employee name.
  final String name;

  /// Parent organization ID (tenant).
  final String organizationId;

  /// Assigned branch IDs. Empty means all branches in [organizationId].
  final List<String> branchIds;

  /// Base salary amount.
  final num baseSalary;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Formatted salary display.
  String get salaryDisplay => '₱${baseSalary.toStringAsFixed(2)}';

  /// Whether this employee is visible at every branch in the org.
  bool get isAssignedToAllBranches => branchIds.isEmpty;
}
