import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/features/auth/presentation/controllers/splash_gate_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SplashGate stays false until minDuration then becomes true', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(splashGateProvider), isFalse);

    container.read(splashGateProvider.notifier).ensureStarted();
    expect(container.read(splashGateProvider), isFalse);

    // Second call is a no-op until reset.
    container.read(splashGateProvider.notifier).ensureStarted();
    expect(container.read(splashGateProvider), isFalse);

    await Future<void>.delayed(
      SplashGate.minDuration + const Duration(milliseconds: 50),
    );
    expect(container.read(splashGateProvider), isTrue);
  });

  test('SplashGate.reset clears elapsed state for a fresh hold', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(splashGateProvider.notifier).ensureStarted();
    await Future<void>.delayed(
      SplashGate.minDuration + const Duration(milliseconds: 50),
    );
    expect(container.read(splashGateProvider), isTrue);

    container.read(splashGateProvider.notifier).reset();
    expect(container.read(splashGateProvider), isFalse);

    container.read(splashGateProvider.notifier).ensureStarted();
    expect(container.read(splashGateProvider), isFalse);

    await Future<void>.delayed(
      SplashGate.minDuration + const Duration(milliseconds: 50),
    );
    expect(container.read(splashGateProvider), isTrue);
  });
}
