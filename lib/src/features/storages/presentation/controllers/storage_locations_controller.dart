import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/storage_location_repository.dart';
import '../../domain/storage_location.dart';

part 'storage_locations_controller.g.dart';

/// Controller for managing storage location list state.
///
/// Storages are scoped to the current working branch. Unassigned locations
/// (no branch set) remain visible so existing org-wide records are not hidden.
@Riverpod(keepAlive: true)
class StorageLocationsController extends _$StorageLocationsController {
  StorageLocationRepository get _repository =>
      ref.read(storageLocationRepositoryProvider);

  String? get _branchFilter => PBFilters.forBranchIncludingUnassigned(
        ref.read(currentBranchIdProvider),
      );

  @override
  Future<List<StorageLocation>> build() async {
    ref.watch(currentBranchIdProvider);
    final result = await _repository.fetchAll(filter: _branchFilter);
    return result.fold(
      (failure) => throw failure,
      (storages) => storages,
    );
  }

  /// Refreshes the storage location list.
  Future<void> refresh() async {
    state = const AsyncLoading();

    final result = await _repository.fetchAll(filter: _branchFilter);

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
