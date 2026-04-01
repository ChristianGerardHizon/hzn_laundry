import 'package:dart_mappable/dart_mappable.dart';

import 'service.dart';

part 'cart_service_item.mapper.dart';

/// Cart Service Item domain model.
///
/// Represents a single service line item in a shopping cart.
@MappableClass()
class CartServiceItem with CartServiceItemMappable {
  const CartServiceItem({
    this.id = '',
    this.cartId = '',
    this.serviceId = '',
    this.service,
    this.quantity = 1,
    this.customPrice,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent Cart ID.
  final String cartId;

  /// Service ID.
  final String serviceId;

  /// Expanded Service (optional).
  final Service? service;

  /// Quantity.
  final num quantity;

  /// Custom price override (for variable-price services).
  final num? customPrice;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// The effective unit price for this item.
  num get effectivePrice => customPrice ?? service?.price ?? 0;

  /// Total price of this item (quantity * effective price).
  num get total => effectivePrice * quantity;

  /// Whether this item uses a custom price.
  bool get hasCustomPrice => customPrice != null;
}
