// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_pending_invites_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pending organization invites for the current org (Management Users).

@ProviderFor(OrgPendingInvitesController)
final orgPendingInvitesControllerProvider =
    OrgPendingInvitesControllerProvider._();

/// Pending organization invites for the current org (Management Users).
final class OrgPendingInvitesControllerProvider extends $AsyncNotifierProvider<
    OrgPendingInvitesController, List<OrganizationInvite>> {
  /// Pending organization invites for the current org (Management Users).
  OrgPendingInvitesControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orgPendingInvitesControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orgPendingInvitesControllerHash();

  @$internal
  @override
  OrgPendingInvitesController create() => OrgPendingInvitesController();
}

String _$orgPendingInvitesControllerHash() =>
    r'39170c9492c8bc20ebca4e6ba3206bf21661df4c';

/// Pending organization invites for the current org (Management Users).

abstract class _$OrgPendingInvitesController
    extends $AsyncNotifier<List<OrganizationInvite>> {
  FutureOr<List<OrganizationInvite>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<OrganizationInvite>>, List<OrganizationInvite>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<OrganizationInvite>>,
            List<OrganizationInvite>>,
        AsyncValue<List<OrganizationInvite>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
