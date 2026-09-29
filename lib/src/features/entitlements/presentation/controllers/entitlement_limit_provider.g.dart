// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_limit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolved limit and usage for the current organization.
///
/// Unlimited while entitlements are loading or if the fetch failed (the server
/// still enforces).

@ProviderFor(entitlementLimit)
final entitlementLimitProvider = EntitlementLimitFamily._();

/// Resolved limit and usage for the current organization.
///
/// Unlimited while entitlements are loading or if the fetch failed (the server
/// still enforces).

final class EntitlementLimitProvider extends $FunctionalProvider<
    EntitlementLimit,
    EntitlementLimit,
    EntitlementLimit> with $Provider<EntitlementLimit> {
  /// Resolved limit and usage for the current organization.
  ///
  /// Unlimited while entitlements are loading or if the fetch failed (the server
  /// still enforces).
  EntitlementLimitProvider._(
      {required EntitlementLimitFamily super.from,
      required LimitKey super.argument})
      : super(
          retry: null,
          name: r'entitlementLimitProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entitlementLimitHash();

  @override
  String toString() {
    return r'entitlementLimitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EntitlementLimit> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EntitlementLimit create(Ref ref) {
    final argument = this.argument as LimitKey;
    return entitlementLimit(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntitlementLimit value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntitlementLimit>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EntitlementLimitProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entitlementLimitHash() => r'170e937c57d7a99636f136b6b3f1fadcf5ddeda7';

/// Resolved limit and usage for the current organization.
///
/// Unlimited while entitlements are loading or if the fetch failed (the server
/// still enforces).

final class EntitlementLimitFamily extends $Family
    with $FunctionalFamilyOverride<EntitlementLimit, LimitKey> {
  EntitlementLimitFamily._()
      : super(
          retry: null,
          name: r'entitlementLimitProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Resolved limit and usage for the current organization.
  ///
  /// Unlimited while entitlements are loading or if the fetch failed (the server
  /// still enforces).

  EntitlementLimitProvider call(
    LimitKey key,
  ) =>
      EntitlementLimitProvider._(argument: key, from: this);

  @override
  String toString() => r'entitlementLimitProvider';
}
