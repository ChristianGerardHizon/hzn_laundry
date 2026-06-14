import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/feature_flag.dart';
import '../dto/feature_flag_dto.dart';

part 'feature_flag_repository.g.dart';

abstract class FeatureFlagRepository {
  FutureEither<List<FeatureFlag>> fetchAll();
  FutureEither<FeatureFlag> update(FeatureFlag flag);
}

@Riverpod(keepAlive: true)
FeatureFlagRepository featureFlagRepository(Ref ref) {
  return FeatureFlagRepositoryImpl(ref.watch(pocketbaseProvider));
}

class FeatureFlagRepositoryImpl implements FeatureFlagRepository {
  FeatureFlagRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.featureFlags);

  FeatureFlag _toEntity(RecordModel record) {
    return FeatureFlagDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<FeatureFlag>> fetchAll() async {
    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(sort: 'key');
        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<FeatureFlag> update(FeatureFlag flag) async {
    return TaskEither.tryCatch(
      () async {
        if (flag.id.isEmpty) {
          throw const DataFailure(
            'FeatureFlag ID cannot be empty',
            null,
            'invalid_feature_flag_id',
          );
        }

        final record = await _collection.update(
          flag.id,
          body: {'enabled': flag.enabled},
        );
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}

/// Returns the enabled state of the emailUpdatesEnabled flag.
/// Defaults to true (fail open) if the flag is missing or an error occurs.
@Riverpod(keepAlive: true)
Future<bool> emailUpdatesEnabled(Ref ref) async {
  final repo = ref.watch(featureFlagRepositoryProvider);
  final result = await repo.fetchAll();
  return result.fold(
    (_) => true,
    (flags) {
      final flag = flags.where((f) => f.key == 'emailUpdatesEnabled').firstOrNull;
      return flag?.enabled ?? true;
    },
  );
}

/// Blocks moving to Processing if any service item has no machine assigned.
/// Defaults to false (fail open — no blocking).
@Riverpod(keepAlive: true)
Future<bool> requireMachineEnabled(Ref ref) async {
  final repo = ref.watch(featureFlagRepositoryProvider);
  final result = await repo.fetchAll();
  return result.fold(
    (_) => false,
    (flags) => flags.where((f) => f.key == 'requireMachine').firstOrNull?.enabled ?? false,
  );
}

/// Blocks moving to Ready if sale has no packs set.
/// Defaults to false (fail open — no blocking).
@Riverpod(keepAlive: true)
Future<bool> requirePackEnabled(Ref ref) async {
  final repo = ref.watch(featureFlagRepositoryProvider);
  final result = await repo.fetchAll();
  return result.fold(
    (_) => false,
    (flags) => flags.where((f) => f.key == 'requirePack').firstOrNull?.enabled ?? false,
  );
}

/// Blocks moving to Ready if any service item has no storage assigned.
/// Defaults to false (fail open — no blocking).
@Riverpod(keepAlive: true)
Future<bool> requireStorageEnabled(Ref ref) async {
  final repo = ref.watch(featureFlagRepositoryProvider);
  final result = await repo.fetchAll();
  return result.fold(
    (_) => false,
    (flags) => flags.where((f) => f.key == 'requireStorage').firstOrNull?.enabled ?? false,
  );
}
