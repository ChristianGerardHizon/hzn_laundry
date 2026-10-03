import 'package:dart_mappable/dart_mappable.dart';

import 'fulfillment_type.dart';

part 'order_status.mapper.dart';

/// Status of an order in the fulfillment workflow.
///
/// Pickup: pending → processing → ready → pickedUp.
/// Delivery: pending → processing → ready → forDelivery → pickedUp.
@MappableEnum()
enum OrderStatus {
  pending,
  processing,
  ready,
  forDelivery,
  pickedUp;

  String get displayName => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.processing => 'Processing',
        OrderStatus.ready => 'Ready',
        OrderStatus.forDelivery => 'Out for Delivery',
        OrderStatus.pickedUp => 'Picked Up',
      };

  /// Display name used when the `delivery` feature is enabled for the
  /// organization. The final status reads "Fulfilled" so it fits both pickup
  /// and delivery orders; organizations without the feature keep "Picked Up".
  String labelFor({required bool deliveryEnabled}) =>
      this == OrderStatus.pickedUp && deliveryEnabled
          ? 'Fulfilled'
          : displayName;

  /// Next status in the (pickup) fulfillment workflow, or null when already
  /// picked up. Prefer [nextFor] when the fulfillment type is known.
  OrderStatus? get next => nextFor(FulfillmentType.pickup);

  /// Next status for [type], or null when the order is already finished.
  OrderStatus? nextFor(FulfillmentType type) => switch (this) {
        OrderStatus.pending => OrderStatus.processing,
        OrderStatus.processing => OrderStatus.ready,
        OrderStatus.ready => type.isDelivery
            ? OrderStatus.forDelivery
            : OrderStatus.pickedUp,
        OrderStatus.forDelivery => OrderStatus.pickedUp,
        OrderStatus.pickedUp => null,
      };

  /// Statuses an order of [type] can be in. Pickup orders never use
  /// [forDelivery].
  static List<OrderStatus> valuesFor(FulfillmentType type) => [
        for (final s in OrderStatus.values)
          if (type.isDelivery || s != OrderStatus.forDelivery) s,
      ];

  /// Returns the icon for this order status.
  String get iconName => switch (this) {
        OrderStatus.pending => 'schedule',
        OrderStatus.processing => 'autorenew',
        OrderStatus.ready => 'check_circle',
        OrderStatus.forDelivery => 'delivery_dining',
        OrderStatus.pickedUp => 'local_shipping',
      };
}
