// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_gate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the splash route visible for a minimum duration after it starts.
///
/// State is `true` once [minDuration] has elapsed since [ensureStarted].
/// Router redirect stays on splash until this is true **and** auth/scope init
/// has finished (`max(3s, init)`).

@ProviderFor(SplashGate)
final splashGateProvider = SplashGateProvider._();

/// Keeps the splash route visible for a minimum duration after it starts.
///
/// State is `true` once [minDuration] has elapsed since [ensureStarted].
/// Router redirect stays on splash until this is true **and** auth/scope init
/// has finished (`max(3s, init)`).
final class SplashGateProvider extends $NotifierProvider<SplashGate, bool> {
  /// Keeps the splash route visible for a minimum duration after it starts.
  ///
  /// State is `true` once [minDuration] has elapsed since [ensureStarted].
  /// Router redirect stays on splash until this is true **and** auth/scope init
  /// has finished (`max(3s, init)`).
  SplashGateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'splashGateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$splashGateHash();

  @$internal
  @override
  SplashGate create() => SplashGate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$splashGateHash() => r'7b7420f853f7599a9f4da9b37053ea85cf767f1b';

/// Keeps the splash route visible for a minimum duration after it starts.
///
/// State is `true` once [minDuration] has elapsed since [ensureStarted].
/// Router redirect stays on splash until this is true **and** auth/scope init
/// has finished (`max(3s, init)`).

abstract class _$SplashGate extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
