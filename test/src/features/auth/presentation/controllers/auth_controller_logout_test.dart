import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/foundation/type_defs.dart';
import 'package:hzn_laundry/src/core/packages/storage/secure_storage_provider.dart';
import 'package:hzn_laundry/src/features/auth/data/auth_repository.dart';
import 'package:hzn_laundry/src/features/auth/domain/auth_state.dart';
import 'package:hzn_laundry/src/features/auth/domain/user.dart';
import 'package:hzn_laundry/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/controllers/current_organization_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const auth = AuthState(
    token: 'token',
    user: User(id: 'user-1', name: 'Test', email: 'test@example.com'),
  );

  test(
    'logout completes and clears auth even when org storage delete hangs',
    () async {
      final storage = _HangingSecureStorage();
      final repo = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(repo),
          authControllerProvider.overrideWith(() => _LoggedInAuthController(auth)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      expect(container.read(authControllerProvider).value, isNotNull);

      // Leave switch overlay active to assert logout clears it.
      unawaited(
        container.read(organizationSwitchOverlayProvider.notifier).run(
              name: 'Acme',
              action: () => Completer<void>().future,
            ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(container.read(organizationSwitchOverlayProvider).active, isTrue);

      await container.read(authControllerProvider.notifier).logout().timeout(
            const Duration(seconds: 2),
            onTimeout: () => fail('logout hung waiting on storage delete'),
          );

      expect(repo.logoutCalled, isTrue);
      expect(container.read(authControllerProvider).value, isNull);
      expect(container.read(organizationSwitchOverlayProvider).active, isFalse);
      expect(storage.deleteStarted, isTrue);
      expect(storage.deleteCompleted, isFalse);
    },
  );
}

class _LoggedInAuthController extends AuthController {
  _LoggedInAuthController(this._initial);

  final AuthState _initial;

  @override
  Future<AuthState?> build() async => _initial;
}

class _FakeAuthRepository implements AuthRepository {
  var logoutCalled = false;

  @override
  FutureEither<AuthState> login(String email, String password) async =>
      throw UnimplementedError();

  @override
  FutureEither<AuthState> loginWithGoogle({OAuthUrlLauncher? openUrl}) async =>
      throw UnimplementedError();

  @override
  FutureEither<void> requestPasswordReset(String email) async =>
      throw UnimplementedError();

  @override
  FutureEither<void> logout() async {
    logoutCalled = true;
    return const Right(null);
  }

  @override
  FutureEither<AuthState> refresh() async => throw UnimplementedError();

  @override
  FutureEither<AuthState> initialize() async => throw UnimplementedError();

  @override
  FutureEither<String> requestOtp(String email) async =>
      throw UnimplementedError();

  @override
  FutureEither<AuthState> loginWithOtp(String otpId, String code) async =>
      throw UnimplementedError();
}

class _HangingSecureStorage extends FlutterSecureStorage {
  _HangingSecureStorage() : super();

  var deleteStarted = false;
  var deleteCompleted = false;

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    deleteStarted = true;
    return Completer<void>().future.then((_) {
      deleteCompleted = true;
    });
  }
}
