// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pocketbase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for toggling between dev and production PocketBase instances.
///
/// Stores the preference in secure storage and provides methods to toggle.

@ProviderFor(PbDebugController)
final pbDebugControllerProvider = PbDebugControllerProvider._();

/// Controller for toggling between dev and production PocketBase instances.
///
/// Stores the preference in secure storage and provides methods to toggle.
final class PbDebugControllerProvider
    extends $AsyncNotifierProvider<PbDebugController, bool> {
  /// Controller for toggling between dev and production PocketBase instances.
  ///
  /// Stores the preference in secure storage and provides methods to toggle.
  PbDebugControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pbDebugControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pbDebugControllerHash();

  @$internal
  @override
  PbDebugController create() => PbDebugController();
}

String _$pbDebugControllerHash() => r'5a7431672b4eaf881e60b270a4428df4014186db';

/// Controller for toggling between dev and production PocketBase instances.
///
/// Stores the preference in secure storage and provides methods to toggle.

abstract class _$PbDebugController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<bool>, bool>,
        AsyncValue<bool>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provides a singleton PocketBase instance.
///
/// URL comes from `--flavor` / `--dart-define=ENV` (see [AppEnvironment]).
///
/// Uses [PocketBase.reuseHTTPClient] with a platform HTTP client (Fetch on web
/// for OAuth2 realtime) and a request timeout wrapper.

@ProviderFor(pocketbase)
final pocketbaseProvider = PocketbaseProvider._();

/// Provides a singleton PocketBase instance.
///
/// URL comes from `--flavor` / `--dart-define=ENV` (see [AppEnvironment]).
///
/// Uses [PocketBase.reuseHTTPClient] with a platform HTTP client (Fetch on web
/// for OAuth2 realtime) and a request timeout wrapper.

final class PocketbaseProvider
    extends $FunctionalProvider<PocketBase, PocketBase, PocketBase>
    with $Provider<PocketBase> {
  /// Provides a singleton PocketBase instance.
  ///
  /// URL comes from `--flavor` / `--dart-define=ENV` (see [AppEnvironment]).
  ///
  /// Uses [PocketBase.reuseHTTPClient] with a platform HTTP client (Fetch on web
  /// for OAuth2 realtime) and a request timeout wrapper.
  PocketbaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pocketbaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pocketbaseHash();

  @$internal
  @override
  $ProviderElement<PocketBase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PocketBase create(Ref ref) {
    return pocketbase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PocketBase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PocketBase>(value),
    );
  }
}

String _$pocketbaseHash() => r'82c2822f7dba07d2f2814689a8122294a6a825e7';
