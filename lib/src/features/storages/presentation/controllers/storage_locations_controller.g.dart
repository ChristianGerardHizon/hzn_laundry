// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_locations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing storage location list state.
///
/// Storages are scoped to the selected branch, or all branches of the current
/// organization when All Branches is selected. Blank-branch locations are
/// excluded so they cannot leak across orgs.

@ProviderFor(StorageLocationsController)
final storageLocationsControllerProvider =
    StorageLocationsControllerProvider._();

/// Controller for managing storage location list state.
///
/// Storages are scoped to the selected branch, or all branches of the current
/// organization when All Branches is selected. Blank-branch locations are
/// excluded so they cannot leak across orgs.
final class StorageLocationsControllerProvider extends $AsyncNotifierProvider<
    StorageLocationsController, List<StorageLocation>> {
  /// Controller for managing storage location list state.
  ///
  /// Storages are scoped to the selected branch, or all branches of the current
  /// organization when All Branches is selected. Blank-branch locations are
  /// excluded so they cannot leak across orgs.
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
    r'e10fe2d896edb9790c9d1bd82e539df7307b9f52';

/// Controller for managing storage location list state.
///
/// Storages are scoped to the selected branch, or all branches of the current
/// organization when All Branches is selected. Blank-branch locations are
/// excluded so they cannot leak across orgs.

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
