import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/utils/spurious_key_event_assert.dart';

void main() {
  group('isSpuriousEmptyKeysPressedAssert', () {
    test('matches the Windows Alt Left services-library assert', () {
      final details = FlutterErrorDetails(
        exception: AssertionError(
          'Attempted to send a key down event when no keys are in keysPressed. '
          "This state can occur if the key event being sent doesn't properly "
          'set its modifier flags. This was the event: RawKeyDownEvent',
        ),
        library: 'services library',
      );

      expect(isSpuriousEmptyKeysPressedAssert(details), isTrue);
    });

    test('does not match other Flutter asserts', () {
      final details = FlutterErrorDetails(
        exception: AssertionError('RenderBox was not laid out'),
        library: 'rendering library',
      );

      expect(isSpuriousEmptyKeysPressedAssert(details), isFalse);
    });

    test('does not match non-assert errors in the services library', () {
      final details = FlutterErrorDetails(
        exception: StateError('platform channel failed'),
        library: 'services library',
      );

      expect(isSpuriousEmptyKeysPressedAssert(details), isFalse);
    });
  });

  test('install filter swallows the assert and forwards other errors', () {
    final previous = FlutterError.onError;
    addTearDown(() => FlutterError.onError = previous);

    final forwarded = <FlutterErrorDetails>[];
    FlutterError.onError = forwarded.add;
    installSpuriousKeyEventAssertFilter();

    final spurious = FlutterErrorDetails(
      exception: AssertionError(
        'Attempted to send a key down event when no keys are in keysPressed. '
        "This state can occur if the key event being sent doesn't properly "
        'set its modifier flags.',
      ),
      library: 'services library',
    );
    FlutterError.onError!(spurious);
    expect(forwarded, isEmpty);

    final other = FlutterErrorDetails(exception: StateError('boom'));
    FlutterError.onError!(other);
    expect(forwarded.single, same(other));
  });
}
