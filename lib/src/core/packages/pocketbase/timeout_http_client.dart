import 'dart:async';

import 'package:http/http.dart' as http;

/// An [http.Client] wrapper that aborts any request taking longer than
/// [timeout], surfacing an error instead of hanging forever.
class TimeoutHttpClient extends http.BaseClient {
  TimeoutHttpClient(this._inner, this.timeout);

  final http.Client _inner;
  final Duration timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(
      timeout,
      onTimeout: () {
        throw http.ClientException(
          'Request timed out after ${timeout.inSeconds}s',
          request.url,
        );
      },
    );
  }

  @override
  void close() => _inner.close();
}
