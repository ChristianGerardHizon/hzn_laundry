// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_organization_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keep-alive flag for the organization-switch full-screen overlay.

@ProviderFor(OrganizationSwitchOverlay)
final organizationSwitchOverlayProvider = OrganizationSwitchOverlayProvider._();

/// Keep-alive flag for the organization-switch full-screen overlay.
final class OrganizationSwitchOverlayProvider extends $NotifierProvider<
    OrganizationSwitchOverlay, OrganizationSwitchOverlayState> {
  /// Keep-alive flag for the organization-switch full-screen overlay.
  OrganizationSwitchOverlayProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'organizationSwitchOverlayProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationSwitchOverlayHash();

  @$internal
  @override
  OrganizationSwitchOverlay create() => OrganizationSwitchOverlay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationSwitchOverlayState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<OrganizationSwitchOverlayState>(value),
    );
  }
}

String _$organizationSwitchOverlayHash() =>
    r'38154d334b86c90a817339b5206a6d9352861eb5';

/// Keep-alive flag for the organization-switch full-screen overlay.

abstract class _$OrganizationSwitchOverlay
    extends $Notifier<OrganizationSwitchOverlayState> {
  OrganizationSwitchOverlayState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<OrganizationSwitchOverlayState, OrganizationSwitchOverlayState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OrganizationSwitchOverlayState,
            OrganizationSwitchOverlayState>,
        OrganizationSwitchOverlayState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentOrganizationController)
final currentOrganizationControllerProvider =
    CurrentOrganizationControllerProvider._();

final class CurrentOrganizationControllerProvider
    extends $AsyncNotifierProvider<CurrentOrganizationController,
        Organization?> {
  CurrentOrganizationControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentOrganizationControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentOrganizationControllerHash();

  @$internal
  @override
  CurrentOrganizationController create() => CurrentOrganizationController();
}

String _$currentOrganizationControllerHash() =>
    r'35af2b145111ef9c4668b6238e47948d7683469d';

abstract class _$CurrentOrganizationController
    extends $AsyncNotifier<Organization?> {
  FutureOr<Organization?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Organization?>, Organization?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Organization?>, Organization?>,
        AsyncValue<Organization?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(currentOrganizationId)
final currentOrganizationIdProvider = CurrentOrganizationIdProvider._();

final class CurrentOrganizationIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  CurrentOrganizationIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentOrganizationIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentOrganizationIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentOrganizationId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentOrganizationIdHash() =>
    r'ac7eab489dba76f0b27102077ebd74f5074e8569';

@ProviderFor(canSwitchOrganization)
final canSwitchOrganizationProvider = CanSwitchOrganizationProvider._();

final class CanSwitchOrganizationProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  CanSwitchOrganizationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'canSwitchOrganizationProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canSwitchOrganizationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canSwitchOrganization(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canSwitchOrganizationHash() =>
    r'9c7581a6ac1dd7ee4778209b0c875cdfeba385c6';
