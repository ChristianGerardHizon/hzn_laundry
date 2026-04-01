import 'package:dart_mappable/dart_mappable.dart';

import 'promo.dart';

part 'customer_promo.mapper.dart';

/// Tracks a customer's progress in a loyalty promo.
///
/// Each record represents one customer enrolled in one promo,
/// tracking completed orders and reward redemption state.
@MappableClass()
class CustomerPromo with CustomerPromoMappable {
  const CustomerPromo({
    required this.id,
    required this.customerId,
    required this.promoId,
    this.completedOrders = 0,
    this.isRewardEarned = false,
    this.isRewardRedeemed = false,
    this.redeemedOnSaleId,
    this.promo,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Customer FK ID.
  final String customerId;

  /// Promo FK ID.
  final String promoId;

  /// Number of qualifying orders completed.
  final int completedOrders;

  /// Whether the reward threshold has been reached.
  final bool isRewardEarned;

  /// Whether the reward has been applied to an order.
  final bool isRewardRedeemed;

  /// Sale ID where the reward was redeemed.
  final String? redeemedOnSaleId;

  /// Expanded promo details.
  final Promo? promo;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Orders remaining until reward is earned.
  int get remainingOrders =>
      promo != null
          ? (promo!.requiredOrders - completedOrders)
              .clamp(0, promo!.requiredOrders)
          : 0;

  /// Whether the reward can be redeemed now.
  bool get canRedeem => isRewardEarned && !isRewardRedeemed;

  /// Progress towards earning the reward (0.0 to 1.0).
  double get progressPercent =>
      promo != null
          ? (completedOrders / promo!.requiredOrders).clamp(0.0, 1.0)
          : 0.0;
}
