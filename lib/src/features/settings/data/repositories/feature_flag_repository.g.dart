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
    r'34bd13450ea0bdd6f035742f3da2069e40e6a3ea';

/// Blocks moving to Processing if any service item has no machine assigned.
/// Defaults to false (fail open — no blocking).

@ProviderFor(requireMachineEnabled)
final requireMachineEnabledProvider = RequireMachineEnabledProvider._();

/// Blocks moving to Processing if any service item has no machine assigned.
/// Defaults to false (fail open — no blocking).

final class RequireMachineEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Blocks moving to Processing if any service item has no machine assigned.
  /// Defaults to false (fail open — no blocking).
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
    r'ad77677b44d0ea0cc74cc4c3f086c1a93bd78aca';

/// Blocks moving to Ready if sale has no packs set.
/// Defaults to false (fail open — no blocking).

@ProviderFor(requirePackEnabled)
final requirePackEnabledProvider = RequirePackEnabledProvider._();

/// Blocks moving to Ready if sale has no packs set.
/// Defaults to false (fail open — no blocking).

final class RequirePackEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Blocks moving to Ready if sale has no packs set.
  /// Defaults to false (fail open — no blocking).
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
    r'd16d079a5ea22e045f39d2fe6714b3f410881270';

/// Blocks moving to Ready if any service item has no storage assigned.
/// Defaults to false (fail open — no blocking).

@ProviderFor(requireStorageEnabled)
final requireStorageEnabledProvider = RequireStorageEnabledProvider._();

/// Blocks moving to Ready if any service item has no storage assigned.
/// Defaults to false (fail open — no blocking).

final class RequireStorageEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Blocks moving to Ready if any service item has no storage assigned.
  /// Defaults to false (fail open — no blocking).
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
    r'276f3aea7d770a42eb3f1eabe5468483ee74bf93';
