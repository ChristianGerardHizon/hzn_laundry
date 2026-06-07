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
/// (`saleServiceItems.machineLoadCounts`). Loads are summed across every
/// assigned machine of every service item in an order. Voided sales are
/// excluded.

@ProviderFor(loadsSummary)
final loadsSummaryProvider = LoadsSummaryProvider._();

/// Summary of machine loads for the effective dashboard date, broken down per
/// order.
///
/// A load is a machine cycle assigned to a sale's service items
/// (`saleServiceItems.machineLoadCounts`). Loads are summed across every
/// assigned machine of every service item in an order. Voided sales are
/// excluded.

final class LoadsSummaryProvider extends $FunctionalProvider<
        AsyncValue<LoadsSummaryData>,
        LoadsSummaryData,
        FutureOr<LoadsSummaryData>>
    with $FutureModifier<LoadsSummaryData>, $FutureProvider<LoadsSummaryData> {
  /// Summary of machine loads for the effective dashboard date, broken down per
  /// order.
  ///
  /// A load is a machine cycle assigned to a sale's service items
  /// (`saleServiceItems.machineLoadCounts`). Loads are summed across every
  /// assigned machine of every service item in an order. Voided sales are
  /// excluded.
  LoadsSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loadsSummaryProvider',
          isAutoDispose: true,
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

String _$loadsSummaryHash() => r'802eb0c8b233b38b8a59c214f817cf23c887055f';
