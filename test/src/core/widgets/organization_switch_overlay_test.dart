import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/i18n/strings.g.dart';
import 'package:hzn_laundry/src/core/widgets/organization_switch_overlay.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/controllers/current_organization_controller.dart';

void main() {
  testWidgets('shows opaque switching screen with org letter-mark',
      (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            organizationSwitchOverlayProvider.overrideWith(
              _ActiveOverlay.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  SizedBox.expand(),
                  OrganizationSwitchLoadingOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(OrganizationSwitchLoadingOverlay),
        matching: find.byType(ColoredBox),
      ),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('AL'), findsOneWidget);
    expect(find.text('Switching to Main Branch…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('hides when overlay is inactive', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  SizedBox.expand(),
                  OrganizationSwitchLoadingOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(OrganizationSwitchLoadingOverlay),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
    expect(find.textContaining('Switching'), findsNothing);
  });
}

class _ActiveOverlay extends OrganizationSwitchOverlay {
  @override
  OrganizationSwitchOverlayState build() {
    return const OrganizationSwitchOverlayState(
      active: true,
      targetName: 'Main Branch',
      organizationLabel: 'Acme Laundry',
    );
  }
}
