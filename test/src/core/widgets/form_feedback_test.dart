import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/packages/theme/feedback_colors.dart';
import 'package:hzn_laundry/src/core/widgets/form_feedback.dart';

void main() {
  ThemeData themeFor(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        ),
        useMaterial3: true,
      );

  Future<void> pumpAndShow(
    WidgetTester tester, {
    required Brightness brightness,
    required void Function(BuildContext context) show,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: themeFor(brightness),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => show(context),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
  }

  void expectSnackBarColors({
    required WidgetTester tester,
    required FeedbackColors Function(ThemeData theme) colorsOf,
    required Color rawAccent,
  }) {
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    final theme = Theme.of(tester.element(find.byType(SnackBar)));
    final colors = colorsOf(theme);

    expect(snackBar.backgroundColor, colors.background);
    expect(snackBar.backgroundColor, isNot(rawAccent));
    expect(snackBar.closeIconColor, colors.foreground);

    final message = tester.widget<Text>(find.text('Feedback message'));
    expect(message.style?.color, colors.foreground);

    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.byType(Icon).first,
      ),
    );
    expect(icon.color, colors.icon);
  }

  group('FeedbackColors', () {
    test('dark warning is a tinted surface, not raw orange', () {
      final theme = themeFor(Brightness.dark);
      final colors = FeedbackColors.warning(theme);

      expect(colors.background, isNot(Colors.orange));
      expect(colors.background, isNot(Colors.orange.shade50));
      expect(colors.foreground, Colors.orange.shade200);
      expect(colors.icon, colors.foreground);
    });

    test('light warning keeps shade50 / shade900 pair', () {
      final theme = themeFor(Brightness.light);
      final colors = FeedbackColors.warning(theme);

      expect(colors.background, Colors.orange.shade50);
      expect(colors.foreground, Colors.orange.shade900);
    });

    test('dark success and error are not raw Material accents', () {
      final theme = themeFor(Brightness.dark);

      expect(
        FeedbackColors.success(theme).background,
        isNot(Colors.green),
      );
      expect(FeedbackColors.error(theme).background, isNot(Colors.red));
      expect(
        FeedbackColors.success(theme).foreground,
        Colors.green.shade200,
      );
      expect(FeedbackColors.error(theme).foreground, Colors.red.shade200);
    });
  });

  group('feedback snackbars', () {
    testWidgets('warning uses themed colors in dark mode', (tester) async {
      await pumpAndShow(
        tester,
        brightness: Brightness.dark,
        show: (context) => showWarningSnackBar(
          context,
          message: 'Feedback message',
        ),
      );

      expectSnackBarColors(
        tester: tester,
        colorsOf: FeedbackColors.warning,
        rawAccent: Colors.orange,
      );
    });

    testWidgets('warning uses themed colors in light mode', (tester) async {
      await pumpAndShow(
        tester,
        brightness: Brightness.light,
        show: (context) => showWarningSnackBar(
          context,
          message: 'Feedback message',
        ),
      );

      expectSnackBarColors(
        tester: tester,
        colorsOf: FeedbackColors.warning,
        rawAccent: Colors.orange,
      );
    });

    testWidgets('success uses themed colors in dark mode', (tester) async {
      await pumpAndShow(
        tester,
        brightness: Brightness.dark,
        show: (context) => showSuccessSnackBar(
          context,
          message: 'Feedback message',
        ),
      );

      expectSnackBarColors(
        tester: tester,
        colorsOf: FeedbackColors.success,
        rawAccent: Colors.green,
      );
    });

    testWidgets('error uses themed colors in dark mode', (tester) async {
      await pumpAndShow(
        tester,
        brightness: Brightness.dark,
        show: (context) => showErrorSnackBar(
          context,
          message: 'Feedback message',
        ),
      );

      expectSnackBarColors(
        tester: tester,
        colorsOf: FeedbackColors.error,
        rawAccent: Colors.red,
      );
    });

    testWidgets('info uses themed colors in dark mode', (tester) async {
      await pumpAndShow(
        tester,
        brightness: Brightness.dark,
        show: (context) => showInfoSnackBar(
          context,
          message: 'Feedback message',
        ),
      );

      expectSnackBarColors(
        tester: tester,
        colorsOf: FeedbackColors.info,
        rawAccent: Colors.blue,
      );
    });
  });
}
