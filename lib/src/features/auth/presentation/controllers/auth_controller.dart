import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/sentry/sentry_breadcrumbs.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../../core/routing/pending_redirect_provider.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';

part 'auth_controller.g.dart';

/// Controller for managing authentication state.
///
/// Provides methods for login, logout, and session management.
/// The state is [AuthState?] where null means not authenticated.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthState?> build() async {
    final result = await _repository.initialize();

    return result.fold(
      (failure) => null,
      (authState) => authState,
    );
  }

  /// Attempts to login with email and password.
  Future<bool> login(String email, String password) async {
    addBreadcrumb('Login attempt', category: 'auth', data: {'email': email});
    state = const AsyncLoading();

    final result = await _repository.login(email, password);

    return result.fold(
      (failure) {
        addBreadcrumb('Login failed', category: 'auth', data: {'email': email});
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (authState) async {
        addBreadcrumb('Login success', category: 'auth', data: {
          'userId': authState.user.id,
          'email': email,
        });
        state = AsyncData(authState);
        return true;
      },
    );
  }

  /// Attempts Google OAuth2 login (web / Android).
  ///
  /// Does not set [AsyncLoading] while waiting: the OAuth popup/tab can be
  /// closed by the user before the flow finishes.
  Future<bool> loginWithGoogle() async {
    addBreadcrumb('Google login attempt', category: 'auth');

    final result = await _repository.loginWithGoogle();

    return result.fold(
      (failure) {
        // User closed the popup or denied consent — leave login UI idle.
        if (failure.identifier == 'google_oauth_cancelled') {
          addBreadcrumb('Google login cancelled', category: 'auth');
          return false;
        }
        addBreadcrumb('Google login failed', category: 'auth');
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (authState) {
        addBreadcrumb('Google login success', category: 'auth', data: {
          'userId': authState.user.id,
        });
        state = AsyncData(authState);
        return true;
      },
    );
  }

  /// Logs out the current user.
  ///
  /// Clears the auth session first so redirect to login is never blocked by
  /// secure-storage I/O. Last-used org id is cleared best-effort afterward.
  Future<void> logout() async {
    addBreadcrumb('Logout', category: 'auth');
    ref.read(pendingRedirectProvider.notifier).consume();
    await _repository.logout();
    state = const AsyncData(null);
    ref.read(organizationSwitchOverlayProvider.notifier).clear();
    unawaited(_clearPersistedOrganizationId());
  }

  Future<void> _clearPersistedOrganizationId() async {
    try {
      await ref.read(secureStorageProvider).delete(
            key: currentOrganizationStorageKey,
          );
    } catch (e, st) {
      assert(() {
        debugPrint('Failed to clear persisted organization on logout: $e\n$st');
        return true;
      }());
    }
  }

  /// Refreshes the current authentication token.
  Future<bool> refresh() async {
    final result = await _repository.refresh();

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (authState) {
        state = AsyncData(authState);
        return true;
      },
    );
  }

  /// Requests an email OTP. Does not change global auth loading state.
  FutureEither<String> requestOtp(String email) {
    return _repository.requestOtp(email);
  }

  /// Logs in with an email OTP id and code.
  Future<bool> loginWithOtp(String otpId, String code) async {
    state = const AsyncLoading();

    final result = await _repository.loginWithOtp(otpId, code);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (authState) {
        state = AsyncData(authState);
        return true;
      },
    );
  }
}

/// Convenience provider to check if user is authenticated.
@Riverpod(keepAlive: true)
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.value != null;
}

/// Convenience provider to get the current user.
@Riverpod(keepAlive: true)
AuthState? currentAuth(Ref ref) {
  return ref.watch(authControllerProvider).value;
}
