/// Status of the version check against remote config.
enum VersionCheckStatus {
  /// App is up to date — no action needed.
  upToDate,

  /// A newer version is available but current version is still supported.
  /// Shows a dismissable dialog.
  updateAvailable,

  /// Current version is below the minimum — user must update.
  /// Shows a blocking full-screen page.
  forceUpdateRequired,

  /// A newer version is deployed on web — user should reload.
  /// Shows a blocking page with a reload button.
  webUpdateAvailable,
}

/// Result of comparing the current app version against remote config.
class VersionCheckResult {
  const VersionCheckResult({
    required this.status,
    this.latestVersion,
  });

  /// The status of the version check.
  final VersionCheckStatus status;

  /// The latest available version string.
  final String? latestVersion;

  /// Convenience factory for the default "all good" result.
  static const upToDate = VersionCheckResult(
    status: VersionCheckStatus.upToDate,
  );
}
