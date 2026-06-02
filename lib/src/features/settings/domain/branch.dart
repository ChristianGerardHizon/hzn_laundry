import 'package:dart_mappable/dart_mappable.dart';

part 'branch.mapper.dart';

/// Branch domain model.
///
/// Represents a physical branch/location of the business.
@MappableClass()
class Branch with BranchMappable {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    this.operatingHours,
    this.cutOffTime,
    this.incentiveAmount = 5,
    this.incentivePerServiceItems = 200,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Branch name (short internal identifier, e.g., "Main Branch").
  final String name;

  /// Branch address.
  final String address;

  /// Branch contact number.
  final String contactNumber;

  /// Operating hours (e.g., "Mon-Sat 8:00 AM - 5:00 PM").
  final String? operatingHours;

  /// Cut-off time for accepting new orders (e.g., "4:30 PM").
  final String? cutOffTime;

  /// Incentive amount earned per service price threshold (in pesos).
  final num incentiveAmount;

  /// Service price threshold (in pesos) to earn the incentive.
  final num incentivePerServiceItems;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
