// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_platform_stats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads platform-wide organization metrics for Super Admin.

@ProviderFor(OrganizationPlatformStatsController)
final organizationPlatformStatsControllerProvider =
    OrganizationPlatformStatsControllerProvider._();

/// Loads platform-wide organization metrics for Super Admin.
final class OrganizationPlatformStatsControllerProvider
    extends $AsyncNotifierProvider<OrganizationPlatformStatsController,
        OrganizationPlatformStatsResponse> {
  /// Loads platform-wide organization metrics for Super Admin.
  OrganizationPlatformStatsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'organizationPlatformStatsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$organizationPlatformStatsControllerHash();

  @$internal
  @override
  OrganizationPlatformStatsController create() =>
      OrganizationPlatformStatsController();
}

String _$organizationPlatformStatsControllerHash() =>
    r'cee7db9135211cffaeb08595b8fad02da6934c64';

/// Loads platform-wide organization metrics for Super Admin.

abstract class _$OrganizationPlatformStatsController
    extends $AsyncNotifier<OrganizationPlatformStatsResponse> {
  FutureOr<OrganizationPlatformStatsResponse> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OrganizationPlatformStatsResponse>,
        OrganizationPlatformStatsResponse>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<OrganizationPlatformStatsResponse>,
            OrganizationPlatformStatsResponse>,
        AsyncValue<OrganizationPlatformStatsResponse>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
