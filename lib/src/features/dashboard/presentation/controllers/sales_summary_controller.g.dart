// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's sales summary including backlog sales paid today.
///
/// Runs two parallel queries:
/// 1. All sales created today (not voided)
/// 2. Payments made today on backlog sales (created before today), with
///    expanded sale records
///
/// Also fetches service items and sale items for all sales to display
/// in the breakdown.

@ProviderFor(salesSummary)
final salesSummaryProvider = SalesSummaryProvider._();

/// Today's sales summary including backlog sales paid today.
///
/// Runs two parallel queries:
/// 1. All sales created today (not voided)
/// 2. Payments made today on backlog sales (created before today), with
///    expanded sale records
///
/// Also fetches service items and sale items for all sales to display
/// in the breakdown.

final class SalesSummaryProvider extends $FunctionalProvider<
        AsyncValue<SalesSummaryData>,
        SalesSummaryData,
        FutureOr<SalesSummaryData>>
    with $FutureModifier<SalesSummaryData>, $FutureProvider<SalesSummaryData> {
  /// Today's sales summary including backlog sales paid today.
  ///
  /// Runs two parallel queries:
  /// 1. All sales created today (not voided)
  /// 2. Payments made today on backlog sales (created before today), with
  ///    expanded sale records
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

String _$salesSummaryHash() => r'0f914862af114342aba7f496b33749dde45a0446';
