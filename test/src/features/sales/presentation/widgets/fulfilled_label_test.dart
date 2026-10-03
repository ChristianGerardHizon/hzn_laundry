import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/features/pos/domain/order_status.dart';
import 'package:hzn_laundry/src/features/pos/domain/sale.dart';
import 'package:hzn_laundry/src/features/sales/presentation/widgets/sale_highlight_banner.dart';
import 'package:hzn_laundry/src/features/sales/presentation/widgets/sale_list_status_chip.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

Sale _sale(OrderStatus status) => Sale(
      id: 's1',
      receiptNumber: 'S-1',
      branchId: 'b1',
      cashierId: 'u1',
      totalAmount: 100,
      status: 'pending',
      orderStatus: status,
    );

void main() {
  // The final status reads "Fulfilled" for every org; the delivery feature
  // flag must not be needed (no ProviderScope here on purpose).
  testWidgets('list chip shows Fulfilled without any feature flag',
      (tester) async {
    await tester
        .pumpWidget(_wrap(SaleListStatusChip(sale: _sale(OrderStatus.pickedUp))));
    expect(find.text('Fulfilled'), findsOneWidget);
    expect(find.text('Picked up'), findsNothing);
  });

  testWidgets('banner uses Fulfilled wording for unpaid pickup orders',
      (tester) async {
    await tester.pumpWidget(_wrap(const SaleHighlightBanner(
      orderStatus: OrderStatus.pickedUp,
      isPaid: false,
      saleStatus: 'completed',
    )));
    expect(find.text('Fulfilled - Unpaid'), findsOneWidget);
  });

  testWidgets('banner keeps delivery wording for delivery orders',
      (tester) async {
    await tester.pumpWidget(_wrap(const SaleHighlightBanner(
      orderStatus: OrderStatus.pickedUp,
      isPaid: false,
      saleStatus: 'completed',
      isDelivery: true,
    )));
    expect(find.text('Delivered - Unpaid'), findsOneWidget);
  });

  test('every status has a label and Fulfilled replaces Picked Up', () {
    expect(OrderStatus.values.map((s) => s.displayName),
        ['Pending', 'Processing', 'Ready', 'Out for Delivery', 'Fulfilled']);
  });
}
