// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_ons_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Summary of add-ons (product line items) sold on the effective dashboard
/// date, aggregated per product.
///
/// Add-ons are the product line items (`saleItems`) attached to sales, as
/// opposed to laundry service items. The `vw_add_ons_summary` view collapses
/// each sale's line items to one row per (sale, product) carrying the sale's
/// branch + postedDate, so this provider range-filters by the day and folds
/// the rows per product. Voided sales are excluded by the view.

@ProviderFor(addOnsSummary)
final addOnsSummaryProvider = AddOnsSummaryProvider._();

/// Summary of add-ons (product line items) sold on the effective dashboard
/// date, aggregated per product.
///
/// Add-ons are the product line items (`saleItems`) attached to sales, as
/// opposed to laundry service items. The `vw_add_ons_summary` view collapses
/// each sale's line items to one row per (sale, product) carrying the sale's
/// branch + postedDate, so this provider range-filters by the day and folds
/// the rows per product. Voided sales are excluded by the view.

final class AddOnsSummaryProvider extends $FunctionalProvider<
        AsyncValue<AddOnsSummaryData>,
        AddOnsSummaryData,
        FutureOr<AddOnsSummaryData>>
    with
        $FutureModifier<AddOnsSummaryData>,
        $FutureProvider<AddOnsSummaryData> {
  /// Summary of add-ons (product line items) sold on the effective dashboard
  /// date, aggregated per product.
  ///
  /// Add-ons are the product line items (`saleItems`) attached to sales, as
  /// opposed to laundry service items. The `vw_add_ons_summary` view collapses
  /// each sale's line items to one row per (sale, product) carrying the sale's
  /// branch + postedDate, so this provider range-filters by the day and folds
  /// the rows per product. Voided sales are excluded by the view.
  AddOnsSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addOnsSummaryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addOnsSummaryHash();

  @$internal
  @override
  $FutureProviderElement<AddOnsSummaryData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AddOnsSummaryData> create(Ref ref) {
    return addOnsSummary(ref);
  }
}

String _$addOnsSummaryHash() => r'6b1e3649469d20f53d047ea0a62daae3e0a875ba';
