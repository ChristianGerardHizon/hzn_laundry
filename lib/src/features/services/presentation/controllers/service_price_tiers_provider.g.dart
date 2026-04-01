// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_price_tiers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all price tiers for a given service, sorted by minQuantity.

@ProviderFor(servicePriceTiers)
final servicePriceTiersProvider = ServicePriceTiersFamily._();

/// Fetches all price tiers for a given service, sorted by minQuantity.

final class ServicePriceTiersProvider extends $FunctionalProvider<
        AsyncValue<List<ServicePriceTier>>,
        List<ServicePriceTier>,
        FutureOr<List<ServicePriceTier>>>
    with
        $FutureModifier<List<ServicePriceTier>>,
        $FutureProvider<List<ServicePriceTier>> {
  /// Fetches all price tiers for a given service, sorted by minQuantity.
  ServicePriceTiersProvider._(
      {required ServicePriceTiersFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'servicePriceTiersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$servicePriceTiersHash();

  @override
  String toString() {
    return r'servicePriceTiersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ServicePriceTier>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServicePriceTier>> create(Ref ref) {
    final argument = this.argument as String;
    return servicePriceTiers(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ServicePriceTiersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$servicePriceTiersHash() => r'df7906752e079da0d31e608472c5d6e77e3de8e6';

/// Fetches all price tiers for a given service, sorted by minQuantity.

final class ServicePriceTiersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ServicePriceTier>>, String> {
  ServicePriceTiersFamily._()
      : super(
          retry: null,
          name: r'servicePriceTiersProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches all price tiers for a given service, sorted by minQuantity.

  ServicePriceTiersProvider call(
    String serviceId,
  ) =>
      ServicePriceTiersProvider._(argument: serviceId, from: this);

  @override
  String toString() => r'servicePriceTiersProvider';
}
