import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/features/pos/data/dto/sale_dto.dart';
import 'package:hzn_laundry/src/features/pos/domain/fulfillment_type.dart';
import 'package:hzn_laundry/src/features/pos/domain/order_status.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('SaleDto', () {
    test('maps voidedBy and voidedAt from record', () {
      final record = RecordModel({
        'id': 'sale1',
        'collectionId': 'col',
        'collectionName': 'sales',
        'receiptNumber': 'S-001',
        'branch': 'b1',
        'cashier': 'u1',
        'totalAmount': 100,
        'status': 'voided',
        'orderStatus': 'pending',
        'isPaid': false,
        'paymentStatus': 'unpaid',
        'packs': 0,
        'voidedBy': 'user_void',
        'voidedAt': '2026-04-01 10:00:00.000Z',
      });

      final entity = SaleDto.fromRecord(record).toEntity();

      expect(entity.voidedById, 'user_void');
      expect(entity.voidedAt, isNotNull);
      expect(entity.orderStatus, OrderStatus.pending);
    });

    Map<String, dynamic> base() => {
          'id': 'sale1',
          'collectionId': 'col',
          'collectionName': 'sales',
          'receiptNumber': 'S-001',
          'branch': 'b1',
          'cashier': 'u1',
          'totalAmount': 100,
          'status': 'pending',
          'isPaid': false,
          'paymentStatus': 'unpaid',
          'packs': 0,
        };

    test('legacy record without delivery fields is a pickup order', () {
      final entity = SaleDto.fromRecord(
        RecordModel({...base(), 'orderStatus': 'ready'}),
      ).toEntity();

      expect(entity.fulfillmentType, FulfillmentType.pickup);
      expect(entity.isDelivery, isFalse);
      expect(entity.deliveryFee, 0);
      expect(entity.deliveryAddress, isNull);
    });

    test('maps forDelivery status and delivery fields', () {
      final entity = SaleDto.fromRecord(
        RecordModel({
          ...base(),
          'orderStatus': 'forDelivery',
          'fulfillmentType': 'delivery',
          'deliveryAddress': '12 Main St',
          'distanceKm': 4.5,
          'deliveryRatePerKm': 10,
          'deliveryFee': 75,
          'deliveryFeeOverridden': true,
        }),
      ).toEntity();

      expect(entity.orderStatus, OrderStatus.forDelivery);
      expect(entity.fulfillmentType, FulfillmentType.delivery);
      expect(entity.deliveryAddress, '12 Main St');
      expect(entity.distanceKm, 4.5);
      expect(entity.deliveryFee, 75);
      expect(entity.deliveryFeeOverridden, isTrue);
    });
  });
}
