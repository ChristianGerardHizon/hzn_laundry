// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumables_usage_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's consumable usage, aggregated per product.
///
/// Uses the same non-voided sales as [salesSummary]. Cost visibility is a
/// UI concern (`usage.cost.view`).

@ProviderFor(consumablesUsageSummary)
final consumablesUsageSummaryProvider = ConsumablesUsageSummaryProvider._();

/// Today's consumable usage, aggregated per product.
///
/// Uses the same non-voided sales as [salesSummary]. Cost visibility is a
/// UI concern (`usage.cost.view`).

final class ConsumablesUsageSummaryProvider extends $FunctionalProvider<
        AsyncValue<ConsumablesUsageSummaryData>,
        ConsumablesUsageSummaryData,
        FutureOr<ConsumablesUsageSummaryData>>
    with
        $FutureModifier<ConsumablesUsageSummaryData>,
        $FutureProvider<ConsumablesUsageSummaryData> {
  /// Today's consumable usage, aggregated per product.
  ///
  /// Uses the same non-voided sales as [salesSummary]. Cost visibility is a
  /// UI concern (`usage.cost.view`).
  ConsumablesUsageSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'consumablesUsageSummaryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$consumablesUsageSummaryHash();

  @$internal
  @override
  $FutureProviderElement<ConsumablesUsageSummaryData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ConsumablesUsageSummaryData> create(Ref ref) {
    return consumablesUsageSummary(ref);
  }
}

String _$consumablesUsageSummaryHash() =>
    r'8dbe28fef539da125e4368bbd61835740e55747b';
