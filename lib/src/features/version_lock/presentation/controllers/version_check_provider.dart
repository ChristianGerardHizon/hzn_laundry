import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/app_info/app_info_provider.dart';
import '../../data/repositories/app_config_repository.dart';
import '../../domain/version_check_result.dart';
import '../../domain/version_utils.dart';

part 'version_check_provider.g.dart';

/// Pass --dart-define=SKIP_VERSION_CHECK=true to disable version checking.
const _skipVersionCheck =
    bool.fromEnvironment('SKIP_VERSION_CHECK', defaultValue: false);

/// Checks the current app version against the remote version-manager service.
///
/// Returns [VersionCheckResult] indicating whether the user needs to update.
/// Fails open: any error or missing config returns [VersionCheckStatus.upToDate].
///
/// On web, shows a blocking page with a reload button when below minimum version.
/// The `latestVersion` check is skipped since the deployed build is always
/// the latest version on web.
///
/// The minimum-version lockout only applies on Android and web — Google Play's
/// native In-App Update API handles Android, while iOS/macOS/Linux/Windows have
/// no in-app update mechanism and always report up to date.
@Riverpod(keepAlive: true)
Future<VersionCheckResult> versionCheck(Ref ref) async {
  // Skip version check in debug/profile modes or when explicitly disabled
  if (kDebugMode || kProfileMode || _skipVersionCheck) {
    return VersionCheckResult.upToDate;
  }

  if (!kIsWeb && !Platform.isAndroid) {
    return VersionCheckResult.upToDate;
  }

  try {
    final packageInfo = await ref.watch(appInfoProvider.future);
    final currentVersion = packageInfo.version;

    final repo = ref.watch(appConfigRepositoryProvider);
    final result = await repo.fetch();

    return result.fold(
      // Fetch failed → fail open
      (_) => VersionCheckResult.upToDate,
      (config) {
        // No config found → proceed normally
        if (config == null) {
          return VersionCheckResult.upToDate;
        }

        final isBelowMinimum =
            VersionUtils.isBelow(currentVersion, config.minimumVersion);

        // On web, only block when below minimum version (actual deploy mismatch).
        // Being below latestVersion doesn't matter on web since there's no APK.
        if (kIsWeb && isBelowMinimum) {
          return const VersionCheckResult(
            status: VersionCheckStatus.webUpdateAvailable,
          );
        }

        // On web and above minimum → up to date (skip latestVersion check)
        if (kIsWeb) {
          return VersionCheckResult.upToDate;
        }

        // Below minimum → force update
        if (VersionUtils.isBelow(currentVersion, config.minimumVersion)) {
          return VersionCheckResult(
            status: VersionCheckStatus.forceUpdateRequired,
            latestVersion: config.latestVersion,
          );
        }

        // Up to date
        return VersionCheckResult.upToDate;
      },
    );
  } catch (_) {
    // Any unexpected error → fail open
    return VersionCheckResult.upToDate;
  }
}
