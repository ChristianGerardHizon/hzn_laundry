// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_service_items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching sale service items by sale ID.

@ProviderFor(saleServiceItems)
final saleServiceItemsProvider = SaleServiceItemsFamily._();

/// Provider for fetching sale service items by sale ID.

final class SaleServiceItemsProvider extends $FunctionalProvider<
        AsyncValue<List<SaleServiceItem>>,
        List<SaleServiceItem>,
        FutureOr<List<SaleServiceItem>>>
    with
        $FutureModifier<List<SaleServiceItem>>,
        $FutureProvider<List<SaleServiceItem>> {
  /// Provider for fetching sale service items by sale ID.
  SaleServiceItemsProvider._(
      {required SaleServiceItemsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'saleServiceItemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$saleServiceItemsHash();

  @override
  String toString() {
    return r'saleServiceItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SaleServiceItem>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SaleServiceItem>> create(Ref ref) {
    final argument = this.argument as String;
    return saleServiceItems(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleServiceItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleServiceItemsHash() => r'0c41e463b6f1b4f86beac811cddc690f7810b205';

/// Provider for fetching sale service items by sale ID.

final class SaleServiceItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SaleServiceItem>>, String> {
  SaleServiceItemsFamily._()
      : super(
          retry: null,
          name: r'saleServiceItemsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for fetching sale service items by sale ID.

  SaleServiceItemsProvider call(
    String saleId,
  ) =>
      SaleServiceItemsProvider._(argument: saleId, from: this);

  @override
  String toString() => r'saleServiceItemsProvider';
}
