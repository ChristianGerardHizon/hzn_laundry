import 'package:flutter/material.dart';

import 'system_nav_panel.dart';

/// Empty state shown when no item is selected in tablet layout.
class EmptySystemState extends StatelessWidget {
  const EmptySystemState({
    super.key,
    required this.mode,
  });

  /// Current system mode to determine the message.
  final SystemMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, title, subtitle) = switch (mode) {
      SystemMode.printers => (
          Icons.print_outlined,
          'Select a printer',
          'Choose a printer from the list to view and configure',
        ),
      SystemMode.appearance => (
          Icons.palette_outlined,
          'Appearance',
          'Customize app theme and colors',
        ),
    };

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
