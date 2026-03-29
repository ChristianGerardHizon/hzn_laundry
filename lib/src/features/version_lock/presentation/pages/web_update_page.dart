import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../controllers/web_reload_stub.dart'
    if (dart.library.js_interop) '../controllers/web_reload_web.dart';

/// Full-screen blocking page shown on web when a newer version is deployed.
///
/// Cannot be dismissed — the user must tap the reload button to load the
/// latest version.
class WebUpdatePage extends HookConsumerWidget {
  const WebUpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                  'New Version Available',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A new version of the app has been deployed. '
                  'Please reload to get the latest updates.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: hardReload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
