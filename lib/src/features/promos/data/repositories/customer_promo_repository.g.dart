// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_promo_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the CustomerPromoRepository instance.

@ProviderFor(customerPromoRepository)
final customerPromoRepositoryProvider = CustomerPromoRepositoryProvider._();

/// Provides the CustomerPromoRepository instance.

final class CustomerPromoRepositoryProvider extends $FunctionalProvider<
    CustomerPromoRepository,
    CustomerPromoRepository,
    CustomerPromoRepository> with $Provider<CustomerPromoRepository> {
  /// Provides the CustomerPromoRepository instance.
  CustomerPromoRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'customerPromoRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerPromoRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomerPromoRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CustomerPromoRepository create(Ref ref) {
    return customerPromoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerPromoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerPromoRepository>(value),
    );
  }
}

String _$customerPromoRepositoryHash() =>
    r'690294b9c8a71499056b21a6121725cadb81b11e';
