// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_location_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the StorageLocationRepository instance.

@ProviderFor(storageLocationRepository)
final storageLocationRepositoryProvider = StorageLocationRepositoryProvider._();

/// Provides the StorageLocationRepository instance.

final class StorageLocationRepositoryProvider extends $FunctionalProvider<
    StorageLocationRepository,
    StorageLocationRepository,
    StorageLocationRepository> with $Provider<StorageLocationRepository> {
  /// Provides the StorageLocationRepository instance.
  StorageLocationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'storageLocationRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$storageLocationRepositoryHash();

  @$internal
  @override
  $ProviderElement<StorageLocationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StorageLocationRepository create(Ref ref) {
    return storageLocationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageLocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageLocationRepository>(value),
    );
  }
}

String _$storageLocationRepositoryHash() =>
    r'a76a2f3fd7a8398916686d757d062ddf1b86039d';
