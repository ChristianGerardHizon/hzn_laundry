import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/packages/theme/app_themes.dart';
import 'package:hzn_laundry/src/core/widgets/list/list.dart';

void main() {
  Widget wrap(Widget child, {ThemeData? theme}) => MaterialApp(
        theme: theme ?? AppThemes.dark().data,
        home: Scaffold(body: child),
      );

  group('AppListRow', () {
    testWidgets('renders title, subtitle, trailing and forwards taps',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(
        AppListRow(
          title: const Text('Alice'),
          subtitle: const Text('alice@example.com'),
          trailing: const Text('Admin'),
          onTap: () => taps++,
        ),
      ));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);

      await tester.tap(find.text('Alice'));
      expect(taps, 1);
    });

    testWidgets('selected row uses secondaryContainer', (tester) async {
      final theme = AppThemes.dark().data;
      await tester.pumpWidget(wrap(
        const AppListRow(title: Text('Alice'), isSelected: true),
        theme: theme,
      ));

      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.selected, isTrue);
      expect(tile.selectedTileColor, theme.colorScheme.secondaryContainer);
    });

    testWidgets('row is at least 48dp tall (touch target)', (tester) async {
      await tester.pumpWidget(wrap(
        const AppListRow(title: Text('Alice')),
      ));
      expect(
        tester.getSize(find.byType(ListTile)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('RowChip', () {
    testWidgets('neutral chip shows label without a status dot',
        (tester) async {
      await tester.pumpWidget(wrap(const RowChip(label: 'Admin')));
      expect(find.text('Admin'), findsOneWidget);
      expect(find.byType(DecoratedBox), findsWidgets);
    });

    testWidgets('label keeps >= 4.5:1 contrast when tinted (dark + light)',
        (tester) async {
      for (final theme in [AppThemes.dark().data, AppThemes.light().data]) {
        await tester.pumpWidget(wrap(
          const RowChip(label: 'Paid', color: Colors.green),
          theme: theme,
        ));

        final text = tester.widget<Text>(find.text('Paid'));
        final container = tester
            .widgetList<Container>(find.byType(Container))
            .firstWhere((c) {
          final d = c.decoration;
          return d is BoxDecoration && d.borderRadius != null;
        });
        final bg = (container.decoration! as BoxDecoration).color!;
        final fg = text.style!.color!;

        double lum(Color c) => c.computeLuminance();
        final l1 = lum(bg) > lum(fg) ? lum(bg) : lum(fg);
        final l2 = lum(bg) > lum(fg) ? lum(fg) : lum(bg);
        final ratio = (l1 + 0.05) / (l2 + 0.05);

        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'brightness ${theme.brightness}');
      }
    });
  });
}
