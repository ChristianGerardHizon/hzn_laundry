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
/// opposed to laundry service items. Voided sales are excluded.

@ProviderFor(addOnsSummary)
final addOnsSummaryProvider = AddOnsSummaryProvider._();

/// Summary of add-ons (product line items) sold on the effective dashboard
/// date, aggregated per product.
///
/// Add-ons are the product line items (`saleItems`) attached to sales, as
/// opposed to laundry service items. Voided sales are excluded.

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
  /// opposed to laundry service items. Voided sales are excluded.
  AddOnsSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addOnsSummaryProvider',
          isAutoDispose: true,
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

String _$addOnsSummaryHash() => r'0b92d8ee953de4745dac222de455480810c6c4d6';
