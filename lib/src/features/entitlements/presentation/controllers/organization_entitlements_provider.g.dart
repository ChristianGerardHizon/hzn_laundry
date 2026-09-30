// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_entitlements_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolved entitlements for the current organization.
///
/// Re-resolves automatically when the current organization changes. Fails open
/// (everything enabled) on errors: the server guards still enforce, and a
/// transient network error must not hide the whole app.

@ProviderFor(currentOrganizationEntitlements)
final currentOrganizationEntitlementsProvider =
    CurrentOrganizationEntitlementsProvider._();

/// Resolved entitlements for the current organization.
///
/// Re-resolves automatically when the current organization changes. Fails open
/// (everything enabled) on errors: the server guards still enforce, and a
/// transient network error must not hide the whole app.

final class CurrentOrganizationEntitlementsProvider extends $FunctionalProvider<
        AsyncValue<OrganizationEntitlements>,
        OrganizationEntitlements,
        FutureOr<OrganizationEntitlements>>
    with
        $FutureModifier<OrganizationEntitlements>,
        $FutureProvider<OrganizationEntitlements> {
  /// Resolved entitlements for the current organization.
  ///
  /// Re-resolves automatically when the current organization changes. Fails open
  /// (everything enabled) on errors: the server guards still enforce, and a
  /// transient network error must not hide the whole app.
  CurrentOrganizationEntitlementsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentOrganizationEntitlementsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentOrganizationEntitlementsHash();

  @$internal
  @override
  $FutureProviderElement<OrganizationEntitlements> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OrganizationEntitlements> create(Ref ref) {
    return currentOrganizationEntitlements(ref);
  }
}

String _$currentOrganizationEntitlementsHash() =>
    r'ae0b376411dd427ed57bb880de2b971ac93c3948';

/// Entitlements for any organization by id (Super Admin feature access UI).

@ProviderFor(organizationEntitlements)
final organizationEntitlementsProvider = OrganizationEntitlementsFamily._();

/// Entitlements for any organization by id (Super Admin feature access UI).

final class OrganizationEntitlementsProvider extends $FunctionalProvider<
        AsyncValue<OrganizationEntitlements>,
        OrganizationEntitlements,
        FutureOr<OrganizationEntitlements>>
    with
        $FutureModifier<OrganizationEntitlements>,
        $FutureProvider<OrganizationEntitlements> {
  /// Entitlements for any organization by id (Super Admin feature access UI).
  OrganizationEntitlementsProvider._(
      {required OrganizationEntitlementsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'organizationEntitlementsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationEntitlementsHash();

  @override
  String toString() {
    return r'organizationEntitlementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OrganizationEntitlements> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OrganizationEntitlements> create(Ref ref) {
    final argument = this.argument as String;
    return organizationEntitlements(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrganizationEntitlementsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizationEntitlementsHash() =>
    r'094202a7f393b3be7b2bb7538ec4a4226dcbc133';

/// Entitlements for any organization by id (Super Admin feature access UI).

final class OrganizationEntitlementsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OrganizationEntitlements>, String> {
  OrganizationEntitlementsFamily._()
      : super(
          retry: null,
          name: r'organizationEntitlementsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Entitlements for any organization by id (Super Admin feature access UI).

  OrganizationEntitlementsProvider call(
    String organizationId,
  ) =>
      OrganizationEntitlementsProvider._(argument: organizationId, from: this);

  @override
  String toString() => r'organizationEntitlementsProvider';
}
