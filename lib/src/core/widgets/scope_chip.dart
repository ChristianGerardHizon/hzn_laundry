import 'package:flutter/material.dart';

/// Height of a compact scope chip (organization / branch) in the shell bar.
const double kScopeChipHeight = 40;

/// Decoration for compact scope *controls* (things you can tap to switch).
///
/// Ghost style: transparent fill + hairline outline, so the shell bar does not
/// compete with page content. Non-compact callers keep the legacy filled look.
///
/// Pass [interactive] = false for display-only labels: in compact mode they
/// render with no outline at all so they are not mistaken for controls.
BoxDecoration scopeChipDecoration(
  ThemeData theme, {
  required bool compact,
  bool interactive = true,
}) {
  final scheme = theme.colorScheme;
  if (compact && !interactive) return const BoxDecoration();
  if (!compact) {
    return BoxDecoration(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    );
  }
  return BoxDecoration(
    borderRadius: BorderRadius.circular(kScopeChipHeight / 2),
    border: Border.all(color: scheme.outlineVariant),
  );
}
