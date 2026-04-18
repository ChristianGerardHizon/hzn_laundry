// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_incentive_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that calculates the total incentive for the effective dashboard date.
///
/// Excludes orders with status 'processing'.

@ProviderFor(todayIncentiveSummary)
final todayIncentiveSummaryProvider = TodayIncentiveSummaryProvider._();

/// Provider that calculates the total incentive for the effective dashboard date.
///
/// Excludes orders with status 'processing'.

final class TodayIncentiveSummaryProvider extends $FunctionalProvider<
        AsyncValue<TodayIncentiveSummary>,
        TodayIncentiveSummary,
        FutureOr<TodayIncentiveSummary>>
    with
        $FutureModifier<TodayIncentiveSummary>,
        $FutureProvider<TodayIncentiveSummary> {
  /// Provider that calculates the total incentive for the effective dashboard date.
  ///
  /// Excludes orders with status 'processing'.
  TodayIncentiveSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todayIncentiveSummaryProvider',
          isAutoDispose: true,
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
    r'cedd2114845f39000dee4077d995c12d27bc8ab4';
