// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incentive_tiers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cached list of incentive tiers for a branch. Tiers change rarely, so
/// keep them alive across screen rebuilds to avoid refetching.

@ProviderFor(incentiveTiersForBranch)
final incentiveTiersForBranchProvider = IncentiveTiersForBranchFamily._();

/// Cached list of incentive tiers for a branch. Tiers change rarely, so
/// keep them alive across screen rebuilds to avoid refetching.

final class IncentiveTiersForBranchProvider extends $FunctionalProvider<
        AsyncValue<List<IncentiveTier>>,
        List<IncentiveTier>,
        FutureOr<List<IncentiveTier>>>
    with
        $FutureModifier<List<IncentiveTier>>,
        $FutureProvider<List<IncentiveTier>> {
  /// Cached list of incentive tiers for a branch. Tiers change rarely, so
  /// keep them alive across screen rebuilds to avoid refetching.
  IncentiveTiersForBranchProvider._(
      {required IncentiveTiersForBranchFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'incentiveTiersForBranchProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$incentiveTiersForBranchHash();

  @override
  String toString() {
    return r'incentiveTiersForBranchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<IncentiveTier>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<IncentiveTier>> create(Ref ref) {
    final argument = this.argument as String;
    return incentiveTiersForBranch(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IncentiveTiersForBranchProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$incentiveTiersForBranchHash() =>
    r'5c75bfc7ef3660f4d9c8f9c20d893117cdbd4daa';

/// Cached list of incentive tiers for a branch. Tiers change rarely, so
/// keep them alive across screen rebuilds to avoid refetching.

final class IncentiveTiersForBranchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<IncentiveTier>>, String> {
  IncentiveTiersForBranchFamily._()
      : super(
          retry: null,
          name: r'incentiveTiersForBranchProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Cached list of incentive tiers for a branch. Tiers change rarely, so
  /// keep them alive across screen rebuilds to avoid refetching.

  IncentiveTiersForBranchProvider call(
    String branchId,
  ) =>
      IncentiveTiersForBranchProvider._(argument: branchId, from: this);

  @override
  String toString() => r'incentiveTiersForBranchProvider';
}
