import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/machine.dart';
import '../dto/machine_dto.dart';

part 'machine_repository.g.dart';

/// Repository interface for machine operations.
abstract class MachineRepository {
  /// Fetches all machines.
  FutureEither<List<Machine>> fetchAll({String? filter, String? sort});

  /// Fetches a single machine by ID.
  FutureEither<Machine> fetchOne(String id);

  /// Creates a new machine.
  FutureEither<Machine> create(Machine machine);

  /// Updates an existing machine.
  FutureEither<Machine> update(Machine machine);

  /// Soft deletes a machine by ID.
  FutureEither<void> delete(String id);
}

/// Provides the MachineRepository instance.
@Riverpod(keepAlive: true)
MachineRepository machineRepository(Ref ref) {
  return MachineRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [MachineRepository] using PocketBase.
class MachineRepositoryImpl implements MachineRepository {
  final PocketBase _pb;

  MachineRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.machines);

  Machine _toEntity(RecordModel record) {
    return MachineDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<Machine>> fetchAll({String? filter, String? sort}) async {
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
  FutureEither<Machine> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Machine ID cannot be empty',
            null,
            'invalid_machine_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Machine> create(Machine machine) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': machine.name,
          'type': machine.type.name,
          'size': machine.size?.name ?? '',
          'branch': machine.branchId,
          'isAvailable': machine.isAvailable,
          'strictSingleUse': machine.strictSingleUse,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Machine> update(Machine machine) async {
    return TaskEither.tryCatch(
      () async {
        if (machine.id.isEmpty) {
          throw const DataFailure(
            'Machine ID cannot be empty',
            null,
            'invalid_machine_id',
          );
        }

        final body = <String, dynamic>{
          'name': machine.name,
          'type': machine.type.name,
          'size': machine.size?.name ?? '',
          'branch': machine.branchId,
          'isAvailable': machine.isAvailable,
          'strictSingleUse': machine.strictSingleUse,
        };

        final record = await _collection.update(machine.id, body: body);
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
            'Machine ID cannot be empty',
            null,
            'invalid_machine_id',
          );
        }

        // Soft delete
        await _collection.update(id, body: {'isDeleted': true});
      },
      Failure.handle,
    ).run();
  }
}
