// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the ServiceRepository instance.

@ProviderFor(serviceRepository)
final serviceRepositoryProvider = ServiceRepositoryProvider._();

/// Provides the ServiceRepository instance.

final class ServiceRepositoryProvider extends $FunctionalProvider<
    ServiceRepository,
    ServiceRepository,
    ServiceRepository> with $Provider<ServiceRepository> {
  /// Provides the ServiceRepository instance.
  ServiceRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serviceRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serviceRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServiceRepository create(Ref ref) {
    return serviceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceRepository>(value),
    );
  }
}

String _$serviceRepositoryHash() => r'3673946496be5ea487fb602ac82224a6d96ef4ce';
