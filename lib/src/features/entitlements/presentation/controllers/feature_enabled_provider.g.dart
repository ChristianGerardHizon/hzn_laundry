// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_enabled_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether [feature] is enabled for the current organization.
///
/// While entitlements are still loading this returns `true` so navigation does
/// not flicker or redirect deep links prematurely; server guards still apply.

@ProviderFor(featureEnabled)
final featureEnabledProvider = FeatureEnabledFamily._();

/// Whether [feature] is enabled for the current organization.
///
/// While entitlements are still loading this returns `true` so navigation does
/// not flicker or redirect deep links prematurely; server guards still apply.

final class FeatureEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [feature] is enabled for the current organization.
  ///
  /// While entitlements are still loading this returns `true` so navigation does
  /// not flicker or redirect deep links prematurely; server guards still apply.
  FeatureEnabledProvider._(
      {required FeatureEnabledFamily super.from,
      required FeatureKey super.argument})
      : super(
          retry: null,
          name: r'featureEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$featureEnabledHash();

  @override
  String toString() {
    return r'featureEnabledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as FeatureKey;
    return featureEnabled(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FeatureEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$featureEnabledHash() => r'faafeec948f19edce0fae4d7e8372eb206947bb8';

/// Whether [feature] is enabled for the current organization.
///
/// While entitlements are still loading this returns `true` so navigation does
/// not flicker or redirect deep links prematurely; server guards still apply.

final class FeatureEnabledFamily extends $Family
    with $FunctionalFamilyOverride<bool, FeatureKey> {
  FeatureEnabledFamily._()
      : super(
          retry: null,
          name: r'featureEnabledProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Whether [feature] is enabled for the current organization.
  ///
  /// While entitlements are still loading this returns `true` so navigation does
  /// not flicker or redirect deep links prematurely; server guards still apply.

  FeatureEnabledProvider call(
    FeatureKey feature,
  ) =>
      FeatureEnabledProvider._(argument: feature, from: this);

  @override
  String toString() => r'featureEnabledProvider';
}
