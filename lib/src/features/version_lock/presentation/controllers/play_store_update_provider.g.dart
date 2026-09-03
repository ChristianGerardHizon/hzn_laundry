// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_store_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives Google Play's native In-App Updates flow.
///
/// Android-only: every method fails silently (no-op or falls back to the
/// Play Store listing) on other platforms, in debug builds, or when Play
/// Core isn't available (e.g. the app wasn't installed via the Play Store).

@ProviderFor(PlayStoreUpdate)
final playStoreUpdateProvider = PlayStoreUpdateProvider._();

/// Drives Google Play's native In-App Updates flow.
///
/// Android-only: every method fails silently (no-op or falls back to the
/// Play Store listing) on other platforms, in debug builds, or when Play
/// Core isn't available (e.g. the app wasn't installed via the Play Store).
final class PlayStoreUpdateProvider
    extends $NotifierProvider<PlayStoreUpdate, FlexibleUpdateState> {
  /// Drives Google Play's native In-App Updates flow.
  ///
  /// Android-only: every method fails silently (no-op or falls back to the
  /// Play Store listing) on other platforms, in debug builds, or when Play
  /// Core isn't available (e.g. the app wasn't installed via the Play Store).
  PlayStoreUpdateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'playStoreUpdateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playStoreUpdateHash();

  @$internal
  @override
  PlayStoreUpdate create() => PlayStoreUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlexibleUpdateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlexibleUpdateState>(value),
    );
  }
}

String _$playStoreUpdateHash() => r'65b5274a996248400aeb437cd22a4f954c491326';

/// Drives Google Play's native In-App Updates flow.
///
/// Android-only: every method fails silently (no-op or falls back to the
/// Play Store listing) on other platforms, in debug builds, or when Play
/// Core isn't available (e.g. the app wasn't installed via the Play Store).

abstract class _$PlayStoreUpdate extends $Notifier<FlexibleUpdateState> {
  FlexibleUpdateState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FlexibleUpdateState, FlexibleUpdateState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FlexibleUpdateState, FlexibleUpdateState>,
        FlexibleUpdateState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
