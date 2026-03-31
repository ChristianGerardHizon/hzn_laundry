import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../controllers/version_check_provider.dart';
import '../widgets/apk_download_button.dart';

/// Full-screen blocking page shown when the app version is below the minimum.
///
/// Cannot be dismissed — the user must update the app to continue.
class ForceUpdatePage extends HookConsumerWidget {
  const ForceUpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(versionCheckProvider);
    final theme = Theme.of(context);

    final latestVersion = versionAsync.value?.latestVersion;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.appIconTransparent.image(
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 32),
                Text(
                  'Update Required',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A new version of the app is available. '
                  'Please update to continue.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (latestVersion != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Latest version: $latestVersion',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                if (latestVersion != null)
                  ApkDownloadButton(latestVersion: latestVersion),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
