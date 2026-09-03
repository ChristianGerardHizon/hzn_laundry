import 'package:flutter/foundation.dart';

/// Flutter's legacy [RawKeyboard] asserts in debug when Windows sends a
/// modifier key-down (commonly Alt Left) with `modifiers: 0`.
///
/// The key is recorded, then `_synchronizeModifiers` clears it, and the
/// assert fires. The app keeps running; this only dumps a debug error.
///
/// See https://github.com/flutter/flutter/issues/111641
void installSpuriousKeyEventAssertFilter() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (isSpuriousEmptyKeysPressedAssert(details)) {
      return;
    }
    if (previous != null) {
      previous(details);
    } else {
      FlutterError.presentError(details);
    }
  };
}

/// Whether [details] is the framework's empty-`keysPressed` modifier assert.
@visibleForTesting
bool isSpuriousEmptyKeysPressedAssert(FlutterErrorDetails details) {
  if (details.library != 'services library') return false;

  final message = details.exception is AssertionError
      ? details.exception.toString()
      : details.exceptionAsString();
  return message.contains('keysPressed') && message.contains('modifier flags');
}
