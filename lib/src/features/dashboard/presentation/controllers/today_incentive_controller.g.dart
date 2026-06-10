// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_incentive_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that calculates the total incentive for the effective dashboard date.
///
/// Includes processing, ready, and pickedUp orders. Excludes pending.

@ProviderFor(todayIncentiveSummary)
final todayIncentiveSummaryProvider = TodayIncentiveSummaryProvider._();

/// Provider that calculates the total incentive for the effective dashboard date.
///
/// Includes processing, ready, and pickedUp orders. Excludes pending.

final class TodayIncentiveSummaryProvider extends $FunctionalProvider<
        AsyncValue<TodayIncentiveSummary>,
        TodayIncentiveSummary,
        FutureOr<TodayIncentiveSummary>>
    with
        $FutureModifier<TodayIncentiveSummary>,
        $FutureProvider<TodayIncentiveSummary> {
  /// Provider that calculates the total incentive for the effective dashboard date.
  ///
  /// Includes processing, ready, and pickedUp orders. Excludes pending.
  TodayIncentiveSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todayIncentiveSummaryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todayIncentiveSummaryHash();

  @$internal
  @override
  $FutureProviderElement<TodayIncentiveSummary> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TodayIncentiveSummary> create(Ref ref) {
    return todayIncentiveSummary(ref);
  }
}

String _$todayIncentiveSummaryHash() =>
    r'a126ee8ada90cdb45b769a71578dfdc8faa4a73c';
