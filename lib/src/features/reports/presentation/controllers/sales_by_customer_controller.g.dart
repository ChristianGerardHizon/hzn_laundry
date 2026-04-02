// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_by_customer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches sales by customer from the [vw_sales_by_customer] view.
///
/// Uses branch filter on the query, then filters by date range in Dart
/// (view date fields are JSON type, not filterable via PB date operators).

@ProviderFor(salesByCustomer)
final salesByCustomerProvider = SalesByCustomerProvider._();

/// Fetches sales by customer from the [vw_sales_by_customer] view.
///
/// Uses branch filter on the query, then filters by date range in Dart
/// (view date fields are JSON type, not filterable via PB date operators).

final class SalesByCustomerProvider extends $FunctionalProvider<
        AsyncValue<List<CustomerSalesEntry>>,
        List<CustomerSalesEntry>,
        FutureOr<List<CustomerSalesEntry>>>
    with
        $FutureModifier<List<CustomerSalesEntry>>,
        $FutureProvider<List<CustomerSalesEntry>> {
  /// Fetches sales by customer from the [vw_sales_by_customer] view.
  ///
  /// Uses branch filter on the query, then filters by date range in Dart
  /// (view date fields are JSON type, not filterable via PB date operators).
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

String _$salesByCustomerHash() => r'e997603d2b86fbe3ebbe039a036a2b456ea7cd23';
