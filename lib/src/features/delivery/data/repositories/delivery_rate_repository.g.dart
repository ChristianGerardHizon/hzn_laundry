// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_rate_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deliveryRateRepository)
final deliveryRateRepositoryProvider = DeliveryRateRepositoryProvider._();

final class DeliveryRateRepositoryProvider extends $FunctionalProvider<
    DeliveryRateRepository,
    DeliveryRateRepository,
    DeliveryRateRepository> with $Provider<DeliveryRateRepository> {
  DeliveryRateRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deliveryRateRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deliveryRateRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeliveryRateRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeliveryRateRepository create(Ref ref) {
    return deliveryRateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeliveryRateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeliveryRateRepository>(value),
    );
  }
}

String _$deliveryRateRepositoryHash() =>
    r'71dc30a91d46813d181e9bb5ef631a103205b822';
