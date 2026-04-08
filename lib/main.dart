import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hizonelaundry/src/core/packages/pocketbase/pocketbase_provider.dart';
import 'package:hizonelaundry/src/core/utils/window_utils.dart';
import 'package:hizonelaundry/src/application.dart';
import 'package:hizonelaundry/src/core/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/core/packages/sentry/sentry_provider_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowUtils.register();
  LocaleSettings.useDeviceLocale();

  final app = ProviderScope(
    observers: [SentryProviderObserver()],
    child: TranslationProvider(child: Application()),
  );

  // Only enable Sentry in release mode (staging & prod)
  if (kReleaseMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://8f474a193a284778a787192bf9f35665@o418473.ingest.us.sentry.io/4511186534006784';
        options.environment = currentEnvironment;
        options.tracesSampleRate = currentEnvironment == 'prod' ? 0.2 : 1.0;
        // ignore: experimental_member_use
        options.profilesSampleRate = currentEnvironment == 'prod' ? 0.2 : 1.0;

        // Session replays
        options.replay.sessionSampleRate =
            currentEnvironment == 'prod' ? 0.1 : 1.0;
        options.replay.onErrorSampleRate = 1.0;

        // Structured logs
        options.enableLogs = true;
      },
      appRunner: () => runApp(
        DefaultAssetBundle(
          bundle: SentryAssetBundle(),
          child: app,
        ),
      ),
    );
  } else {
    runApp(app);
  }
}
