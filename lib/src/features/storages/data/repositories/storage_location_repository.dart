import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/storage_location.dart';
import '../dto/storage_location_dto.dart';

part 'storage_location_repository.g.dart';

/// Repository interface for storage location operations.
abstract class StorageLocationRepository {
  /// Fetches all storage locations.
  FutureEither<List<StorageLocation>> fetchAll({String? filter, String? sort});

  /// Fetches a single storage location by ID.
  FutureEither<StorageLocation> fetchOne(String id);

  /// Creates a new storage location.
  FutureEither<StorageLocation> create(StorageLocation storageLocation);

  /// Updates an existing storage location.
  FutureEither<StorageLocation> update(StorageLocation storageLocation);

  /// Soft deletes a storage location by ID.
  FutureEither<void> delete(String id);
}

/// Provides the StorageLocationRepository instance.
@Riverpod(keepAlive: true)
StorageLocationRepository storageLocationRepository(Ref ref) {
  return StorageLocationRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [StorageLocationRepository] using PocketBase.
class StorageLocationRepositoryImpl implements StorageLocationRepository {
  final PocketBase _pb;

  StorageLocationRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.storages);

  StorageLocation _toEntity(RecordModel record) {
    return StorageLocationDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<StorageLocation>> fetchAll(
      {String? filter, String? sort}) async {
    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final combinedFilter =
            filter != null ? '$baseFilter && $filter' : baseFilter;

        final records = await _collection.getFullList(
          filter: combinedFilter,
          sort: sort ?? 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<StorageLocation> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Storage location ID cannot be empty',
            null,
            'invalid_storage_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<StorageLocation> create(StorageLocation storageLocation) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': storageLocation.name,
          'branch': storageLocation.branchId,
          'isAvailable': storageLocation.isAvailable,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<StorageLocation> update(StorageLocation storageLocation) async {
    return TaskEither.tryCatch(
      () async {
        if (storageLocation.id.isEmpty) {
          throw const DataFailure(
            'Storage location ID cannot be empty',
            null,
            'invalid_storage_id',
          );
        }

        final body = <String, dynamic>{
          'name': storageLocation.name,
          'branch': storageLocation.branchId,
          'isAvailable': storageLocation.isAvailable,
        };

        final record =
            await _collection.update(storageLocation.id, body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Storage location ID cannot be empty',
            null,
            'invalid_storage_id',
          );
        }

        // Soft delete
        await _collection.update(id, body: {'isDeleted': true});
      },
      Failure.handle,
    ).run();
  }
}
