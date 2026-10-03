import 'package:dart_mappable/dart_mappable.dart';

import '../../pos/domain/delivery_fee.dart';

part 'delivery_rate.mapper.dart';

/// A named delivery rate set up on a branch (e.g. "Standard", "Far area").
///
/// Fee = [baseFee] + max(0, distance - [includedKm]) * [ratePerKm].
/// Exactly one non-deleted rate per branch is the default.
@MappableClass()
class DeliveryRate with DeliveryRateMappable {
  const DeliveryRate({
    required this.id,
    required this.branchId,
    required this.name,
    this.baseFee = 0,
    this.includedKm = 0,
    this.ratePerKm = 0,
    this.isDefault = false,
  });

  final String id;
  final String branchId;
  final String name;

  /// Flat fee covering the first [includedKm] kilometres (PHP).
  final num baseFee;
  final num includedKm;

  /// Per-km price beyond [includedKm] (PHP).
  final num ratePerKm;
  final bool isDefault;

  /// Fee for [distanceKm] using this rate, optionally with a per-order
  /// [ratePerKmOverride].
  num feeFor(num distanceKm, {num? ratePerKmOverride}) => DeliveryFee.calculate(
        distanceKm: distanceKm,
        baseFee: baseFee,
        includedKm: includedKm,
        ratePerKm: ratePerKmOverride ?? ratePerKm,
      );

  /// Short summary for lists, e.g. "₱50 base (2 km) + ₱10/km".
  String get summary =>
      '₱${_fmt(baseFee)} base (${_fmt(includedKm)} km) + ₱${_fmt(ratePerKm)}/km';

  /// 50.0 -> "50", 12.5 -> "12.5".
  static String _fmt(num n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toString();
}
