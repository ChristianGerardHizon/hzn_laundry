// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for all service categories.

@ProviderFor(serviceCategories)
final serviceCategoriesProvider = ServiceCategoriesProvider._();

/// Provider for all service categories.

final class ServiceCategoriesProvider extends $FunctionalProvider<
        AsyncValue<List<ServiceCategory>>,
        List<ServiceCategory>,
        FutureOr<List<ServiceCategory>>>
    with
        $FutureModifier<List<ServiceCategory>>,
        $FutureProvider<List<ServiceCategory>> {
  /// Provider for all service categories.
  ServiceCategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serviceCategoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serviceCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ServiceCategory>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceCategory>> create(Ref ref) {
    return serviceCategories(ref);
  }
}

String _$serviceCategoriesHash() => r'733b1a930d08464d1b78649b62f63f1de0858bad';
