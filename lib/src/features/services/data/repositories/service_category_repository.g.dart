// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_category_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the ServiceCategoryRepository instance.

@ProviderFor(serviceCategoryRepository)
final serviceCategoryRepositoryProvider = ServiceCategoryRepositoryProvider._();

/// Provides the ServiceCategoryRepository instance.

final class ServiceCategoryRepositoryProvider extends $FunctionalProvider<
    ServiceCategoryRepository,
    ServiceCategoryRepository,
    ServiceCategoryRepository> with $Provider<ServiceCategoryRepository> {
  /// Provides the ServiceCategoryRepository instance.
  ServiceCategoryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serviceCategoryRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serviceCategoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceCategoryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServiceCategoryRepository create(Ref ref) {
    return serviceCategoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceCategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceCategoryRepository>(value),
    );
  }
}

String _$serviceCategoryRepositoryHash() =>
    r'939ffa00c445d005fd707c2e9ef0c49339930a10';
