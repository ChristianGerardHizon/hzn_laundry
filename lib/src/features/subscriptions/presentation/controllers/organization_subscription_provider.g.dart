// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single organization subscription by organization ID.

@ProviderFor(organizationSubscription)
final organizationSubscriptionProvider = OrganizationSubscriptionFamily._();

/// Single organization subscription by organization ID.

final class OrganizationSubscriptionProvider extends $FunctionalProvider<
        AsyncValue<OrganizationSubscription?>,
        OrganizationSubscription?,
        FutureOr<OrganizationSubscription?>>
    with
        $FutureModifier<OrganizationSubscription?>,
        $FutureProvider<OrganizationSubscription?> {
  /// Single organization subscription by organization ID.
  OrganizationSubscriptionProvider._(
      {required OrganizationSubscriptionFamily super.from,
      required String super.argument})
      : super(
          retry: retryUnlessForbidden,
          name: r'organizationSubscriptionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationSubscriptionHash();

  @override
  String toString() {
    return r'organizationSubscriptionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OrganizationSubscription?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OrganizationSubscription?> create(Ref ref) {
    final argument = this.argument as String;
    return organizationSubscription(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrganizationSubscriptionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizationSubscriptionHash() =>
    r'1d4cfe6c9a14b0a36034fc54426f431b15aa39d4';

/// Single organization subscription by organization ID.

final class OrganizationSubscriptionFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<OrganizationSubscription?>, String> {
  OrganizationSubscriptionFamily._()
      : super(
          retry: retryUnlessForbidden,
          name: r'organizationSubscriptionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Single organization subscription by organization ID.

  OrganizationSubscriptionProvider call(
    String organizationId,
  ) =>
      OrganizationSubscriptionProvider._(argument: organizationId, from: this);

  @override
  String toString() => r'organizationSubscriptionProvider';
}
