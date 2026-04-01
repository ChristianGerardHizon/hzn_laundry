import 'package:dart_mappable/dart_mappable.dart';

import 'machine_type.dart';

part 'machine.mapper.dart';

/// Machine domain model.
///
/// Represents a laundry machine (washer, dryer, etc.) in a branch.
@MappableClass()
class Machine with MachineMappable {
  const Machine({
    required this.id,
    required this.name,
    required this.type,
    this.branchId,
    this.isAvailable = true,
    this.strictSingleUse = false,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  static const String collectionName = 'machines';

  /// PocketBase record ID.
  final String id;

  /// Machine name (e.g., "Washer #1").
  final String name;

  /// Machine type.
  final MachineType type;

  /// Branch this machine belongs to.
  final String? branchId;

  /// Whether the machine is currently available.
  final bool isAvailable;

  /// Whether the machine requires strict single use validation.
  /// When true, shows a warning if the machine is assigned to a processing order.
  final bool strictSingleUse;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
