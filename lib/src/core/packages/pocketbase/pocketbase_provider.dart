import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/app_environment.dart';
import '../../constants/constants.dart';
import '../storage/secure_storage_provider.dart';
import 'pocketbase_http_client.dart';
import 'timeout_http_client.dart';

export '../../config/app_environment.dart'
    show
        PocketBaseUrls,
        AppEnvironment,
        pocketbaseUrl,
        currentEnvironment,
        appTitle;

part 'pocketbase_provider.g.dart';

/// Controller for toggling between dev and production PocketBase instances.
///
/// Stores the preference in secure storage and provides methods to toggle.
@Riverpod(keepAlive: true)
class PbDebugController extends _$PbDebugController {
  static const _key = 'pb_debug_mode';

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  Future<bool> build() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  /// Toggle between dev and production mode.
  Future<void> toggle() async {
    final current = state.value ?? false;
    await _storage.write(key: _key, value: (!current).toString());
    ref.invalidateSelf();
  }

  /// Get the current debug mode value.
  Future<bool> get() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }
}

/// Provides a singleton PocketBase instance.
///
/// URL comes from `--flavor` / `--dart-define=ENV` (see [AppEnvironment]).
///
/// Uses [PocketBase.reuseHTTPClient] with a platform HTTP client (Fetch on web
/// for OAuth2 realtime) and a request timeout wrapper.
@Riverpod(keepAlive: true)
PocketBase pocketbase(Ref ref) {
  final pb = PocketBase(
    pocketbaseUrl,
    reuseHTTPClient: true,
    httpClientFactory: () => TimeoutHttpClient(
      createPocketBaseHttpClient(),
      ApiConstants.requestTimeout,
    ),
  );
  ref.onDispose(pb.close);
  return pb;
}
