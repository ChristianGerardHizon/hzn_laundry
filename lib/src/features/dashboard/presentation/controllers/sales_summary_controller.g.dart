// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sales summary for the effective dashboard date, including backlog sales
/// paid on that date.
///
/// Runs two parallel queries:
/// 1. All sales created on the effective date (not voided)
/// 2. Payments made on the effective date on backlog sales (created before
///    that date), with expanded sale records
///
/// Also fetches service items and sale items for all sales to display
/// in the breakdown.

@ProviderFor(salesSummary)
final salesSummaryProvider = SalesSummaryProvider._();

/// Sales summary for the effective dashboard date, including backlog sales
/// paid on that date.
///
/// Runs two parallel queries:
/// 1. All sales created on the effective date (not voided)
/// 2. Payments made on the effective date on backlog sales (created before
///    that date), with expanded sale records
///
/// Also fetches service items and sale items for all sales to display
/// in the breakdown.

final class SalesSummaryProvider extends $FunctionalProvider<
        AsyncValue<SalesSummaryData>,
        SalesSummaryData,
        FutureOr<SalesSummaryData>>
    with $FutureModifier<SalesSummaryData>, $FutureProvider<SalesSummaryData> {
  /// Sales summary for the effective dashboard date, including backlog sales
  /// paid on that date.
  ///
  /// Runs two parallel queries:
  /// 1. All sales created on the effective date (not voided)
  /// 2. Payments made on the effective date on backlog sales (created before
  ///    that date), with expanded sale records
  ///
  /// Also fetches service items and sale items for all sales to display
  /// in the breakdown.
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

String _$salesSummaryHash() => r'35b4ce4bd66f38a12553f8cd0fb18a9a35945f06';
