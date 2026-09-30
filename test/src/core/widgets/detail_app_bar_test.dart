import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/packages/theme/app_themes.dart';
import 'package:hzn_laundry/src/core/widgets/detail_app_bar.dart';

void main() {
  Widget host(PreferredSizeWidget appBar, {Widget? body}) => MaterialApp(
        theme: AppThemes.dark().data,
        home: Scaffold(appBar: appBar, body: body ?? const SizedBox()),
      );

  testWidgets('shows title + subtitle and only Edit + overflow actions',
      (tester) async {
    await tester.pumpWidget(host(
      DetailAppBar(
        title: 'Alice Reyes',
        subtitle: 'Admin',
        onEdit: () {},
        onRefresh: () {},
        menuItems: const [
          DetailMenuItem(
            value: 'delete',
            label: 'Delete',
            icon: Icons.delete,
            destructive: true,
          ),
        ],
        onMenuSelected: (_) {},
      ),
    ));

    expect(find.text('Alice Reyes'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    // Refresh is not a top-level action anymore.
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);
  });

  testWidgets('overflow menu routes Refresh and custom items', (tester) async {
    var refreshed = 0;
    String? selected;

    await tester.pumpWidget(host(
      DetailAppBar(
        title: 'Alice',
        onRefresh: () => refreshed++,
        menuItems: const [
          DetailMenuItem(value: 'delete', label: 'Delete', icon: Icons.delete),
        ],
        onMenuSelected: (v) => selected = v,
      ),
    ));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Refresh'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(refreshed, 1);
    expect(selected, isNull);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(selected, 'delete');
  });

  testWidgets('no menu button when there is nothing to put in it',
      (tester) async {
    await tester.pumpWidget(host(const DetailAppBar(title: 'Alice')));
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('up to 3 tabs fill the width; 4+ scroll', (tester) async {
    Future<TabBar> pumpTabs(int n) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppThemes.dark().data,
        home: DefaultTabController(
          length: n,
          child: Builder(
            builder: (context) => Scaffold(
              appBar: DetailAppBar(
                title: 'X',
                tabController: DefaultTabController.of(context),
                tabs: [for (var i = 0; i < n; i++) Tab(text: 'T$i')],
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      ));
      return tester.widget<TabBar>(find.byType(TabBar));
    }

    final three = await pumpTabs(3);
    expect(three.isScrollable, isFalse);
    expect(three.tabAlignment, TabAlignment.fill);

    final four = await pumpTabs(DetailAppBar.maxFillTabs + 1);
    expect(four.isScrollable, isTrue);
    expect(four.tabAlignment, TabAlignment.start);
  });

  testWidgets('preferredSize grows only when tabs are present', (tester) async {
    const plain = DetailAppBar(title: 'X');
    const tabbed = DetailAppBar(title: 'X', tabs: [Tab(text: 'A')]);
    expect(plain.preferredSize.height, kToolbarHeight);
    expect(tabbed.preferredSize.height, kToolbarHeight + kTextTabBarHeight);
  });
}
