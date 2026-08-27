// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_locations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing storage location list state.
///
/// Storages are scoped to the current working branch. Unassigned locations
/// (no branch set) remain visible so existing org-wide records are not hidden.

@ProviderFor(StorageLocationsController)
final storageLocationsControllerProvider =
    StorageLocationsControllerProvider._();

/// Controller for managing storage location list state.
///
/// Storages are scoped to the current working branch. Unassigned locations
/// (no branch set) remain visible so existing org-wide records are not hidden.
final class StorageLocationsControllerProvider extends $AsyncNotifierProvider<
    StorageLocationsController, List<StorageLocation>> {
  /// Controller for managing storage location list state.
  ///
  /// Storages are scoped to the current working branch. Unassigned locations
  /// (no branch set) remain visible so existing org-wide records are not hidden.
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
    r'75679593e490a35b100e336ba3dbbfe7821db30a';

/// Controller for managing storage location list state.
///
/// Storages are scoped to the current working branch. Unassigned locations
/// (no branch set) remain visible so existing org-wide records are not hidden.

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
