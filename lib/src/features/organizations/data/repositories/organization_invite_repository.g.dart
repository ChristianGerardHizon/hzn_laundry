// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_invite_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizationInviteRepository)
final organizationInviteRepositoryProvider =
    OrganizationInviteRepositoryProvider._();

final class OrganizationInviteRepositoryProvider extends $FunctionalProvider<
    OrganizationInviteRepository,
    OrganizationInviteRepository,
    OrganizationInviteRepository> with $Provider<OrganizationInviteRepository> {
  OrganizationInviteRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'organizationInviteRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationInviteRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationInviteRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrganizationInviteRepository create(Ref ref) {
    return organizationInviteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationInviteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationInviteRepository>(value),
    );
  }
}

String _$organizationInviteRepositoryHash() =>
    r'c1876ce974688769489c76af703b857aada1a3ee';
