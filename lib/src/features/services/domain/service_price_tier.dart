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
    this.flatPrice,
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

  /// Price per unit for this tier (used when [flatPrice] is not set).
  final num pricePerUnit;

  /// Flat price for this tier's quantity range.
  /// When set (and > 0), the total is this flat amount regardless of quantity.
  final num? flatPrice;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this tier uses flat pricing.
  bool get isFlatPrice => flatPrice != null && flatPrice! > 0;

  /// Whether this tier has an upper bound.
  bool get hasUpperBound => maxQuantity != null && maxQuantity! > 0;

  /// Display-friendly range text. When [nextTierMin] is provided,
  /// shows `nextTierMin - 0.01` as the upper bound to indicate decimals
  /// are covered (e.g. "1 – 6.99 kg" when next tier starts at 7).
  String displayRange(String unitLabel, {num? nextTierMin}) {
    if (!hasUpperBound) return '$minQuantity+ $unitLabel';
    final displayMax = nextTierMin != null ? nextTierMin - 0.01 : maxQuantity;
    return '$minQuantity – $displayMax $unitLabel';
  }

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
/// Tier prices are always flat totals for the range (e.g. 1-3 kg = ₱300).
/// Returns `tierPrice / quantity` so that `unitPrice * quantity == tierPrice`.
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

  final tier = _findMatchingTier(tiers, quantity);
  if (tier == null) return basePrice;

  return quantity > 0 ? tier.pricePerUnit / quantity : tier.pricePerUnit;
}

/// Resolves the total price for a given quantity from a list of tiers.
/// Tier prices are flat totals — returns the tier price directly.
/// Falls back to `basePrice * quantity` if no tier matches.
num resolveTieredTotal(
  List<ServicePriceTier> tiers,
  num quantity,
  num basePrice,
) {
  if (tiers.isEmpty) return basePrice * quantity;

  final tier = _findMatchingTier(tiers, quantity);
  if (tier == null) return basePrice * quantity;

  return tier.pricePerUnit;
}

/// Returns the matching tier for a quantity, or null if none matches.
ServicePriceTier? findMatchingTier(
  List<ServicePriceTier> tiers,
  num quantity,
) =>
    _findMatchingTier(tiers, quantity);

/// Resolves the total price for a service line.
///
/// When [tiers] are present, uses flat range totals ([resolveTieredTotal]).
/// Otherwise uses `price * quantity`. A positive [minimumCharge] is then
/// applied as a floor so Mag-style ₱20/kg with ₱120 min works without
/// changing Hi-Zone bucket tiers (their [minimumCharge] is 0).
num resolveServiceTotal({
  required num price,
  required num quantity,
  num minimumCharge = 0,
  List<ServicePriceTier> tiers = const [],
}) {
  final raw = tiers.isEmpty
      ? price * quantity
      : resolveTieredTotal(tiers, quantity, price);
  if (minimumCharge > 0 && raw < minimumCharge) return minimumCharge;
  return raw;
}

/// Unit price implied by [resolveServiceTotal] (`total / quantity`).
num resolveServiceUnitPrice({
  required num price,
  required num quantity,
  num minimumCharge = 0,
  List<ServicePriceTier> tiers = const [],
}) {
  if (quantity <= 0) return price;
  return resolveServiceTotal(
        price: price,
        quantity: quantity,
        minimumCharge: minimumCharge,
        tiers: tiers,
      ) /
      quantity;
}

ServicePriceTier? _findMatchingTier(
  List<ServicePriceTier> tiers,
  num quantity,
) {
  if (tiers.isEmpty) return null;

  final sorted = [...tiers]
    ..sort((a, b) => a.minQuantity.compareTo(b.minQuantity));

  for (int i = 0; i < sorted.length; i++) {
    final nextMin = i + 1 < sorted.length ? sorted[i + 1].minQuantity : null;
    if (sorted[i].containsQuantityWithNext(quantity, nextTierMin: nextMin)) {
      return sorted[i];
    }
  }

  return null;
}
