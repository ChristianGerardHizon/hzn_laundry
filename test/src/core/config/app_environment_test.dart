import 'package:flutter_test/flutter_test.dart';
import 'package:hizonelaundry/src/core/config/app_environment.dart';

void main() {
  group('AppEnvironment.resolve', () {
    test('ENV takes priority over flavor', () {
      final env = AppEnvironment.resolve(
        env: 'staging',
        flavor: 'prod',
        isDebug: true,
      );
      expect(env, AppEnvironment.staging);
      expect(env.pocketBaseUrl, PocketBaseUrls.staging);
    });

    test('flavor is used when ENV is empty', () {
      final env = AppEnvironment.resolve(
        env: '',
        flavor: 'staging',
        isDebug: true,
      );
      expect(env, AppEnvironment.staging);
      expect(env.appTitle, 'Hi-Zone Laundry [Stg]');
    });

    test('dev flavor uses local PocketBase', () {
      final env = AppEnvironment.resolve(
        env: '',
        flavor: 'dev',
        isDebug: false,
      );
      expect(env, AppEnvironment.dev);
      expect(env.pocketBaseUrl, PocketBaseUrls.dev);
      expect(env.appTitle, 'Hi-Zone Laundry [Dev]');
    });

    test('prod flavor uses production URL and unadorned title', () {
      final env = AppEnvironment.resolve(
        env: '',
        flavor: 'prod',
        isDebug: true,
      );
      expect(env, AppEnvironment.prod);
      expect(env.pocketBaseUrl, PocketBaseUrls.prod);
      expect(env.appTitle, 'Hi-Zone Laundry');
    });

    test('debug fallback is dev when ENV and flavor are empty', () {
      final env = AppEnvironment.resolve(
        env: '',
        flavor: '',
        isDebug: true,
      );
      expect(env, AppEnvironment.dev);
    });

    test('release fallback is prod when ENV and flavor are empty', () {
      final env = AppEnvironment.resolve(
        env: '',
        flavor: '',
        isDebug: false,
      );
      expect(env, AppEnvironment.prod);
    });
  });
}
