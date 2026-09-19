// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_detail_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lightweight KPIs for the Orders report tab (view + count queries).

@ProviderFor(salesDetailSummary)
final salesDetailSummaryProvider = SalesDetailSummaryProvider._();

/// Lightweight KPIs for the Orders report tab (view + count queries).

final class SalesDetailSummaryProvider extends $FunctionalProvider<
        AsyncValue<OrdersReportSummary>,
        OrdersReportSummary,
        FutureOr<OrdersReportSummary>>
    with
        $FutureModifier<OrdersReportSummary>,
        $FutureProvider<OrdersReportSummary> {
  /// Lightweight KPIs for the Orders report tab (view + count queries).
  SalesDetailSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesDetailSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salesDetailSummaryHash();

  @$internal
  @override
  $FutureProviderElement<OrdersReportSummary> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OrdersReportSummary> create(Ref ref) {
    return salesDetailSummary(ref);
  }
}

String _$salesDetailSummaryHash() =>
    r'15fe7a394c8f4062659b5dad14f34152146c818f';
