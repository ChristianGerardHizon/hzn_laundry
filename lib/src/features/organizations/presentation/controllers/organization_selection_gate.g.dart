// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_selection_gate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Session flag: user has explicitly chosen (or created) an organization.
///
/// Cleared on logout so the next login with 1+ memberships shows the picker
/// again. Kept in memory only — not persisted.

@ProviderFor(OrganizationSelectionConfirmed)
final organizationSelectionConfirmedProvider =
    OrganizationSelectionConfirmedProvider._();

/// Session flag: user has explicitly chosen (or created) an organization.
///
/// Cleared on logout so the next login with 1+ memberships shows the picker
/// again. Kept in memory only — not persisted.
final class OrganizationSelectionConfirmedProvider
    extends $NotifierProvider<OrganizationSelectionConfirmed, bool> {
  /// Session flag: user has explicitly chosen (or created) an organization.
  ///
  /// Cleared on logout so the next login with 1+ memberships shows the picker
  /// again. Kept in memory only — not persisted.
  OrganizationSelectionConfirmedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'organizationSelectionConfirmedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationSelectionConfirmedHash();

  @$internal
  @override
  OrganizationSelectionConfirmed create() => OrganizationSelectionConfirmed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$organizationSelectionConfirmedHash() =>
    r'df748c6226083c858f045703ac359c7e783b0715';

/// Session flag: user has explicitly chosen (or created) an organization.
///
/// Cleared on logout so the next login with 1+ memberships shows the picker
/// again. Kept in memory only — not persisted.

abstract class _$OrganizationSelectionConfirmed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
