// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_history_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(customerHistoryRepository)
final customerHistoryRepositoryProvider = CustomerHistoryRepositoryProvider._();

final class CustomerHistoryRepositoryProvider extends $FunctionalProvider<
    CustomerHistoryRepository,
    CustomerHistoryRepository,
    CustomerHistoryRepository> with $Provider<CustomerHistoryRepository> {
  CustomerHistoryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'customerHistoryRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomerHistoryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CustomerHistoryRepository create(Ref ref) {
    return customerHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerHistoryRepository>(value),
    );
  }
}

String _$customerHistoryRepositoryHash() =>
    r'27a923fbd63f6f1911dcda032d5b84fed237d021';
