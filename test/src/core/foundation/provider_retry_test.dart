import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/foundation/failure.dart';
import 'package:hzn_laundry/src/core/foundation/provider_retry.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('retryUnlessForbidden', () {
    test('never retries auth / forbidden failures', () {
      expect(retryUnlessForbidden(0, const AuthFailure('forbidden')), isNull);
      expect(
        retryUnlessForbidden(
          0,
          ClientException(statusCode: 403, response: {'message': 'nope'}),
        ),
        isNull,
      );
      expect(
        retryUnlessForbidden(
          0,
          DataFailure(ClientException(statusCode: 404)),
        ),
        isNull,
      );
    });

    test('backs off for other errors and stops after 5 attempts', () {
      final error = StateError('boom');
      expect(retryUnlessForbidden(0, error), const Duration(milliseconds: 200));
      expect(retryUnlessForbidden(2, error), const Duration(milliseconds: 800));
      expect(retryUnlessForbidden(4, error), const Duration(milliseconds: 3200));
      expect(retryUnlessForbidden(5, error), isNull);
    });
  });
}
