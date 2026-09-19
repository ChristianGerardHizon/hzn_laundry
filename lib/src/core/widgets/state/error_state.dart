import 'package:flutter/material.dart';

import '../../foundation/failure.dart';

/// A standardized error state display widget.
///
/// Used when data loading fails, showing a short title, user-facing message,
/// and an optional retry button.
///
/// Example:
/// ```dart
/// ErrorState.fromError(
///   error,
///   onRetry: () => ref.read(controller.notifier).refresh(),
/// )
/// ```
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
    this.iconSize = 64,
  });

  /// Builds from any thrown/[Failure] value using [Failure.displayErrorMessage].
  factory ErrorState.fromError(
    Object error, {
    Key? key,
    String title = 'Something went wrong',
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
    IconData icon = Icons.error_outline,
    double iconSize = 64,
  }) {
    return ErrorState(
      key: key,
      title: title,
      message: Failure.displayErrorMessage(error),
      onRetry: onRetry,
      retryLabel: retryLabel,
      icon: icon,
      iconSize: iconSize,
    );
  }

  /// Short headline above the body message.
  final String title;

  /// The user-facing error message to display.
  final String message;

  /// Callback when retry button is pressed. If null, no retry button is shown.
  final VoidCallback? onRetry;

  /// Label for the retry button. Defaults to 'Retry'.
  final String retryLabel;

  /// The error icon. Defaults to [Icons.error_outline].
  final IconData icon;

  /// Size of the error icon. Defaults to 64.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(retryLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
