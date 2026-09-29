import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:hzn_laundry/src/core/foundation/failure.dart';

void main() {
  group('Failure.shouldCaptureToSentry', () {
    test('skips TimeoutException', () {
      expect(
        Failure.shouldCaptureToSentry(
          TimeoutException('Future not completed'),
        ),
        isFalse,
      );
    });

    test('skips aborted ClientException', () {
      expect(
        Failure.shouldCaptureToSentry(
          ClientException(isAbort: true, statusCode: 0),
        ),
        isFalse,
      );
    });

    test('skips 400 validation ClientException', () {
      expect(
        Failure.shouldCaptureToSentry(
          ClientException(
            statusCode: 400,
            response: {
              'message': 'Failed to update record.',
              'data': {
                'email': {'code': 'validation_required', 'message': 'Cannot be blank.'},
              },
            },
          ),
        ),
        isFalse,
      );
    });

    test('skips invalid OTP ClientException', () {
      expect(
        Failure.shouldCaptureToSentry(
          ClientException(
            statusCode: 400,
            response: {'message': 'Invalid or expired OTP.', 'data': {}},
          ),
        ),
        isFalse,
      );
    });

    test('captures 504 gateway ClientException', () {
      expect(
        Failure.shouldCaptureToSentry(
          ClientException(statusCode: 504, response: const {}),
        ),
        isTrue,
      );
    });

    test('captures 502 invite email ClientException', () {
      expect(
        Failure.shouldCaptureToSentry(
          ClientException(
            statusCode: 502,
            response: {'message': 'Failed to send invite email.', 'data': {}},
          ),
        ),
        isTrue,
      );
    });
  });
}
