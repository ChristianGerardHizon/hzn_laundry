// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_locations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing storage location list state.

@ProviderFor(StorageLocationsController)
final storageLocationsControllerProvider =
    StorageLocationsControllerProvider._();

/// Controller for managing storage location list state.
final class StorageLocationsControllerProvider extends $AsyncNotifierProvider<
    StorageLocationsController, List<StorageLocation>> {
  /// Controller for managing storage location list state.
  StorageLocationsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'storageLocationsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$storageLocationsControllerHash();

  @$internal
  @override
  StorageLocationsController create() => StorageLocationsController();
}

String _$storageLocationsControllerHash() =>
    r'f616e547723aab60bc86202194ae8724aa07f525';

/// Controller for managing storage location list state.

abstract class _$StorageLocationsController
    extends $AsyncNotifier<List<StorageLocation>> {
  FutureOr<List<StorageLocation>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<StorageLocation>>, List<StorageLocation>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<StorageLocation>>, List<StorageLocation>>,
        AsyncValue<List<StorageLocation>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
