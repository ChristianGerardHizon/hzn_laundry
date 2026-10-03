import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/features/pos/domain/delivery_fee.dart';
import 'package:hzn_laundry/src/features/pos/domain/fulfillment_type.dart';
import 'package:hzn_laundry/src/features/pos/domain/order_status.dart';

void main() {
  group('DeliveryFee.calculate', () {
    test('within included km charges only the base fee', () {
      expect(
        DeliveryFee.calculate(
            distanceKm: 1.5, baseFee: 50, includedKm: 2, ratePerKm: 10),
        50,
      );
    });

    test('adds per-km rate beyond included km', () {
      expect(
        DeliveryFee.calculate(
            distanceKm: 5, baseFee: 50, includedKm: 2, ratePerKm: 10),
        80,
      );
    });

    test('zero distance is the base fee', () {
      expect(
        DeliveryFee.calculate(
            distanceKm: 0, baseFee: 40, includedKm: 0, ratePerKm: 15),
        40,
      );
    });

    test('rounds to centavos', () {
      expect(
        DeliveryFee.calculate(
            distanceKm: 3.333, baseFee: 0, includedKm: 0, ratePerKm: 10),
        33.33,
      );
    });
  });

  group('OrderStatus workflow', () {
    test('pickup skips forDelivery', () {
      expect(OrderStatus.ready.nextFor(FulfillmentType.pickup),
          OrderStatus.pickedUp);
      expect(OrderStatus.ready.next, OrderStatus.pickedUp);
      expect(OrderStatus.valuesFor(FulfillmentType.pickup),
          isNot(contains(OrderStatus.forDelivery)));
    });

    test('delivery goes ready -> forDelivery -> pickedUp', () {
      expect(OrderStatus.ready.nextFor(FulfillmentType.delivery),
          OrderStatus.forDelivery);
      expect(OrderStatus.forDelivery.nextFor(FulfillmentType.delivery),
          OrderStatus.pickedUp);
      expect(OrderStatus.valuesFor(FulfillmentType.delivery),
          contains(OrderStatus.forDelivery));
    });

    test('final status reads Fulfilled for every org', () {
      expect(OrderStatus.pickedUp.displayName, 'Fulfilled');
    });

    test('missing fulfillment type parses as pickup', () {
      expect(FulfillmentType.parse(null), FulfillmentType.pickup);
      expect(FulfillmentType.parse(''), FulfillmentType.pickup);
      expect(FulfillmentType.parse('delivery'), FulfillmentType.delivery);
    });
  });
}
