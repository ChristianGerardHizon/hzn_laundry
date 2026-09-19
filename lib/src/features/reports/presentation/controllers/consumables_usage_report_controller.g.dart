// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumables_usage_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Consumable usage for the selected report period (non-voided, non-refunded).

@ProviderFor(consumablesUsageReport)
final consumablesUsageReportProvider = ConsumablesUsageReportProvider._();

/// Consumable usage for the selected report period (non-voided, non-refunded).

final class ConsumablesUsageReportProvider extends $FunctionalProvider<
        AsyncValue<ConsumablesUsageSummaryData>,
        ConsumablesUsageSummaryData,
        FutureOr<ConsumablesUsageSummaryData>>
    with
        $FutureModifier<ConsumablesUsageSummaryData>,
        $FutureProvider<ConsumablesUsageSummaryData> {
  /// Consumable usage for the selected report period (non-voided, non-refunded).
  ConsumablesUsageReportProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'consumablesUsageReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$consumablesUsageReportHash();

  @$internal
  @override
  $FutureProviderElement<ConsumablesUsageSummaryData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ConsumablesUsageSummaryData> create(Ref ref) {
    return consumablesUsageReport(ref);
  }
}

String _$consumablesUsageReportHash() =>
    r'57a2b495f504eec98397730e12af94d46102f884';
