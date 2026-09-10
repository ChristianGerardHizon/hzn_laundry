// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flag_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(featureFlagRepository)
final featureFlagRepositoryProvider = FeatureFlagRepositoryProvider._();

final class FeatureFlagRepositoryProvider extends $FunctionalProvider<
    FeatureFlagRepository,
    FeatureFlagRepository,
    FeatureFlagRepository> with $Provider<FeatureFlagRepository> {
  FeatureFlagRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'featureFlagRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$featureFlagRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeatureFlagRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeatureFlagRepository create(Ref ref) {
    return featureFlagRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeatureFlagRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeatureFlagRepository>(value),
    );
  }
}

String _$featureFlagRepositoryHash() =>
    r'9f9e5ab128e10c15610380df4083708962d0e4f2';

@ProviderFor(organizationFeatureFlags)
final organizationFeatureFlagsProvider = OrganizationFeatureFlagsProvider._();

final class OrganizationFeatureFlagsProvider extends $FunctionalProvider<
        AsyncValue<List<FeatureFlag>>,
        List<FeatureFlag>,
        FutureOr<List<FeatureFlag>>>
    with
        $FutureModifier<List<FeatureFlag>>,
        $FutureProvider<List<FeatureFlag>> {
  OrganizationFeatureFlagsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'organizationFeatureFlagsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationFeatureFlagsHash();

  @$internal
  @override
  $FutureProviderElement<List<FeatureFlag>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<FeatureFlag>> create(Ref ref) {
    return organizationFeatureFlags(ref);
  }
}

String _$organizationFeatureFlagsHash() =>
    r'b1acce5faaa000824a3e9206a71e57242a6ce5ea';

/// Returns the enabled state of the emailUpdatesEnabled flag.
/// Defaults to true (fail open) if the flag is missing or an error occurs.

@ProviderFor(emailUpdatesEnabled)
final emailUpdatesEnabledProvider = EmailUpdatesEnabledProvider._();

/// Returns the enabled state of the emailUpdatesEnabled flag.
/// Defaults to true (fail open) if the flag is missing or an error occurs.

final class EmailUpdatesEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Returns the enabled state of the emailUpdatesEnabled flag.
  /// Defaults to true (fail open) if the flag is missing or an error occurs.
  EmailUpdatesEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'emailUpdatesEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$emailUpdatesEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return emailUpdatesEnabled(ref);
  }
}

String _$emailUpdatesEnabledHash() =>
    r'5ae31d96faaa5db18f39623977b644822db5739d';

/// Blocks moving to Processing if any service item has no machine assigned.
/// Defaults to false (fail closed — no blocking).

@ProviderFor(requireMachineEnabled)
final requireMachineEnabledProvider = RequireMachineEnabledProvider._();

/// Blocks moving to Processing if any service item has no machine assigned.
/// Defaults to false (fail closed — no blocking).

final class RequireMachineEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Blocks moving to Processing if any service item has no machine assigned.
  /// Defaults to false (fail closed — no blocking).
  RequireMachineEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'requireMachineEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$requireMachineEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return requireMachineEnabled(ref);
  }
}

String _$requireMachineEnabledHash() =>
    r'54b3d8c65e1252e6b3eca1374c0c11882600ffed';

/// Blocks moving to Ready if sale has no packs set.
/// Defaults to false (fail closed — no blocking).

@ProviderFor(requirePackEnabled)
final requirePackEnabledProvider = RequirePackEnabledProvider._();

/// Blocks moving to Ready if sale has no packs set.
/// Defaults to false (fail closed — no blocking).

final class RequirePackEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Blocks moving to Ready if sale has no packs set.
  /// Defaults to false (fail closed — no blocking).
  RequirePackEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'requirePackEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$requirePackEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return requirePackEnabled(ref);
  }
}

String _$requirePackEnabledHash() =>
    r'd7d6a4735175e611ba7126b7efef4d2309b7e56b';

/// Blocks moving to Ready if any service item has no storage assigned.
/// Defaults to false (fail closed — no blocking).

@ProviderFor(requireStorageEnabled)
final requireStorageEnabledProvider = RequireStorageEnabledProvider._();

/// Blocks moving to Ready if any service item has no storage assigned.
/// Defaults to false (fail closed — no blocking).

final class RequireStorageEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Blocks moving to Ready if any service item has no storage assigned.
  /// Defaults to false (fail closed — no blocking).
  RequireStorageEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'requireStorageEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$requireStorageEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return requireStorageEnabled(ref);
  }
}

String _$requireStorageEnabledHash() =>
    r'7ed56d4cf4017e5c6abd2e7acffb2b789ec2769e';

/// Shows consumable usage on orders. Defaults to false (fail closed).

@ProviderFor(consumableUsageEnabled)
final consumableUsageEnabledProvider = ConsumableUsageEnabledProvider._();

/// Shows consumable usage on orders. Defaults to false (fail closed).

final class ConsumableUsageEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Shows consumable usage on orders. Defaults to false (fail closed).
  ConsumableUsageEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'consumableUsageEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$consumableUsageEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return consumableUsageEnabled(ref);
  }
}

String _$consumableUsageEnabledHash() =>
    r'27e1c01fe8b3781d6ee8fb18928956a13a04f0e0';
