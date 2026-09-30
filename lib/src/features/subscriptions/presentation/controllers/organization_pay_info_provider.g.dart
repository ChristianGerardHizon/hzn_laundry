// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_pay_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pay-screen payload for an organization (subscription + QRPH settings).

@ProviderFor(organizationPayInfo)
final organizationPayInfoProvider = OrganizationPayInfoFamily._();

/// Pay-screen payload for an organization (subscription + QRPH settings).

final class OrganizationPayInfoProvider extends $FunctionalProvider<
        AsyncValue<OrganizationPayInfo>,
        OrganizationPayInfo,
        FutureOr<OrganizationPayInfo>>
    with
        $FutureModifier<OrganizationPayInfo>,
        $FutureProvider<OrganizationPayInfo> {
  /// Pay-screen payload for an organization (subscription + QRPH settings).
  OrganizationPayInfoProvider._(
      {required OrganizationPayInfoFamily super.from,
      required String super.argument})
      : super(
          retry: retryUnlessForbidden,
          name: r'organizationPayInfoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationPayInfoHash();

  @override
  String toString() {
    return r'organizationPayInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OrganizationPayInfo> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OrganizationPayInfo> create(Ref ref) {
    final argument = this.argument as String;
    return organizationPayInfo(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrganizationPayInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizationPayInfoHash() =>
    r'3a89156e52834013bd724187564b7261fc926815';

/// Pay-screen payload for an organization (subscription + QRPH settings).

final class OrganizationPayInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OrganizationPayInfo>, String> {
  OrganizationPayInfoFamily._()
      : super(
          retry: retryUnlessForbidden,
          name: r'organizationPayInfoProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Pay-screen payload for an organization (subscription + QRPH settings).

  OrganizationPayInfoProvider call(
    String organizationId,
  ) =>
      OrganizationPayInfoProvider._(argument: organizationId, from: this);

  @override
  String toString() => r'organizationPayInfoProvider';
}
