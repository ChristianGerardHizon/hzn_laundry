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
    required this.slug,
    required this.address,
    required this.contactNumber,
    this.organizationId,
    this.operatingHours,
    this.cutOffTime,
    this.isDefault = false,
    this.isDeleted = false,
    this.deliveryBaseFee,
    this.deliveryIncludedKm,
    this.deliveryRatePerKm,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent organization ID (tenant).
  final String? organizationId;

  /// Branch name (short internal identifier, e.g., "Main Branch").
  final String name;

  /// URL-safe slug unique within the organization. Literal `all` is reserved.
  final String slug;

  /// Branch address.
  final String address;

  /// Branch contact number.
  final String contactNumber;

  /// Operating hours (e.g., "Mon-Sat 8:00 AM - 5:00 PM").
  final String? operatingHours;

  /// Cut-off time for accepting new orders (e.g., "4:30 PM").
  final String? cutOffTime;

  /// Whether this is the organization's default branch.
  final bool isDefault;

  /// Soft delete flag.
  final bool isDeleted;

  /// Default delivery base fee in PHP (delivery feature only).
  final num? deliveryBaseFee;

  /// Kilometres covered by the base fee before the per-km rate applies.
  final num? deliveryIncludedKm;

  /// Default per-km rate in PHP for distance beyond [deliveryIncludedKm].
  final num? deliveryRatePerKm;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
