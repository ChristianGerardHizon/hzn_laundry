import 'package:flutter/material.dart';

/// Semantic surface/on-surface pairs for success, error, warning, and info UI.
///
/// Uses Material 3 container-style tinting: a tinted surface with contrasting
/// on-container text. Dark mode blends the accent onto [ColorScheme.surface]
/// so snackbars stay opaque. Does not use inverted seed colors such as
/// [ColorScheme.error] in dark mode (those are light reds meant for buttons).
class FeedbackColors {
  const FeedbackColors({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  /// Opaque container fill.
  final Color background;

  /// Text, close icon, and other on-container content.
  final Color foreground;

  /// Leading glyph; matches [foreground] so icons and copy cannot diverge.
  final Color icon;

  static const double _darkBlendAlpha = 0.24;

  static FeedbackColors error(ThemeData theme) =>
      _fromAccent(theme, Colors.red);

  static FeedbackColors warning(ThemeData theme) =>
      _fromAccent(theme, Colors.orange);

  static FeedbackColors success(ThemeData theme) =>
      _fromAccent(theme, Colors.green);

  static FeedbackColors info(ThemeData theme) =>
      _fromAccent(theme, Colors.blue);

  static FeedbackColors _fromAccent(ThemeData theme, MaterialColor accent) {
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      final onContainer = accent.shade200;
      return FeedbackColors(
        background: Color.alphaBlend(
          accent.withValues(alpha: _darkBlendAlpha),
          theme.colorScheme.surface,
        ),
        foreground: onContainer,
        icon: onContainer,
      );
    }
    return FeedbackColors(
      background: accent.shade50,
      foreground: accent.shade900,
      icon: accent.shade900,
    );
  }
}
