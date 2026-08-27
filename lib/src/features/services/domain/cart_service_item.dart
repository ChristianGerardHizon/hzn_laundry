import 'package:dart_mappable/dart_mappable.dart';

import 'service.dart';
import 'service_price_tier.dart';

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
    this.priceTiers = const [],
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

  /// In-memory price tiers for this service (not persisted on the cart row).
  final List<ServicePriceTier> priceTiers;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// The effective unit price for this item.
  num get effectivePrice {
    if (hasCustomPrice) return customPrice!;
    if (quantity <= 0) return service?.price ?? 0;
    return total / quantity;
  }

  /// Total price of this item.
  num get total {
    if (hasCustomPrice) return customPrice! * quantity;
    return resolveServiceTotal(
      price: service?.price ?? 0,
      quantity: quantity,
      minimumCharge: service?.minimumCharge ?? 0,
      tiers: priceTiers,
    );
  }

  /// Whether this item uses a custom price.
  bool get hasCustomPrice => customPrice != null;
}
