import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/features/sales/presentation/widgets/delivery_order_section.dart';
import 'package:hzn_laundry/src/features/settings/presentation/controllers/current_branch_controller.dart';

void main() {
  testWidgets('Pickup and Delivery chips have spacing and 44px height',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentBranchIdProvider.overrideWithValue(null)],
        child: MaterialApp(
          home: Scaffold(
            body: FormBuilder(
              child: DeliveryOrderSection(
                draft: const DeliveryDraft(),
                enabled: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final pickup = tester.getRect(find.widgetWithText(ChoiceChip, 'Pickup'));
    final delivery = tester.getRect(find.widgetWithText(ChoiceChip, 'Delivery'));

    expect(delivery.left - pickup.right, greaterThanOrEqualTo(8),
        reason: 'chips must not touch');
    expect(pickup.height, greaterThanOrEqualTo(44));
    expect(delivery.height, greaterThanOrEqualTo(44));
  });
}
