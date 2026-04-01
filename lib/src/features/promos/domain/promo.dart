import 'package:dart_mappable/dart_mappable.dart';

part 'promo.mapper.dart';

/// Promo domain model.
///
/// Represents a loyalty promotion with a free-weight reward
/// earned after completing a set number of orders.
@MappableClass()
class Promo with PromoMappable {
  const Promo({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.requiredOrders,
    required this.rewardFreeWeight,
    this.isActive = true,
    this.branch,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Promo display name.
  final String name;

  /// Optional description.
  final String? description;

  /// When the promo starts.
  final DateTime startDate;

  /// When the promo expires.
  final DateTime endDate;

  /// Number of orders required to earn the reward.
  final int requiredOrders;

  /// Free weight reward amount in kg.
  final num rewardFreeWeight;

  /// Whether the promo is enabled by admin.
  final bool isActive;

  /// Branch FK ID (null = all branches).
  final String? branch;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether the promo is active and within the valid date range.
  bool get isCurrentlyActive =>
      isActive &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);

  /// Human-readable reward display.
  String get rewardDisplay => 'Free ${rewardFreeWeight}kg';
}
