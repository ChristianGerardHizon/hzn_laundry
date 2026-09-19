// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_by_customer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Raw daily rows from [vw_sales_by_customer] for the current branch scope.
///
/// Kept alive so changing the date range does not re-download the full view.

@ProviderFor(salesByCustomerRaw)
final salesByCustomerRawProvider = SalesByCustomerRawProvider._();

/// Raw daily rows from [vw_sales_by_customer] for the current branch scope.
///
/// Kept alive so changing the date range does not re-download the full view.

final class SalesByCustomerRawProvider extends $FunctionalProvider<
        AsyncValue<List<RecordModel>>,
        List<RecordModel>,
        FutureOr<List<RecordModel>>>
    with
        $FutureModifier<List<RecordModel>>,
        $FutureProvider<List<RecordModel>> {
  /// Raw daily rows from [vw_sales_by_customer] for the current branch scope.
  ///
  /// Kept alive so changing the date range does not re-download the full view.
  SalesByCustomerRawProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesByCustomerRawProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salesByCustomerRawHash();

  @$internal
  @override
  $FutureProviderElement<List<RecordModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecordModel>> create(Ref ref) {
    return salesByCustomerRaw(ref);
  }
}

String _$salesByCustomerRawHash() =>
    r'44e5a8ef4264388b7552e3e70e2897f595cd42ac';

/// Aggregates cached view rows into per-customer totals for the selected range.

@ProviderFor(salesByCustomer)
final salesByCustomerProvider = SalesByCustomerProvider._();

/// Aggregates cached view rows into per-customer totals for the selected range.

final class SalesByCustomerProvider extends $FunctionalProvider<
        AsyncValue<List<CustomerSalesEntry>>,
        List<CustomerSalesEntry>,
        FutureOr<List<CustomerSalesEntry>>>
    with
        $FutureModifier<List<CustomerSalesEntry>>,
        $FutureProvider<List<CustomerSalesEntry>> {
  /// Aggregates cached view rows into per-customer totals for the selected range.
  SalesByCustomerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salesByCustomerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salesByCustomerHash();

  @$internal
  @override
  $FutureProviderElement<List<CustomerSalesEntry>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomerSalesEntry>> create(Ref ref) {
    return salesByCustomer(ref);
  }
}

String _$salesByCustomerHash() => r'56de7f3975b46f6e2d14fe6f762bfc6bb64749b4';
