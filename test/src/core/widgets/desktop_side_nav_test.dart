import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/config/app_environment.dart';
import 'package:hzn_laundry/src/core/i18n/strings.g.dart';
import 'package:hzn_laundry/src/core/packages/pocketbase/pb_connectivity_provider.dart';
import 'package:hzn_laundry/src/core/widgets/desktop_nav_item.dart';
import 'package:hzn_laundry/src/core/widgets/desktop_side_nav.dart';
import 'package:hzn_laundry/src/core/widgets/nav_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        'profile' => 'Profile',
        _ => key,
      });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildHarness({
    required List<NavItem> visibleItems,
    int selectedIndex = 0,
    String location = '/',
    ValueChanged<int>? onDestinationSelected,
  }) {
    final router = GoRouter(
      initialLocation: location,
      routes: [
        for (final path in {'/', '/management/roles'})
          GoRoute(
            path: path,
            builder: (context, state) => SizedBox(
              width: 1200,
              height: 1200,
              child: DesktopSideNav(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected ?? (_) {},
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

  Future<void> pumpNav(
    WidgetTester tester, {
    List<NavItem>? items,
    int selectedIndex = 0,
    String location = '/',
    ValueChanged<int>? onDestinationSelected,
  }) async {
    // Tall enough that the lazy ListView builds every row.
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildHarness(
        visibleItems: items ?? allItems,
        selectedIndex: selectedIndex,
        location: location,
        onDestinationSelected: onDestinationSelected,
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Hovers [label]'s row and taps its pin/unpin button.
  Future<void> hoverAndTapPin(
    WidgetTester tester,
    String label,
    String tooltip,
  ) async {
    final row = find.ancestor(
      of: find.text(label),
      matching: find.byType(DesktopPinnableNavItem),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(row));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: row, matching: find.byTooltip(tooltip)),
    );
    await tester.pumpAndSettle();
    await mouse.removePointer();
  }

  Future<List<String>> storedPins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('nav.pinned.anonymous') ?? const [];
  }

  testWidgets('renders dashboard, pinned defaults, logical groups, footer',
      (tester) async {
    await pumpNav(tester);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text(pocketbaseUrl), findsOneWidget);

    // Default pins (previous "shortcuts").
    expect(find.text('Pinned'), findsOneWidget);
    for (final label in ['Orders', 'Products', 'Services', 'Customers']) {
      expect(find.text(label), findsOneWidget);
    }

    // Everything else is inline under a named group: no "Show more" needed.
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Setup'), findsOneWidget);
    expect(find.text('Administration'), findsOneWidget);
    expect(find.text('Employees'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Activities'), findsOneWidget);
    expect(find.text('Show more'), findsNothing);
    expect(find.text('Categories'), findsNothing);

    // Footer stays reachable.
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('setup and administration start collapsed and expand on tap',
      (tester) async {
    await pumpNav(tester);

    expect(find.text('Branches'), findsNothing);
    expect(find.text('Users'), findsNothing);

    await tester.tap(find.text('Setup'));
    await tester.pumpAndSettle();

    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Machines'), findsOneWidget);
    expect(find.text('Users'), findsNothing);

    await tester.tap(find.text('Administration'));
    await tester.pumpAndSettle();

    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Roles'), findsOneWidget);
    expect(find.text('Organizations'), findsOneWidget);

    // Collapse again.
    await tester.tap(find.text('Setup'));
    await tester.pumpAndSettle();
    expect(find.text('Branches'), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('nav.collapsed.anonymous'), ['setup']);
  });

  testWidgets('collapsed group still shows the active page', (tester) async {
    await pumpNav(
      tester,
      selectedIndex: allItems.indexWhere((i) => i.id == NavId.management),
      location: '/management/roles',
    );

    expect(find.text('Roles'), findsOneWidget);
    expect(find.text('Users'), findsNothing);
  });

  testWidgets('hides empty groups when items are not visible', (tester) async {
    final staffItems = allItems
        .where(
          (item) =>
              item.id == NavId.dashboard ||
              item.id == NavId.customers ||
              item.id == NavId.organizations,
        )
        .toList();

    await pumpNav(tester, items: staffItems);

    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Administration'), findsOneWidget);
    expect(find.text('Setup'), findsNothing);
    expect(find.text('Operations'), findsNothing);
    expect(find.text('Insights'), findsNothing);
    // Customers is pinned by default, leaving People empty.
    expect(find.text('People'), findsNothing);
  });

  testWidgets('long-press pins a destination and moves it to Pinned',
      (tester) async {
    await pumpNav(tester);
    expect(find.text('People'), findsOneWidget);

    await tester.longPress(find.text('Employees'));
    await tester.pumpAndSettle();

    // People only contained Employees, so the group disappears.
    expect(find.text('People'), findsNothing);
    expect(find.text('Employees'), findsOneWidget);
    expect(await storedPins(), contains('nav.employees'));
  });

  testWidgets('hover pin button pins and unpins', (tester) async {
    await pumpNav(tester);

    await hoverAndTapPin(tester, 'Reports', 'Pin to top');
    expect(await storedPins(), contains('nav.reports'));

    // Now lives under Pinned (after the default pins), not Insights.
    final reportsY = tester.getTopLeft(find.text('Reports')).dy;
    final insightsY = tester.getTopLeft(find.text('Insights')).dy;
    expect(reportsY, lessThan(insightsY));

    await hoverAndTapPin(tester, 'Reports', 'Unpin');
    expect(await storedPins(), isNot(contains('nav.reports')));
    expect(
      tester.getTopLeft(find.text('Reports')).dy,
      greaterThan(tester.getTopLeft(find.text('Insights')).dy),
    );
  });

  testWidgets('stored pins are restored and replace the defaults',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'nav.pinned.anonymous': ['nav.reports'],
    });

    await pumpNav(tester);

    final pinnedY = tester.getTopLeft(find.text('Pinned')).dy;
    final operationsY = tester.getTopLeft(find.text('Operations')).dy;
    final reportsY = tester.getTopLeft(find.text('Reports')).dy;
    expect(reportsY, greaterThan(pinnedY));
    expect(reportsY, lessThan(operationsY));
    // Orders no longer pinned: it sits inside Operations.
    expect(
      tester.getTopLeft(find.text('Orders')).dy,
      greaterThan(operationsY),
    );
  });

  testWidgets('no Pinned section when nothing is pinned', (tester) async {
    SharedPreferences.setMockInitialValues({
      'nav.pinned.anonymous': <String>[],
    });

    await pumpNav(tester);

    expect(find.text('Pinned'), findsNothing);
    expect(find.text('Orders'), findsOneWidget);
  });

  testWidgets('collapse toggle hides labels and keeps pinned as icons',
      (tester) async {
    await pumpNav(tester);

    expect(find.text('Pinned'), findsOneWidget);
    expect(find.text(pocketbaseUrl), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();

    expect(find.text('Pinned'), findsNothing);
    expect(find.text('Operations'), findsNothing);
    expect(find.text(pocketbaseUrl), findsNothing);
    expect(find.byTooltip('Dashboard'), findsOneWidget);
    expect(find.byTooltip('Orders'), findsOneWidget);
  });

  testWidgets('category flyout shows items on tap when collapsed',
      (tester) async {
    await pumpNav(tester);

    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('People'));
    await tester.pumpAndSettle();

    expect(find.text('Employees'), findsOneWidget);
  });

  testWidgets('shows search field when expanded', (tester) async {
    await pumpNav(tester);

    expect(find.text('Search pages'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('search filters destinations and shows overlay', (tester) async {
    int? tappedIndex;

    await pumpNav(
      tester,
      onDestinationSelected: (index) => tappedIndex = index,
    );

    await tester.enterText(find.byType(TextField), 'cust');
    await tester.pumpAndSettle();

    expect(find.text('Search results'), findsOneWidget);
    expect(find.text('Customers'), findsWidgets);
    // Nav list stays underneath the compact results popover.
    expect(find.text('Pinned'), findsOneWidget);

    await tester.tap(find.text('Customers').last);
    await tester.pumpAndSettle();

    expect(tappedIndex, allItems.indexWhere((i) => i.id == NavId.customers));
    expect(find.text('Search results'), findsNothing);
  });

  testWidgets('collapse hides search field', (tester) async {
    await pumpNav(tester);

    await tester.enterText(find.byType(TextField), 'cust');
    await tester.pumpAndSettle();
    expect(find.text('Search results'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Search pages'), findsNothing);
    expect(find.text('Search results'), findsNothing);
  });
}

class _FakePbConnectivity extends PbConnectivity {
  @override
  Future<PbHealthSnapshot> build() async {
    return const PbHealthSnapshot(status: PbConnectionStatus.online);
  }
}
