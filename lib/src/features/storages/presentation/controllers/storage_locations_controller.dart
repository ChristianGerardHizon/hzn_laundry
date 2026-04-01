import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/storage_location_repository.dart';
import '../../domain/storage_location.dart';

part 'storage_locations_controller.g.dart';

/// Controller for managing storage location list state.
@Riverpod(keepAlive: true)
class StorageLocationsController extends _$StorageLocationsController {
  StorageLocationRepository get _repository =>
      ref.read(storageLocationRepositoryProvider);

  @override
  Future<List<StorageLocation>> build() async {
    final result = await _repository.fetchAll();
    return result.fold(
      (failure) => throw failure,
      (storages) => storages,
    );
  }

  /// Refreshes the storage location list.
  Future<void> refresh() async {
    state = const AsyncLoading();

    final result = await _repository.fetchAll();

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (storages) => AsyncData(storages),
    );
  }

  /// Creates a new storage location.
  Future<bool> createStorageLocation(StorageLocation storageLocation) async {
    final result = await _repository.create(storageLocation);

    return result.fold(
      (failure) => false,
      (newStorage) {
        final currentList = state.value ?? [];
        state = AsyncData([newStorage, ...currentList]);
        return true;
      },
    );
  }

  /// Updates an existing storage location.
  Future<bool> updateStorageLocation(StorageLocation storageLocation) async {
    final result = await _repository.update(storageLocation);

    return result.fold(
      (failure) => false,
      (updatedStorage) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((s) {
          return s.id == updatedStorage.id ? updatedStorage : s;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Deletes a storage location (soft delete).
  Future<bool> deleteStorageLocation(String id) async {
    final result = await _repository.delete(id);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.where((s) => s.id != id).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }
}
