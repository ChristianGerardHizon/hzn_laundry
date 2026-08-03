import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pocketbase_provider.dart';

part 'pb_connectivity_provider.g.dart';

/// PocketBase server reachability quality based on `/api/health` latency.
enum PbConnectionStatus {
  /// Health check succeeded with acceptable latency.
  online,

  /// Health check succeeded but response was slow.
  poor,

  /// Health check failed or timed out.
  offline,
}

extension PbConnectionStatusX on PbConnectionStatus {
  bool get isReachable =>
      this == PbConnectionStatus.online || this == PbConnectionStatus.poor;
}

/// Result of a PocketBase health poll, including measured latency.
class PbHealthSnapshot {
  const PbHealthSnapshot({
    required this.status,
    this.latency,
  });

  final PbConnectionStatus status;

  /// Round-trip time of the last successful health check, if any.
  final Duration? latency;

  bool get isOnline => status.isReachable;
}

/// Polls PocketBase `/api/health` to determine server reachability quality.
///
/// - [PbConnectionStatus.online] — reachable and latency below [_poorThreshold]
/// - [PbConnectionStatus.poor] — reachable but slow
/// - [PbConnectionStatus.offline] — unreachable or timed out
///
/// Polls every 15s while reachable and every 5s while offline for faster recovery.
@Riverpod(keepAlive: true)
class PbConnectivity extends _$PbConnectivity {
  static const _onlineInterval = Duration(seconds: 15);
  static const _offlineInterval = Duration(seconds: 5);
  static const _requestTimeout = Duration(seconds: 5);

  /// Responses at or above this latency are reported as [PbConnectionStatus.poor].
  static const _poorThreshold = Duration(milliseconds: 1000);

  Timer? _timer;

  /// First successful check skips the poor-latency classification — Dart HTTP
  /// cold-start plus competing app boot requests often push RTT over 1s even
  /// when talking to a local PocketBase that answers in milliseconds.
  var _warmupDone = false;

  @override
  Future<PbHealthSnapshot> build() async {
    ref.onDispose(() => _timer?.cancel());
    _warmupDone = false;

    final snapshot = await _checkHealth();
    _scheduleNext(snapshot.status);
    return snapshot;
  }

  /// Forces an immediate health check and reschedules the poll timer.
  Future<void> checkNow() async {
    final snapshot = await _checkHealth();
    if (!ref.mounted) return;
    state = AsyncData(snapshot);
    _scheduleNext(snapshot.status);
  }

  Future<PbHealthSnapshot> _checkHealth() async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await ref
          .read(pocketbaseProvider)
          .health
          .check()
          .timeout(_requestTimeout);
      stopwatch.stop();

      if (result.code != 200) {
        return const PbHealthSnapshot(status: PbConnectionStatus.offline);
      }

      final latency = stopwatch.elapsed;
      final skipPoor = !_warmupDone;
      _warmupDone = true;

      final status = (!skipPoor && latency >= _poorThreshold)
          ? PbConnectionStatus.poor
          : PbConnectionStatus.online;
      return PbHealthSnapshot(status: status, latency: latency);
    } catch (_) {
      return const PbHealthSnapshot(status: PbConnectionStatus.offline);
    }
  }

  void _scheduleNext(PbConnectionStatus status) {
    _timer?.cancel();
    final interval =
        status == PbConnectionStatus.offline ? _offlineInterval : _onlineInterval;
    // Timer callbacks are synchronous; kick off async work explicitly.
    _timer = Timer(interval, () => unawaited(_poll()));
  }

  Future<void> _poll() async {
    final next = await _checkHealth();
    if (!ref.mounted) return;
    state = AsyncData(next);
    _scheduleNext(next.status);
  }
}
