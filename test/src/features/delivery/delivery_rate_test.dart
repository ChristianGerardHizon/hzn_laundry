import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/features/delivery/domain/customer_address.dart';
import 'package:hzn_laundry/src/features/delivery/domain/delivery_rate.dart';
import 'package:hzn_laundry/src/features/pos/domain/fulfillment_type.dart';
import 'package:hzn_laundry/src/features/sales/presentation/widgets/delivery_order_section.dart';

void main() {
  const standard = DeliveryRate(
    id: 'r1',
    branchId: 'b1',
    name: 'Standard',
    baseFee: 50,
    includedKm: 2,
    ratePerKm: 10,
    isDefault: true,
  );
  const far = DeliveryRate(
    id: 'r2',
    branchId: 'b1',
    name: 'Far area',
    baseFee: 100,
    includedKm: 0,
    ratePerKm: 20,
  );

  group('DeliveryRate', () {
    test('fee uses base + per-km beyond included distance', () {
      expect(standard.feeFor(5), 80);
      expect(far.feeFor(5), 200);
    });

    test('per-order rate override replaces the per-km rate only', () {
      expect(standard.feeFor(5, ratePerKmOverride: 15), 95);
    });
  });

  test('summary drops trailing .0', () {
    expect(standard.summary, '₱50 base (2 km) + ₱10/km');
    expect(standard.copyWith(ratePerKm: 12.5).summary, '₱50 base (2 km) + ₱12.5/km');
  });

  group('DeliveryDraft', () {
    test('pickup orders never charge a fee', () {
      const d = DeliveryDraft(rate: standard, distanceKm: 10);
      expect(d.fee(), 0);
    });

    test('delivery fee comes from the selected rate and distance', () {
      const d = DeliveryDraft(
        type: FulfillmentType.delivery,
        rate: standard,
        distanceKm: 5,
      );
      expect(d.calculatedFee(), 80);
      expect(d.fee(), 80);
      expect(d.effectiveRate(), 10);
    });

    test('switching rate changes the fee; typed rate and override win', () {
      const base = DeliveryDraft(
        type: FulfillmentType.delivery,
        rate: far,
        distanceKm: 5,
      );
      expect(base.fee(), 200);
      expect(base.copyWith(ratePerKm: 30).fee(), 250);
      expect(base.copyWith(feeOverride: 40).fee(), 40);
    });

    test('no rates configured: only a typed rate applies', () {
      const d = DeliveryDraft(
        type: FulfillmentType.delivery,
        distanceKm: 3,
        ratePerKm: 10,
      );
      expect(d.fee(), 30);
    });
  });

  test('address display name uses the label when present', () {
    const a = CustomerAddress(
      id: 'a1',
      customerId: 'c1',
      address: '12 Main St',
      label: 'Home',
    );
    expect(a.displayName, 'Home - 12 Main St');
    expect(a.copyWith(label: null).displayName, '12 Main St');
  });
}
