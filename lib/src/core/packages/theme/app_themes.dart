import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

/// App theme definitions for light and dark modes.
///
/// Uses Material 3 with seed-based color schemes plus shared component
/// themes tuned for dense, one-handed mobile use (flat app bars, 64dp
/// navigation bar, 16dp list gutters, hairline dividers).
class AppThemes {
  AppThemes._();

  /// Light theme ID.
  static const String lightId = 'light_theme';

  /// Dark theme ID.
  static const String darkId = 'dark_theme';

  /// Default seed color for the app.
  static const Color seedColor = Colors.blue;

  /// Light theme definition.
  static AppTheme light() => AppTheme(
        id: lightId,
        description: 'Light Theme',
        data: _build(Brightness.light),
      );

  /// Dark theme definition.
  static AppTheme dark() => AppTheme(
        id: darkId,
        description: 'Dark Theme',
        data: _build(Brightness.dark),
      );

  /// All available themes.
  static List<AppTheme> get all => [light(), dark()];

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = base.textTheme;

    return base.copyWith(
      // Flat app bar that shares the page surface so the scope bar above it
      // and the title read as one header block.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 8,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: scheme.outlineVariant.withValues(alpha: 0.6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
    );
  }
}
