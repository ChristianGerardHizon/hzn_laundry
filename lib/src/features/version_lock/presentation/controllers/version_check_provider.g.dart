// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_check_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(versionCheck)
final versionCheckProvider = VersionCheckProvider._();

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

final class VersionCheckProvider extends $FunctionalProvider<
        AsyncValue<VersionCheckResult>,
        VersionCheckResult,
        FutureOr<VersionCheckResult>>
    with
        $FutureModifier<VersionCheckResult>,
        $FutureProvider<VersionCheckResult> {
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
  VersionCheckProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'versionCheckProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$versionCheckHash();

  @$internal
  @override
  $FutureProviderElement<VersionCheckResult> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<VersionCheckResult> create(Ref ref) {
    return versionCheck(ref);
  }
}

String _$versionCheckHash() => r'da45e8d997dd28f0a22f3d6aafa6816e9ec3a8ec';
