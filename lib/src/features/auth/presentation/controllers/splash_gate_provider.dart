import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_gate_provider.g.dart';

/// Keeps the splash route visible for a minimum duration after it starts.
///
/// State is `true` once [minDuration] has elapsed since [ensureStarted].
/// Router redirect stays on splash until this is true **and** auth/scope init
/// has finished (`max(3s, init)`).
@Riverpod(keepAlive: true)
class SplashGate extends _$SplashGate {
  static const minDuration = Duration(seconds: 3);

  Timer? _timer;
  bool _started = false;

  @override
  bool build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    return false;
  }

  /// Starts the minimum-duration timer once per splash session.
  void ensureStarted() {
    if (_started) return;
    _started = true;
    _timer = Timer(minDuration, () {
      state = true;
    });
  }

  /// Clears the timer so the next splash visit gets a full [minDuration].
  void reset() {
    _timer?.cancel();
    _timer = null;
    _started = false;
    state = false;
  }

  bool get isMinDurationElapsed => state;
}
