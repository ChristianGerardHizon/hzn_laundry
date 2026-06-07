import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/load_rule.dart';
import '../dto/load_rule_dto.dart';

part 'load_rule_repository.g.dart';

/// Repository interface for machine load-rule operations.
abstract class LoadRuleRepository {
  /// Fetches all active load rules for a machine, sorted by [minWeight].
  FutureEither<List<LoadRule>> fetchForMachine(String machineId);

  /// Creates a new load rule.
  FutureEither<LoadRule> create(LoadRule rule);

  /// Updates an existing load rule.
  FutureEither<LoadRule> update(LoadRule rule);

  /// Soft deletes a load rule by ID.
  FutureEither<void> delete(String id);

  /// Copies all active rules from [sourceMachineId] to each machine in
  /// [targetMachineIds]. Returns the number of rules created.
  FutureEither<int> copyRulesToMachines(
    String sourceMachineId,
    List<String> targetMachineIds,
  );
}

/// Provides the LoadRuleRepository instance.
@Riverpod(keepAlive: true)
LoadRuleRepository loadRuleRepository(Ref ref) {
  return LoadRuleRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [LoadRuleRepository] using PocketBase.
class LoadRuleRepositoryImpl implements LoadRuleRepository {
  final PocketBase _pb;

  LoadRuleRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.machineLoadRules);

  LoadRule _toEntity(RecordModel record) {
    return LoadRuleDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<LoadRule>> fetchForMachine(String machineId) async {
    return TaskEither.tryCatch(
      () async {
        if (machineId.isEmpty) {
          throw const DataFailure(
            'Machine ID cannot be empty',
            null,
            'invalid_machine_id',
          );
        }

        final baseFilter = PBFilters.active.build();
        final records = await _collection.getFullList(
          filter: '$baseFilter && machine = "$machineId"',
          sort: 'minWeight',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<LoadRule> create(LoadRule rule) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.create(body: LoadRuleDto.toBody(rule));
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<LoadRule> update(LoadRule rule) async {
    return TaskEither.tryCatch(
      () async {
        if (rule.id.isEmpty) {
          throw const DataFailure(
            'Load rule ID cannot be empty',
            null,
            'invalid_load_rule_id',
          );
        }

        final record =
            await _collection.update(rule.id, body: LoadRuleDto.toBody(rule));
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
            'Load rule ID cannot be empty',
            null,
            'invalid_load_rule_id',
          );
        }

        // Soft delete
        await _collection.update(id, body: {'isDeleted': true});
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<int> copyRulesToMachines(
    String sourceMachineId,
    List<String> targetMachineIds,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final sourceRecords = await _collection.getFullList(
          filter: '$baseFilter && machine = "$sourceMachineId"',
          sort: 'minWeight',
        );
        final sourceRules = sourceRecords.map(_toEntity).toList();

        var created = 0;
        for (final targetId in targetMachineIds) {
          if (targetId == sourceMachineId) continue;
          for (final rule in sourceRules) {
            await _collection.create(
              body: LoadRuleDto.toBody(
                LoadRule(
                  id: '',
                  machineId: targetId,
                  loadCount: rule.loadCount,
                  minWeight: rule.minWeight,
                  maxWeight: rule.maxWeight,
                ),
              ),
            );
            created++;
          }
        }
        return created;
      },
      Failure.handle,
    ).run();
  }
}
