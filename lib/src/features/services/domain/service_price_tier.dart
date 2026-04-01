import 'package:dart_mappable/dart_mappable.dart';

part 'service_price_tier.mapper.dart';

/// A pricing tier for a service based on quantity range.
///
/// Example: 1-3 kg at ₱90/kg, 4-6 kg at ₱80/kg, 7+ kg at ₱70/kg.
/// When [maxQuantity] is 0 or null, the tier has no upper bound.
@MappableClass()
class ServicePriceTier with ServicePriceTierMappable {
  const ServicePriceTier({
    required this.id,
    required this.serviceId,
    required this.minQuantity,
    required this.pricePerUnit,
    this.maxQuantity,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent service ID.
  final String serviceId;

  /// Minimum quantity (inclusive) for this tier.
  final num minQuantity;

  /// Maximum quantity (inclusive) for this tier.
  /// Null or 0 means no upper limit.
  final num? maxQuantity;

  /// Price per unit for this tier.
  final num pricePerUnit;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this tier has an upper bound.
  bool get hasUpperBound =>
      maxQuantity != null && maxQuantity! > 0;

  /// Whether [quantity] falls within this tier's range.
  ///
  /// Uses inclusive min and inclusive max. For quantities with decimals
  /// that fall between integer tier boundaries (e.g. 6.5 with a tier
  /// of 1-6), use [resolveTieredPrice] which handles gaps correctly.
  bool containsQuantity(num quantity) {
    if (quantity < minQuantity) return false;
    if (!hasUpperBound) return true;
    return quantity <= maxQuantity!;
  }

  /// Whether [quantity] falls within this tier, using the next tier's
  /// minQuantity as the exclusive upper bound when available.
  /// This handles decimal quantities that fall between integer boundaries.
  bool containsQuantityWithNext(num quantity, {num? nextTierMin}) {
    if (quantity < minQuantity) return false;
    if (!hasUpperBound) return true;
    // If a next tier exists, use its min as the exclusive upper bound
    if (nextTierMin != null) return quantity < nextTierMin;
    return quantity <= maxQuantity!;
  }
}

/// Resolves the effective price per unit for a given quantity from a list
/// of tiers. Falls back to [basePrice] if no tier matches.
///
/// Handles decimal quantities (e.g. 6.5 kg) by using the next tier's
/// minQuantity as the exclusive upper bound, so 6.5 falls into the 1-6 tier
/// rather than falling through the gap between 6 and 7.
num resolveTieredPrice(
  List<ServicePriceTier> tiers,
  num quantity,
  num basePrice,
) {
  if (tiers.isEmpty) return basePrice;

  // Sort by minQuantity ascending so we match the most specific tier
  final sorted = [...tiers]
    ..sort((a, b) => a.minQuantity.compareTo(b.minQuantity));

  for (int i = 0; i < sorted.length; i++) {
    final nextMin =
        i + 1 < sorted.length ? sorted[i + 1].minQuantity : null;
    if (sorted[i].containsQuantityWithNext(quantity, nextTierMin: nextMin)) {
      return sorted[i].pricePerUnit;
    }
  }

  // No match — use the base price
  return basePrice;
}
