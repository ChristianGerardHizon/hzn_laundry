// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incentive_tier_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the IncentiveTierRepository instance.

@ProviderFor(incentiveTierRepository)
final incentiveTierRepositoryProvider = IncentiveTierRepositoryProvider._();

/// Provides the IncentiveTierRepository instance.

final class IncentiveTierRepositoryProvider extends $FunctionalProvider<
    IncentiveTierRepository,
    IncentiveTierRepository,
    IncentiveTierRepository> with $Provider<IncentiveTierRepository> {
  /// Provides the IncentiveTierRepository instance.
  IncentiveTierRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'incentiveTierRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$incentiveTierRepositoryHash();

  @$internal
  @override
  $ProviderElement<IncentiveTierRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IncentiveTierRepository create(Ref ref) {
    return incentiveTierRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncentiveTierRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncentiveTierRepository>(value),
    );
  }
}

String _$incentiveTierRepositoryHash() =>
    r'9118a40d5fbfb8e78224f8b36082ebbab4cde845';
