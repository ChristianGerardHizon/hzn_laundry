// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the CustomerRepository instance.

@ProviderFor(customerRepository)
final customerRepositoryProvider = CustomerRepositoryProvider._();

/// Provides the CustomerRepository instance.

final class CustomerRepositoryProvider extends $FunctionalProvider<
    CustomerRepository,
    CustomerRepository,
    CustomerRepository> with $Provider<CustomerRepository> {
  /// Provides the CustomerRepository instance.
  CustomerRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'customerRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomerRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CustomerRepository create(Ref ref) {
    return customerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerRepository>(value),
    );
  }
}

String _$customerRepositoryHash() =>
    r'9ab9cae462242de1472db6a01be89777f02ebbb1';
