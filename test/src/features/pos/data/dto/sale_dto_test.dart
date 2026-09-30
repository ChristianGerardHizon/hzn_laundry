import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/features/pos/data/dto/sale_dto.dart';
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
  });
}
