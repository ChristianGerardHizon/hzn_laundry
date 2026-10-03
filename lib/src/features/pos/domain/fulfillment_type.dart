import 'package:dart_mappable/dart_mappable.dart';

part 'fulfillment_type.mapper.dart';

/// How an order gets to the customer.
///
/// Missing/empty values from the server are treated as [pickup] so orders
/// created before delivery support keep working unchanged.
@MappableEnum()
enum FulfillmentType {
  pickup,
  delivery;

  String get displayName => switch (this) {
        FulfillmentType.pickup => 'Pickup',
        FulfillmentType.delivery => 'Delivery',
      };

  bool get isDelivery => this == FulfillmentType.delivery;

  static FulfillmentType parse(String? value) =>
      value == 'delivery' ? FulfillmentType.delivery : FulfillmentType.pickup;
}
