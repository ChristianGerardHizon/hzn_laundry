import 'package:pocketbase/pocketbase.dart';

import 'failure.dart';

/// True when [error] is a permission/not-found response that will not fix
/// itself by retrying (403 / 401 / 404).
bool isNonRetryableError(Object error) {
  if (error is AuthFailure || error is NoAuthFailure) return true;
  final inner = error is Failure ? error.message : error;
  if (inner is ClientException) {
    final code = inner.statusCode;
    return code == 401 || code == 403 || code == 404;
  }
  return false;
}

/// Riverpod `retry` callback: never retry forbidden / not-found responses,
/// otherwise back off (200ms doubling, capped at 6.4s) for up to 5 attempts.
Duration? retryUnlessForbidden(int retryCount, Object error) {
  if (isNonRetryableError(error) || retryCount >= 5) return null;
  final ms = 200 * (1 << retryCount);
  return Duration(milliseconds: ms > 6400 ? 6400 : ms);
}
