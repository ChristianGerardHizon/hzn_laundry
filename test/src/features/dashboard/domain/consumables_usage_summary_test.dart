import 'package:flutter_test/flutter_test.dart';

import 'package:hzn_laundry/src/features/dashboard/domain/consumables_usage_summary.dart';
import 'package:hzn_laundry/src/features/pos/domain/sale_consumable_usage.dart';

void main() {
  SaleConsumableUsage usage({
    required String saleId,
    required String productId,
    required String name,
    required num quantity,
    num cost = 0,
  }) {
    return SaleConsumableUsage(
      id: '$saleId-$productId',
      saleId: saleId,
      productId: productId,
      productName: name,
      quantity: quantity,
      cost: cost,
    );
  }

  test('aggregates quantity and cost per product and averages per order', () {
    final summary = ConsumablesUsageSummaryData.fromUsages(
      usages: [
        usage(
          saleId: 's1',
          productId: 'detergent',
          name: 'Detergent',
          quantity: 2,
          cost: 10,
        ),
        usage(
          saleId: 's2',
          productId: 'detergent',
          name: 'Detergent',
          quantity: 4,
          cost: 20,
        ),
        usage(
          saleId: 's2',
          productId: 'fabcon',
          name: 'Fabcon',
          quantity: 1,
          cost: 5,
        ),
      ],
      orderCount: 2,
    );

    expect(summary.totalQuantity, 7);
    expect(summary.totalCost, 35);
    expect(summary.averagePerOrder, 3.5);
    expect(summary.items, hasLength(2));
    expect(summary.items.first.productId, 'detergent');
    expect(summary.items.first.quantity, 6);
    expect(summary.items.first.orderCount, 2);
    expect(summary.items.last.productId, 'fabcon');
    expect(summary.items.last.orderCount, 1);
  });

  test('empty usages keep the order count for averaging', () {
    final summary = ConsumablesUsageSummaryData.fromUsages(
      usages: const [],
      orderCount: 5,
    );
    expect(summary.totalQuantity, 0);
    expect(summary.averagePerOrder, 0);
    expect(summary.orderCount, 5);
  });
}
