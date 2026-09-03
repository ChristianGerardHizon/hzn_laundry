import 'package:flutter/foundation.dart';

/// PocketBase backend URLs per flavor.
abstract class PocketBaseUrls {
  static const String dev = 'http://127.0.0.1:8090';
  static const String staging = 'https://staging.hznlaundry.hznsystems.com';
  static const String prod = 'https://hznlaundry.hznsystems.com';
}

/// App flavor: `dev` (local testing), `staging`, or `prod`.
///
/// Resolution order:
/// 1. `--dart-define=ENV=` (web, Windows, Linux, and CI)
/// 2. `--flavor` / `FLUTTER_APP_FLAVOR` (Android, iOS, macOS)
/// 3. Debug builds fall back to `dev`; release builds fall back to `prod`
class AppEnvironment {
  const AppEnvironment._(this.name);

  final String name;

  static const dev = AppEnvironment._('dev');
  static const staging = AppEnvironment._('staging');
  static const prod = AppEnvironment._('prod');

  /// `--dart-define=ENV=<value>`
  static const String envDefine = String.fromEnvironment(
    'ENV',
    defaultValue: '',
  );

  /// Injected by Flutter when running with `--flavor`.
  static const String flavorDefine = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: '',
  );

  /// Optional URL override via `--dart-define=API_URL=<url>`.
  static const String apiUrlOverride = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  static AppEnvironment fromName(String raw) {
    switch (raw) {
      case 'staging':
        return staging;
      case 'dev':
        return dev;
      default:
        return prod;
    }
  }

  static AppEnvironment resolve({
    String env = envDefine,
    String flavor = flavorDefine,
    bool? isDebug,
  }) {
    final raw = env.isNotEmpty
        ? env
        : flavor.isNotEmpty
            ? flavor
            : ((isDebug ?? kDebugMode) ? 'dev' : 'prod');
    return fromName(raw);
  }

  static final AppEnvironment current = resolve();

  @override
  bool operator ==(Object other) =>
      other is AppEnvironment && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'AppEnvironment($name)';

  String get pocketBaseUrl => switch (name) {
        'dev' => PocketBaseUrls.dev,
        'staging' => PocketBaseUrls.staging,
        _ => PocketBaseUrls.prod,
      };

  String get appTitle => switch (name) {
        'dev' => 'HZN Laundry [Dev]',
        'staging' => 'HZN Laundry [Stg]',
        _ => 'HZN Laundry',
      };
}

/// Resolves the PocketBase URL.
/// Priority: API_URL override > ENV / flavor > debug/release fallback.
String get pocketbaseUrl {
  if (AppEnvironment.apiUrlOverride.isNotEmpty) {
    return AppEnvironment.apiUrlOverride;
  }
  return AppEnvironment.current.pocketBaseUrl;
}

/// Current environment name for display, logging, and Sentry.
String get currentEnvironment => AppEnvironment.current.name;

/// Window / task-switcher title for the current flavor.
String get appTitle => AppEnvironment.current.appTitle;
