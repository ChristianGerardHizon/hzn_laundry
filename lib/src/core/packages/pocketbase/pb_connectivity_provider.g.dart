// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pb_connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Polls PocketBase `/api/health` to determine server reachability quality.
///
/// - [PbConnectionStatus.online] — reachable and latency below [_poorThreshold]
/// - [PbConnectionStatus.poor] — reachable but slow
/// - [PbConnectionStatus.offline] — unreachable or timed out
///
/// Polls every 15s while reachable and every 5s while offline for faster recovery.

@ProviderFor(PbConnectivity)
final pbConnectivityProvider = PbConnectivityProvider._();

/// Polls PocketBase `/api/health` to determine server reachability quality.
///
/// - [PbConnectionStatus.online] — reachable and latency below [_poorThreshold]
/// - [PbConnectionStatus.poor] — reachable but slow
/// - [PbConnectionStatus.offline] — unreachable or timed out
///
/// Polls every 15s while reachable and every 5s while offline for faster recovery.
final class PbConnectivityProvider
    extends $AsyncNotifierProvider<PbConnectivity, PbHealthSnapshot> {
  /// Polls PocketBase `/api/health` to determine server reachability quality.
  ///
  /// - [PbConnectionStatus.online] — reachable and latency below [_poorThreshold]
  /// - [PbConnectionStatus.poor] — reachable but slow
  /// - [PbConnectionStatus.offline] — unreachable or timed out
  ///
  /// Polls every 15s while reachable and every 5s while offline for faster recovery.
  PbConnectivityProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pbConnectivityProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pbConnectivityHash();

  @$internal
  @override
  PbConnectivity create() => PbConnectivity();
}

String _$pbConnectivityHash() => r'4fd2527d7a16e043b3b036062c3be9ea3c928937';

/// Polls PocketBase `/api/health` to determine server reachability quality.
///
/// - [PbConnectionStatus.online] — reachable and latency below [_poorThreshold]
/// - [PbConnectionStatus.poor] — reachable but slow
/// - [PbConnectionStatus.offline] — unreachable or timed out
///
/// Polls every 15s while reachable and every 5s while offline for faster recovery.

abstract class _$PbConnectivity extends $AsyncNotifier<PbHealthSnapshot> {
  FutureOr<PbHealthSnapshot> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PbHealthSnapshot>, PbHealthSnapshot>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PbHealthSnapshot>, PbHealthSnapshot>,
        AsyncValue<PbHealthSnapshot>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
