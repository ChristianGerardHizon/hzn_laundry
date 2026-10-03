// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_address_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(customerAddressRepository)
final customerAddressRepositoryProvider = CustomerAddressRepositoryProvider._();

final class CustomerAddressRepositoryProvider extends $FunctionalProvider<
    CustomerAddressRepository,
    CustomerAddressRepository,
    CustomerAddressRepository> with $Provider<CustomerAddressRepository> {
  CustomerAddressRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'customerAddressRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerAddressRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomerAddressRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CustomerAddressRepository create(Ref ref) {
    return customerAddressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerAddressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerAddressRepository>(value),
    );
  }
}

String _$customerAddressRepositoryHash() =>
    r'f34736c4249e431fb9f646ab639b0b9665a1e50c';
