// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_selling_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Top 5 selling products (all-time, aggregated from date-grouped view).
///
/// Queries [PocketBaseCollections.vwTopSellingProducts], aggregates rows
/// by product (since the view groups by date), sorts by revenue descending,
/// and returns the top 5.

@ProviderFor(topSellingProducts)
final topSellingProductsProvider = TopSellingProductsProvider._();

/// Top 5 selling products (all-time, aggregated from date-grouped view).
///
/// Queries [PocketBaseCollections.vwTopSellingProducts], aggregates rows
/// by product (since the view groups by date), sorts by revenue descending,
/// and returns the top 5.

final class TopSellingProductsProvider extends $FunctionalProvider<
        AsyncValue<List<TopSellingItem>>,
        List<TopSellingItem>,
        FutureOr<List<TopSellingItem>>>
    with
        $FutureModifier<List<TopSellingItem>>,
        $FutureProvider<List<TopSellingItem>> {
  /// Top 5 selling products (all-time, aggregated from date-grouped view).
  ///
  /// Queries [PocketBaseCollections.vwTopSellingProducts], aggregates rows
  /// by product (since the view groups by date), sorts by revenue descending,
  /// and returns the top 5.
  TopSellingProductsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'topSellingProductsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$topSellingProductsHash();

  @$internal
  @override
  $FutureProviderElement<List<TopSellingItem>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<TopSellingItem>> create(Ref ref) {
    return topSellingProducts(ref);
  }
}

String _$topSellingProductsHash() =>
    r'e27a0df07a2f653a99a9b5fa44c0ac2b7aac96b0';

/// Top 5 selling services (all-time, aggregated from date-grouped view).
///
/// Queries [PocketBaseCollections.vwTopSellingServices], aggregates rows
/// by service (since the view groups by date), sorts by revenue descending,
/// and returns the top 5.

@ProviderFor(topSellingServices)
final topSellingServicesProvider = TopSellingServicesProvider._();

/// Top 5 selling services (all-time, aggregated from date-grouped view).
///
/// Queries [PocketBaseCollections.vwTopSellingServices], aggregates rows
/// by service (since the view groups by date), sorts by revenue descending,
/// and returns the top 5.

final class TopSellingServicesProvider extends $FunctionalProvider<
        AsyncValue<List<TopSellingItem>>,
        List<TopSellingItem>,
        FutureOr<List<TopSellingItem>>>
    with
        $FutureModifier<List<TopSellingItem>>,
        $FutureProvider<List<TopSellingItem>> {
  /// Top 5 selling services (all-time, aggregated from date-grouped view).
  ///
  /// Queries [PocketBaseCollections.vwTopSellingServices], aggregates rows
  /// by service (since the view groups by date), sorts by revenue descending,
  /// and returns the top 5.
  TopSellingServicesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'topSellingServicesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$topSellingServicesHash();

  @$internal
  @override
  $FutureProviderElement<List<TopSellingItem>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<TopSellingItem>> create(Ref ref) {
    return topSellingServices(ref);
  }
}

String _$topSellingServicesHash() =>
    r'5260178ae662e9beb139d17017a7c42304a78c26';
