// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_packs_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that aggregates total packs for the effective dashboard date.
///
/// Fetches non-voided orders for the day and sums the `packs` field.
/// Only orders with packs > 0 appear in the breakdown list.

@ProviderFor(totalPacksSummary)
final totalPacksSummaryProvider = TotalPacksSummaryProvider._();

/// Provider that aggregates total packs for the effective dashboard date.
///
/// Fetches non-voided orders for the day and sums the `packs` field.
/// Only orders with packs > 0 appear in the breakdown list.

final class TotalPacksSummaryProvider extends $FunctionalProvider<
        AsyncValue<TotalPacksSummary>,
        TotalPacksSummary,
        FutureOr<TotalPacksSummary>>
    with
        $FutureModifier<TotalPacksSummary>,
        $FutureProvider<TotalPacksSummary> {
  /// Provider that aggregates total packs for the effective dashboard date.
  ///
  /// Fetches non-voided orders for the day and sums the `packs` field.
  /// Only orders with packs > 0 appear in the breakdown list.
  TotalPacksSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'totalPacksSummaryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$totalPacksSummaryHash();

  @$internal
  @override
  $FutureProviderElement<TotalPacksSummary> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TotalPacksSummary> create(Ref ref) {
    return totalPacksSummary(ref);
  }
}

String _$totalPacksSummaryHash() => r'a79fbde1e30884a6c19b9d1424234fe70f68920d';
