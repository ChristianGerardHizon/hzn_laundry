import 'package:dart_mappable/dart_mappable.dart';

part 'load_rule.mapper.dart';

/// Load rule domain model.
///
/// Represents one weight tier for a machine: a weight range (kg) that maps to
/// a number of loads. Tiers are intentionally non-linear and customizable
/// (e.g. small machine: 0–8 kg = 1 load, 8.1–12 kg = 2 loads).
@MappableClass()
class LoadRule with LoadRuleMappable {
  const LoadRule({
    required this.id,
    required this.machineId,
    required this.loadCount,
    this.minWeight,
    this.maxWeight,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  static const String collectionName = 'machineLoadRules';

  /// PocketBase record ID.
  final String id;

  /// Machine this rule belongs to.
  final String machineId;

  /// Number of loads this tier represents.
  final int loadCount;

  /// Inclusive lower weight bound in kg. Null = no lower bound (0).
  final double? minWeight;

  /// Inclusive upper weight bound in kg. Null = "and up" (no upper bound).
  final double? maxWeight;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether [weight] (kg) falls within this rule's tier.
  ///
  /// Lower bound defaults to 0 when [minWeight] is null; upper bound is
  /// treated as unbounded when [maxWeight] is null. Both bounds inclusive.
  bool matches(double weight) {
    final min = minWeight ?? 0;
    if (weight < min) return false;
    if (maxWeight != null && weight > maxWeight!) return false;
    return true;
  }
}
