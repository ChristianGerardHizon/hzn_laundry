// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loads_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Summary of machine loads for the effective dashboard date, broken down per
/// order.
///
/// A load is a machine cycle assigned to a sale's service items
/// (`saleServiceItems.machineLoadCounts`). Counts come from the service items
/// already loaded with today's sales, so this does not scan
/// `vw_loads_summary`. Voided sales are excluded by [salesSummary].

@ProviderFor(loadsSummary)
final loadsSummaryProvider = LoadsSummaryProvider._();

/// Summary of machine loads for the effective dashboard date, broken down per
/// order.
///
/// A load is a machine cycle assigned to a sale's service items
/// (`saleServiceItems.machineLoadCounts`). Counts come from the service items
/// already loaded with today's sales, so this does not scan
/// `vw_loads_summary`. Voided sales are excluded by [salesSummary].

final class LoadsSummaryProvider extends $FunctionalProvider<
        AsyncValue<LoadsSummaryData>,
        LoadsSummaryData,
        FutureOr<LoadsSummaryData>>
    with $FutureModifier<LoadsSummaryData>, $FutureProvider<LoadsSummaryData> {
  /// Summary of machine loads for the effective dashboard date, broken down per
  /// order.
  ///
  /// A load is a machine cycle assigned to a sale's service items
  /// (`saleServiceItems.machineLoadCounts`). Counts come from the service items
  /// already loaded with today's sales, so this does not scan
  /// `vw_loads_summary`. Voided sales are excluded by [salesSummary].
  LoadsSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loadsSummaryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loadsSummaryHash();

  @$internal
  @override
  $FutureProviderElement<LoadsSummaryData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LoadsSummaryData> create(Ref ref) {
    return loadsSummary(ref);
  }
}

String _$loadsSummaryHash() => r'2a08c0281dfc7a5adcc9c3ab3a977987145b5694';
