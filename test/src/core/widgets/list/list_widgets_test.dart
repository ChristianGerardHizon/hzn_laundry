import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/i18n/strings.g.dart';
import 'package:hzn_laundry/src/core/packages/theme/app_themes.dart';
import 'package:hzn_laundry/src/core/widgets/end_of_list_indicator.dart';
import 'package:hzn_laundry/src/core/widgets/list/list.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.dark}) {
    final theme = brightness == Brightness.dark
        ? AppThemes.dark().data
        : AppThemes.light().data;
    return TranslationProvider(
      child: MaterialApp(
        theme: theme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('ListToolbar', () {
    testWidgets('shows search field and filter badge only when count > 0',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(wrap(
        ListToolbar(
          controller: controller,
          onSearch: () {},
          onTextChanged: (_) {},
          onFilterPressed: () {},
          filterCount: 0,
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
      expect(find.byType(Badge), findsNothing);

      await tester.pumpWidget(wrap(
        ListToolbar(
          controller: controller,
          onSearch: () {},
          onTextChanged: (_) {},
          onFilterPressed: () {},
          filterCount: 3,
        ),
      ));
      expect(find.byType(Badge), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('submitting calls onSearch; clear button empties the field',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var searched = 0;

      await tester.pumpWidget(wrap(
        ListToolbar(
          controller: controller,
          onSearch: () => searched++,
          onTextChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.close), findsNothing);
      await tester.enterText(find.byType(TextField), 'ana');
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(searched, 1);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('active query renders a chip that clears on tap',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var cleared = 0;

      await tester.pumpWidget(wrap(
        ListToolbar(
          controller: controller,
          onSearch: () {},
          onTextChanged: (_) {},
          activeQuery: 'maria',
          onClear: () => cleared++,
        ),
      ));

      expect(find.byType(TextField), findsNothing);
      expect(find.text('"maria"'), findsOneWidget);

      await tester.tap(find.text('"maria"'));
      expect(cleared, 1);
    });

    testWidgets('toolbar actions meet the 44dp touch target', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(wrap(
        ListToolbar(
          controller: controller,
          onSearch: () {},
          onTextChanged: (_) {},
          onFilterPressed: () {},
          onSortPressed: () {},
          sortDescending: false,
        ),
      ));

      final size = tester.getSize(find.byIcon(Icons.tune).first);
      expect(size.width, greaterThan(0));
      for (final icon in [Icons.tune, Icons.arrow_upward]) {
        final button = find.ancestor(
          of: find.byIcon(icon),
          matching: find.byType(IconButton),
        );
        final box = tester.getSize(button);
        expect(box.width, greaterThanOrEqualTo(kListToolbarTarget));
        expect(box.height, greaterThanOrEqualTo(kListToolbarTarget));
      }
    });
  });

  group('ListSectionTabs', () {
    testWidgets('renders counts inline and reports selection', (tester) async {
      var selected = 'members';

      await tester.pumpWidget(wrap(
        StatefulBuilder(
          builder: (context, setState) => ListSectionTabs<String>(
            selected: selected,
            onChanged: (v) => setState(() => selected = v),
            tabs: const [
              ListSectionTab(value: 'members', label: 'Members', count: 12),
              ListSectionTab(
                value: 'invites',
                label: 'Invites',
                count: 2,
                highlightCount: true,
              ),
            ],
          ),
        ),
      ));

      expect(find.text('Members'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('Invites'));
      await tester.pump();
      expect(selected, 'invites');
    });

    testWidgets('zero highlighted count falls back to plain text',
        (tester) async {
      await tester.pumpWidget(wrap(
        ListSectionTabs<String>(
          selected: 'a',
          onChanged: (_) {},
          tabs: const [
            ListSectionTab(value: 'a', label: 'A', count: 1),
            ListSectionTab(
              value: 'b',
              label: 'B',
              count: 0,
              highlightCount: true,
            ),
          ],
        ),
      ));

      expect(find.text('0'), findsOneWidget);
    });
  });

  group('ListPanelHeader', () {
    testWidgets('shows title, count pill and optional subtitle',
        (tester) async {
      await tester.pumpWidget(wrap(
        const ListPanelHeader(title: 'Users', count: 5, subtitle: 'Hint'),
      ));
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
    });
  });

  group('EndOfListIndicator', () {
    testWidgets('end state is text only (no oversized icon)', (tester) async {
      await tester.pumpWidget(wrap(
        const EndOfListIndicator(isLoadingMore: false, hasReachedEnd: true),
      ));
      expect(find.text('End of the list'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('loading state shows a spinner', (tester) async {
      await tester.pumpWidget(wrap(
        const EndOfListIndicator(isLoadingMore: true, hasReachedEnd: false),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
