import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/sentry/sentry_breadcrumbs.dart';
import '../../../../core/routing/pending_redirect_provider.dart';
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
    // Try to initialize from stored auth on app startup
    final result = await _repository.initialize();

    return result.fold(
      (failure) => null, // No valid auth, return null
      (authState) => authState,
    );
  }

  /// Attempts to login with username and password.
  ///
  /// Returns true on success, false on failure.
  Future<bool> login(String username, String password) async {
    addBreadcrumb('Login attempt', category: 'auth', data: {'username': username});
    state = const AsyncLoading();

    final result = await _repository.login(username, password);

    return result.fold(
      (failure) {
        addBreadcrumb('Login failed', category: 'auth', data: {'username': username});
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (authState) async {
        addBreadcrumb('Login success', category: 'auth', data: {
          'userId': authState.user.id,
          'username': username,
        });
        state = AsyncData(authState);
        return true;
      },
    );
  }

  /// Logs out the current user.
  Future<void> logout() async {
    addBreadcrumb('Logout', category: 'auth');
    // Clear pending redirect to prevent unexpected navigation on next login
    ref.read(pendingRedirectProvider.notifier).consume();
    await _repository.logout();
    state = const AsyncData(null);
  }

  /// Refreshes the current authentication token.
  ///
  /// Returns true on success, false on failure.
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
