import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'play_store_update_provider.g.dart';

/// Play Store listing URL — matches `applicationId` in
/// android/app/build.gradle.kts. Used as a fallback when Play's native
/// in-app update flow isn't available/allowed on this device.
const _playStoreListingUrl =
    'https://play.google.com/store/apps/details?id=com.hznsystems.hizonelaundry';

/// State of the background flexible update download.
enum FlexibleUpdateState {
  idle,
  downloading,
  readyToInstall,
}

/// Drives Google Play's native In-App Updates flow.
///
/// Android-only: every method fails silently (no-op or falls back to the
/// Play Store listing) on other platforms, in debug builds, or when Play
/// Core isn't available (e.g. the app wasn't installed via the Play Store).
@Riverpod(keepAlive: true)
class PlayStoreUpdate extends _$PlayStoreUpdate {
  @override
  FlexibleUpdateState build() => FlexibleUpdateState.idle;

  bool get _isSupportedPlatform => !kIsWeb && !kDebugMode && Platform.isAndroid;

  /// Checks Play for an update and, if a flexible update is allowed, starts
  /// downloading it in the background. Call once on app start.
  ///
  /// Also handles the case where a flexible update was already downloaded in
  /// a previous session (e.g. the app was closed before the user restarted)
  /// — Play reports that as [UpdateAvailability.developerTriggeredUpdateInProgress]
  /// rather than [UpdateAvailability.updateAvailable].
  Future<void> startFlexibleUpdateIfAvailable() async {
    if (!_isSupportedPlatform) return;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress &&
          info.installStatus == InstallStatus.downloaded) {
        state = FlexibleUpdateState.readyToInstall;
        return;
      }

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }
      if (!info.flexibleUpdateAllowed) return;

      state = FlexibleUpdateState.downloading;
      final result = await InAppUpdate.startFlexibleUpdate();
      state = result == AppUpdateResult.success
          ? FlexibleUpdateState.readyToInstall
          : FlexibleUpdateState.idle;
    } catch (_) {
      // Fail silently — e.g. not installed via Play, Play services missing.
      state = FlexibleUpdateState.idle;
    }
  }

  /// Installs the downloaded flexible update and restarts the app.
  Future<void> completeFlexibleUpdate() async {
    if (!_isSupportedPlatform) return;

    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (_) {
      // Ignore — the user can restart the app manually.
    } finally {
      state = FlexibleUpdateState.idle;
    }
  }

  /// Triggers Play's immediate (blocking) update flow. Falls back to opening
  /// the Play Store listing if immediate update isn't available/allowed, or
  /// the call fails for any reason.
  Future<void> performImmediateUpdateOrFallback() async {
    if (_isSupportedPlatform) {
      try {
        final info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable &&
            info.immediateUpdateAllowed) {
          final result = await InAppUpdate.performImmediateUpdate();
          // Only success skips the fallback below — userDeniedUpdate and
          // inAppUpdateFailed are returned (not thrown) by the plugin, and
          // otherwise leave the user stuck on the blocking force-update page.
          if (result == AppUpdateResult.success) return;
        }
      } catch (_) {
        // Fall through to opening the store listing below.
      }
    }

    await _openPlayStoreListing();
  }

  Future<void> _openPlayStoreListing() async {
    try {
      await launchUrl(
        Uri.parse(_playStoreListingUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Nothing more we can do.
    }
  }
}
