import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/i18n/strings.g.dart';
import 'package:hzn_laundry/src/core/packages/pocketbase/pb_connectivity_provider.dart';
import 'package:hzn_laundry/src/core/widgets/desktop_side_nav.dart';
import 'package:hzn_laundry/src/core/widgets/nav_permissions.dart';

void main() {
  final allItems = buildAllNavItems((key) => switch (key) {
        'dashboard' => 'Dashboard',
        'salesHistory' => 'Orders',
        'products' => 'Products',
        'services' => 'Services',
        'customers' => 'Customers',
        'employees' => 'Employees',
        'reports' => 'Reports',
        'activities' => 'Activities',
        'management' => 'Management',
        'organizations' => 'Organizations',
        'system' => 'System',
        _ => key,
      });

  Widget buildHarness({
    required List<NavItem> visibleItems,
    int selectedIndex = 0,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => SizedBox(
            width: 1200,
            height: 1200,
            child: DesktopSideNav(
              selectedIndex: selectedIndex,
              onDestinationSelected: (_) {},
              visibleItems: visibleItems,
            ),
          ),
        ),
      ],
    );

    return TranslationProvider(
      child: ProviderScope(
        overrides: [
          pbConnectivityProvider.overrideWith(_FakePbConnectivity.new),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('renders dashboard, shortcuts, categories, and system',
      (tester) async {
    await tester.pumpWidget(buildHarness(visibleItems: allItems));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Shortcuts'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Employees'), findsNothing);
    expect(find.text('Reports'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('System'),
      48,
      scrollable: find.descendant(
        of: find.byType(DesktopSideNav),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('System'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Administration'),
      48,
      scrollable: find.descendant(
        of: find.byType(DesktopSideNav),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Administration'), findsOneWidget);
  });

  testWidgets('hides empty categories when items are not visible',
      (tester) async {
    final staffItems = allItems
        .where(
          (item) =>
              item.id == NavId.dashboard ||
              item.id == NavId.customers ||
              item.id == NavId.organizations,
        )
        .toList();

    await tester.pumpWidget(buildHarness(visibleItems: staffItems));
    await tester.pumpAndSettle();

    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Administration'), findsOneWidget);
    expect(find.text('People'), findsNothing);
    expect(find.text('Insights'), findsNothing);
    expect(find.text('Operations'), findsNothing);
  });

  testWidgets('collapse toggle hides section labels', (tester) async {
    await tester.pumpWidget(buildHarness(visibleItems: allItems));
    await tester.pumpAndSettle();

    expect(find.text('Shortcuts'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();

    expect(find.text('Shortcuts'), findsNothing);
    expect(find.text('Categories'), findsNothing);
    expect(find.byTooltip('Dashboard'), findsOneWidget);
  });

  testWidgets('show more reveals extra shortcut destinations', (tester) async {
    await tester.pumpWidget(buildHarness(visibleItems: allItems));
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsNothing);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Employees'), findsOneWidget);
  });

  testWidgets('category flyout shows remaining items on tap when collapsed',
      (tester) async {
    await tester.pumpWidget(buildHarness(visibleItems: allItems));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('People'));
    await tester.pumpAndSettle();

    expect(find.text('Employees'), findsOneWidget);
  });
}

class _FakePbConnectivity extends PbConnectivity {
  @override
  Future<PbHealthSnapshot> build() async {
    return const PbHealthSnapshot(status: PbConnectionStatus.online);
  }
}
