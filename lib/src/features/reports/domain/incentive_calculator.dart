import '../../settings/domain/incentive_tier.dart';

/// Calculates the incentive for a given service total using custom tiers.
///
/// Tiers are matched by selecting the one with the highest [IncentiveTier.minAmount]
/// that is still <= [serviceTotal]. This ensures higher tiers take priority at
/// boundary values (e.g. when tier1.maxAmount == tier2.minAmount).
///
/// Falls back to legacy flat rate if no tiers are configured.
num calculateIncentive(
  num serviceTotal,
  List<IncentiveTier> tiers,
  num legacyRate,
  num legacyPerServicePrice,
) {
  if (serviceTotal <= 0) return 0;

  if (tiers.isNotEmpty) {
    // Sort descending by minAmount so the highest applicable tier wins.
    // This prevents lower tiers from matching when there is an overlap at
    // tier boundaries (e.g. tier1.max == tier2.min).
    final sorted = [...tiers]
      ..sort((a, b) => b.minAmount.compareTo(a.minAmount));

    for (final tier in sorted) {
      final matchesMin = serviceTotal >= tier.minAmount;
      final matchesMax =
          tier.maxAmount == null || serviceTotal <= tier.maxAmount!;
      if (matchesMin && matchesMax) {
        return tier.incentiveAmount;
      }
    }

    // Service price is below all tiers — use the lowest tier's incentive.
    return sorted.last.incentiveAmount;
  }

  // Legacy flat rate fallback: ceil(serviceTotal / perServicePrice) * rate
  if (legacyPerServicePrice > 0) {
    return (serviceTotal / legacyPerServicePrice).ceil() * legacyRate;
  }
  return 0;
}
