import 'package:pocketbase/pocketbase.dart';

/// Stub for non-web platforms — web Google OAuth is only used on web.
Future<RecordAuth> loginWithGoogleWeb({
  required PocketBase pb,
  required String expand,
}) {
  throw UnsupportedError('Web Google OAuth is only available on web');
}
