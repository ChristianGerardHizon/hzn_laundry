import 'dart:async';
import 'dart:js_interop';

import 'package:pocketbase/pocketbase.dart';
import 'package:web/web.dart' as web;

import '../../../core/foundation/failure.dart';
import '../../../core/packages/pocketbase/pocketbase_collections.dart';

const _redirectMessageType = 'hzn_oauth2_redirect';
const _ackMessageType = 'hzn_oauth2_ack';

/// Manual Google OAuth2 code exchange for Flutter web.
///
/// Opens a popup (without `noopener`) to Google, receives the code via
/// `web/oauth2-redirect.html` postMessage, then calls [RecordService.authWithOAuth2Code].
Future<RecordAuth> loginWithGoogleWeb({
  required PocketBase pb,
  required String expand,
}) async {
  final collection = pb.collection(PocketBaseCollections.users);
  final methods = await collection.listAuthMethods();

  final AuthMethodProvider provider;
  try {
    provider = methods.oauth2.providers.firstWhere((p) => p.name == 'google');
  } catch (_) {
    throw const AuthFailure(
      'Google sign-in is not configured',
      null,
      'google_launch_failed',
    );
  }

  final redirectOrigin = Uri.parse(pb.baseURL).origin;
  final redirectUrl = '$redirectOrigin/oauth2-redirect.html';
  final expectedState = provider.state;

  final authUrl = Uri.parse(provider.authURL + redirectUrl);

  final popup = web.window.open(
    authUrl.toString(),
    'hzn_google_oauth',
    'popup=yes,width=500,height=700',
  );

  if (popup == null) {
    throw const AuthFailure(
      'Could not open Google sign-in',
      null,
      'google_launch_failed',
    );
  }

  final completer = Completer<RecordAuth>();
  StreamSubscription<web.MessageEvent>? messageSub;
  Timer? closedPoll;
  var handlingRedirect = false;

  void cleanup() {
    messageSub?.cancel();
    messageSub = null;
    closedPoll?.cancel();
    closedPoll = null;
  }

  void ackPopup({required bool ok, String? message}) {
    try {
      popup.postMessage(
        <String, Object?>{
          'type': _ackMessageType,
          'ok': ok,
          if (message != null) 'message': message,
        }.jsify(),
        redirectOrigin.toJS,
      );
    } catch (_) {
      // Popup may already be closed.
    }
  }

  void fail(Object error, [StackTrace? stackTrace]) {
    if (completer.isCompleted) return;
    cleanup();
    if (error is Failure) {
      completer.completeError(error, stackTrace);
    } else {
      completer.completeError(error, stackTrace ?? StackTrace.current);
    }
  }

  messageSub = web.window.onMessage.listen((event) async {
    if (handlingRedirect || completer.isCompleted) return;
    if (event.origin != redirectOrigin) return;

    final raw = event.data?.dartify();
    if (raw is! Map) return;

    final type = raw['type']?.toString();
    if (type != _redirectMessageType) return;

    handlingRedirect = true;

    final state = raw['state']?.toString() ?? '';
    final code = raw['code']?.toString() ?? '';
    final error = raw['error']?.toString() ?? '';
    final errorDescription = raw['errorDescription']?.toString() ?? '';

    if (state.isEmpty || state != expectedState) {
      ackPopup(ok: false, message: 'Sign-in state mismatch.');
      fail(
        const AuthFailure(
          'Google sign-in state mismatch',
          null,
          'google_oauth_failed',
        ),
      );
      return;
    }

    if (error.isNotEmpty || code.isEmpty) {
      final cancelled = error == 'access_denied';
      ackPopup(
        ok: false,
        message: errorDescription.isNotEmpty
            ? errorDescription
            : 'Google sign-in was cancelled.',
      );
      fail(
        AuthFailure(
          errorDescription.isNotEmpty
              ? errorDescription
              : 'Google sign-in was cancelled',
          null,
          cancelled ? 'google_oauth_cancelled' : 'google_oauth_failed',
        ),
      );
      return;
    }

    // Popup may close after postMessage; that is success, not cancel.
    closedPoll?.cancel();
    closedPoll = null;

    try {
      final auth = await collection.authWithOAuth2Code(
        provider.name,
        code,
        provider.codeVerifier,
        redirectUrl,
        expand: expand,
      );
      ackPopup(ok: true);
      if (!completer.isCompleted) {
        cleanup();
        completer.complete(auth);
      }
    } catch (err, st) {
      final message = err is ClientException
          ? (err.response['message']?.toString() ?? err.toString())
          : err.toString();
      ackPopup(ok: false, message: message);
      fail(err, st);
    }
  });

  closedPoll = Timer.periodic(const Duration(milliseconds: 400), (_) {
    if (!popup.closed) return;
    if (completer.isCompleted) {
      cleanup();
      return;
    }
    fail(
      const AuthFailure(
        'Google sign-in was cancelled',
        null,
        'google_oauth_cancelled',
      ),
    );
  });

  try {
    return await completer.future;
  } finally {
    cleanup();
  }
}
