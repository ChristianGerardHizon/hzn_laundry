import 'package:flutter_test/flutter_test.dart';

import 'package:hizonelaundry/src/features/services/domain/service_price_tier.dart';

void main() {
  group('resolveServiceTotal', () {
    test('Magsaysay FULL SERVICE: ₱20/kg with ₱120 minimum', () {
      num magTotal(num kg) => resolveServiceTotal(
            price: 20,
            quantity: kg,
            minimumCharge: 120,
          );

      expect(magTotal(4), 120);
      expect(magTotal(6), 120);
      expect(magTotal(7), 140);
      expect(magTotal(8), 160);
      expect(magTotal(14), 280);
    });

    test('no minimum charge uses price × quantity', () {
      expect(
        resolveServiceTotal(price: 20, quantity: 4, minimumCharge: 0),
        80,
      );
    });

    test('Hi-Zone Full Service flat buckets are unchanged', () {
      const tiers = [
        ServicePriceTier(
          id: 'a',
          serviceId: 'hz',
          minQuantity: 1,
          maxQuantity: 6,
          pricePerUnit: 150,
        ),
        ServicePriceTier(
          id: 'b',
          serviceId: 'hz',
          minQuantity: 7,
          maxQuantity: 8,
          pricePerUnit: 200,
        ),
      ];

      expect(
        resolveServiceTotal(price: 120, quantity: 6, tiers: tiers),
        150,
      );
      expect(
        resolveServiceTotal(price: 120, quantity: 8, tiers: tiers),
        200,
      );
    });
  });
}
