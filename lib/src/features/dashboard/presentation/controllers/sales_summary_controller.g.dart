// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sales summary for the effective dashboard date.
///
/// Totals are intentionally separated:
/// - Total Sales: all orders created on the effective date
/// - Payments Received: all money posted on the effective date
/// - Outstanding: remaining balance for orders created on the effective date

@ProviderFor(salesSummary)
final salesSummaryProvider = SalesSummaryProvider._();

/// Sales summary for the effective dashboard date.
///
/// Totals are intentionally separated:
/// - Total Sales: all orders created on the effective date
/// - Payments Received: all money posted on the effective date
/// - Outstanding: remaining balance for orders created on the effective date

final class SalesSummaryProvider extends $FunctionalProvider<
        AsyncValue<SalesSummaryData>,
        SalesSummaryData,
        FutureOr<SalesSummaryData>>
    with $FutureModifier<SalesSummaryData>, $FutureProvider<SalesSummaryData> {
  /// Sales summary for the effective dashboard date.
  ///
  /// Totals are intentionally separated:
  /// - Total Sales: all orders created on the effective date
  /// - Payments Received: all money posted on the effective date
  /// - Outstanding: remaining balance for orders created on the effective date
  SalesSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salesSummaryHash();

  @$internal
  @override
  $FutureProviderElement<SalesSummaryData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SalesSummaryData> create(Ref ref) {
    return salesSummary(ref);
  }
}

String _$salesSummaryHash() => r'769a4b8c256597d449cf66a24657e166375658fc';
