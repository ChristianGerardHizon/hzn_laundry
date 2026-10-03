/// Delivery fee calculation.
///
/// `fee = baseFee + max(0, distanceKm - includedKm) * ratePerKm`
///
/// The base fee is the baseline: it already covers the first [includedKm]
/// kilometres. Staff may still override the final fee with any amount.
class DeliveryFee {
  const DeliveryFee._();

  static num calculate({
    required num distanceKm,
    required num baseFee,
    required num includedKm,
    required num ratePerKm,
  }) {
    final billableKm = distanceKm > includedKm ? distanceKm - includedKm : 0;
    final fee = baseFee + billableKm * ratePerKm;
    // Round to centavos to avoid floating point noise (e.g. 12.500000001).
    return (fee * 100).round() / 100;
  }
}
