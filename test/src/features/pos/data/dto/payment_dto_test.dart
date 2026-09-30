import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/features/pos/data/dto/payment_dto.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('PaymentDto', () {
    test('maps voidedBy from record', () {
      final record = RecordModel({
        'id': 'pay1',
        'collectionId': 'col',
        'collectionName': 'payments',
        'sale': 'sale1',
        'amount': 50,
        'paymentMethod': 'cash',
        'type': 'payment',
        'isVoided': true,
        'voidedBy': 'user_void',
        'voidedAt': '2026-04-01 10:00:00.000Z',
      });

      final entity = PaymentDto.fromRecord(record).toEntity();

      expect(entity.isVoided, isTrue);
      expect(entity.voidedById, 'user_void');
    });
  });
}
