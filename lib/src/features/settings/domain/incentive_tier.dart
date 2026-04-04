import 'package:dart_mappable/dart_mappable.dart';

part 'incentive_tier.mapper.dart';

/// Incentive tier for a branch.
///
/// Defines how much incentive is earned for a service price within
/// [minAmount] to [maxAmount]. If [maxAmount] is null, this tier
/// covers all amounts above [minAmount].
@MappableClass()
class IncentiveTier with IncentiveTierMappable {
  const IncentiveTier({
    required this.id,
    required this.branch,
    required this.minAmount,
    this.maxAmount,
    required this.incentiveAmount,
    this.sortOrder = 0,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Branch ID (relation).
  final String branch;

  /// Minimum service price for this tier (inclusive).
  final num minAmount;

  /// Maximum service price for this tier (inclusive).
  /// Null means no upper limit (catch-all tier).
  final num? maxAmount;

  /// Incentive amount earned when service price falls in this tier.
  final num incentiveAmount;

  /// Sort order for display.
  final int sortOrder;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Display label for this tier.
  String get label {
    if (maxAmount == null) {
      return '₱${minAmount.toStringAsFixed(0)}+';
    }
    return '₱${minAmount.toStringAsFixed(0)} - ₱${maxAmount!.toStringAsFixed(0)}';
  }
}
