import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../controllers/play_store_update_provider.dart';
import '../controllers/version_check_provider.dart';

/// Full-screen blocking page shown when the app version is below the minimum.
///
/// Cannot be dismissed — the user must update the app to continue.
/// Android-only: the minimum-version lockout only redirects here on Android
/// (or web, which uses [WebUpdatePage] instead), so the update action always
/// goes through Google Play's native In-App Update flow.
class ForceUpdatePage extends HookConsumerWidget {
  const ForceUpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(versionCheckProvider);
    final theme = Theme.of(context);
    final isUpdating = useState(false);

    final latestVersion = versionAsync.value?.latestVersion;

    Future<void> handleUpdate() async {
      isUpdating.value = true;
      await ref
          .read(playStoreUpdateProvider.notifier)
          .performImmediateUpdateOrFallback();
      isUpdating.value = false;
    }

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
                FilledButton.icon(
                  onPressed: isUpdating.value ? null : handleUpdate,
                  icon: isUpdating.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.system_update),
                  label: const Text('Update Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
