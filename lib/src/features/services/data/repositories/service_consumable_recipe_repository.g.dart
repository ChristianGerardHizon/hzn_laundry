// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_consumable_recipe_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serviceConsumableRecipeRepository)
final serviceConsumableRecipeRepositoryProvider =
    ServiceConsumableRecipeRepositoryProvider._();

final class ServiceConsumableRecipeRepositoryProvider
    extends $FunctionalProvider<ServiceConsumableRecipeRepository,
        ServiceConsumableRecipeRepository, ServiceConsumableRecipeRepository>
    with $Provider<ServiceConsumableRecipeRepository> {
  ServiceConsumableRecipeRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serviceConsumableRecipeRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$serviceConsumableRecipeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceConsumableRecipeRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServiceConsumableRecipeRepository create(Ref ref) {
    return serviceConsumableRecipeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceConsumableRecipeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<ServiceConsumableRecipeRepository>(value),
    );
  }
}

String _$serviceConsumableRecipeRepositoryHash() =>
    r'855ec8bbe8c83016ac1a2e53dc1660abc38bc09f';
