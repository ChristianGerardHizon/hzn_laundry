import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/foundation/failure.dart';
import '../../../core/foundation/type_defs.dart';
import '../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../core/packages/storage/auth_storage_provider.dart';
import '../domain/auth_state.dart';
import 'auth_dto.dart';
import 'oauth_url_launcher.dart';
import 'oauth_web_login.dart';

part 'auth_repository.g.dart';

/// Opens an OAuth vendor URL (browser popup/tab on web, Custom Tab on Android).
typedef OAuthUrlLauncher = Future<bool> Function(Uri url);

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Attempts to login with email and password.
  FutureEither<AuthState> login(String email, String password);

  /// Attempts Google OAuth2 login (web/Android; existing user email must match).
  FutureEither<AuthState> loginWithGoogle({OAuthUrlLauncher? openUrl});

  /// Sends a password-reset email.
  FutureEither<void> requestPasswordReset(String email);

  /// Logs out the current user.
  FutureEither<void> logout();

  /// Refreshes the current authentication token.
  FutureEither<AuthState> refresh();

  /// Initializes auth state from storage on app startup.
  FutureEither<AuthState> initialize();

  /// Requests an email OTP for passwordless login. Returns the OTP id.
  FutureEither<String> requestOtp(String email);

  /// Logs in with an email OTP id and the code from the email.
  FutureEither<AuthState> loginWithOtp(String otpId, String code);
}

/// Provides the auth repository instance.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    pb: ref.watch(pocketbaseProvider),
    authStorage: ref.read(authStorageProvider),
  );
}

/// Implementation of [AuthRepository] using PocketBase.
class AuthRepositoryImpl implements AuthRepository {
  final PocketBase pb;
  final AuthStorageService authStorage;

  AuthRepositoryImpl({
    required this.pb,
    required this.authStorage,
  });

  RecordService get _collection => pb.collection(PocketBaseCollections.users);
  String get _expand => 'branch';

  /// Creates an AuthState from an AuthDto.
  AuthState _createAuthState(AuthDto dto) {
    final user = dto.toUser(domain: pb.baseURL);
    return AuthState(token: dto.token, user: user);
  }

  Future<void> _persistAuth(AuthDto authDto) async {
    await authStorage.save(authDto);
    pb.authStore.save(authDto.token, authDto.toRecordModel());
  }

  @override
  FutureEither<AuthState> login(String email, String password) async {
    return TaskEither.tryCatch(
      () async {
        final identity = email.trim().toLowerCase();

        pb.authStore.clear();

        final result = await _collection.authWithPassword(
          identity,
          password,
          expand: _expand,
        );

        final authDto = AuthDto.fromAuthResult(result);
        await _persistAuth(authDto);
        return _createAuthState(authDto);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<AuthState> loginWithGoogle({OAuthUrlLauncher? openUrl}) async {
    return TaskEither.tryCatch(() async {
      // Avoid linking Google to a stale leftover session.
      pb.authStore.clear();

      // Web: manual code exchange + custom oauth2-redirect.html (auto-close UX).
      // Android: PocketBase all-in-one + partial Custom Tab.
      if (kIsWeb) {
        final result = await loginWithGoogleWeb(pb: pb, expand: _expand);
        final authDto = AuthDto.fromAuthResult(result);
        await _persistAuth(authDto);
        return _createAuthState(authDto);
      }

      try {
        final result = await _collection.authWithOAuth2(
          'google',
          (url) async {
            final launcher = openUrl ?? launchOAuthVendorUrl;
            final opened = await launcher(url);
            if (!opened) {
              throw const AuthFailure(
                'Could not open Google sign-in',
                null,
                'google_launch_failed',
              );
            }
          },
          expand: _expand,
        );

        final authDto = AuthDto.fromAuthResult(result);
        await _persistAuth(authDto);
        return _createAuthState(authDto);
      } finally {
        // Return from the Android Custom Tab whether auth succeeded or failed.
        await closeOAuthBrowser();
      }
    }, Failure.handle).run();
  }

  @override
  FutureEither<void> requestPasswordReset(String email) async {
    return TaskEither.tryCatch(
      () async {
        await _collection.requestPasswordReset(email.trim().toLowerCase());
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> logout() async {
    return TaskEither.tryCatch(
      () async {
        pb.authStore.clear();
        await authStorage.clear();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<AuthState> refresh() async {
    return TaskEither.tryCatch(
      () async {
        final result = await _collection.authRefresh(expand: _expand);

        final authDto = AuthDto.fromAuthResult(result);
        await _persistAuth(authDto);
        return _createAuthState(authDto);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<AuthState> initialize() async {
    return TaskEither.tryCatch(
      () async {
        final savedAuth = await authStorage.get();
        if (savedAuth == null) {
          throw const NoAuthFailure('No saved authentication', null, 'no_auth');
        }

        pb.authStore.save(savedAuth.token, savedAuth.toRecordModel());

        final result = await _collection.authRefresh(expand: _expand);

        final authDto = AuthDto.fromAuthResult(result);
        await authStorage.save(authDto);
        return _createAuthState(authDto);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<String> requestOtp(String email) async {
    return TaskEither.tryCatch(() async {
      final response =
          await _collection.requestOTP(email.trim().toLowerCase());
      final otpId = response.otpId;
      if (otpId.isEmpty) {
        throw const AuthFailure(
          'Could not send login code',
          null,
          'otp_request_failed',
        );
      }
      return otpId;
    }, (error, stackTrace) {
      if (error is ClientException) {
        final message = error.response['message']?.toString() ?? '';
        if (error.statusCode == 400 &&
            message.toLowerCase().contains('no account')) {
          return AuthFailure(error, stackTrace, 'otp_no_account');
        }
      }
      return Failure.handle(error, stackTrace);
    }).run();
  }

  @override
  FutureEither<AuthState> loginWithOtp(String otpId, String code) async {
    return TaskEither.tryCatch(() async {
      final result = await _collection.authWithOTP(
        otpId,
        code,
        expand: _expand,
      );

      final authDto = AuthDto.fromAuthResult(result);
      await _persistAuth(authDto);
      return _createAuthState(authDto);
    }, (error, stackTrace) {
      final failure = Failure.handle(error, stackTrace);
      if (failure.messageString.toLowerCase().contains('otp')) {
        return AuthFailure(error, stackTrace, 'otp_invalid');
      }
      return failure;
    }).run();
  }
}
