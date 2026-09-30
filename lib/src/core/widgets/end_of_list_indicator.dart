import 'package:flutter/material.dart';

/// Widget shown at the end of a paginated list.
///
/// Displays either a loading indicator (when loading more) or a quiet
/// "End of the list" footer (when all items are loaded). The footer is
/// deliberately low-key (hairlines + small text) so it never competes with
/// the list content.
class EndOfListIndicator extends StatelessWidget {
  const EndOfListIndicator({
    super.key,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    this.endMessage = 'End of the list',
    this.loadingMessage = 'Loading more...',
  });

  /// Whether more items are currently being loaded.
  final bool isLoadingMore;

  /// Whether all items have been loaded.
  final bool hasReachedEnd;

  /// Message to show when all items are loaded.
  final String endMessage;

  /// Message to show while loading.
  final String loadingMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    if (isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                loadingMessage,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      );
    }

    if (hasReachedEnd) {
      // Extra bottom padding keeps the last row clear of the FAB.
      return Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 88),
        child: Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                endMessage,
                style: theme.textTheme.labelMedium?.copyWith(color: color),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
