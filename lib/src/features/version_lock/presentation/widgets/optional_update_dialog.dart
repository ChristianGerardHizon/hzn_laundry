import 'package:flutter/material.dart';

import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../domain/version_check_result.dart';
import 'apk_download_button.dart';

/// Shows a dismissable dialog prompting the user to update.
///
/// Used when the app version is below the latest but still above the minimum.
Future<void> showOptionalUpdateDialog(
  BuildContext context,
  VersionCheckResult result,
) {
  return showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    fullScreen: true,
    barrierDismissible: true,
    builder: (context) => _OptionalUpdateContent(result: result),
  );
}

class _OptionalUpdateContent extends StatelessWidget {
  const _OptionalUpdateContent({required this.result});

  final VersionCheckResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.system_update,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Update Available',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A new version of the app is available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (result.latestVersion != null) ...[
              const SizedBox(height: 8),
              Text(
                'Latest version: ${result.latestVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Later'),
                ),
                const SizedBox(width: 8),
                if (result.latestVersion != null)
                  ApkDownloadButton(latestVersion: result.latestVersion!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
