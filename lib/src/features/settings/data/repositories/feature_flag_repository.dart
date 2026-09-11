import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../domain/feature_flag.dart';
import '../dto/feature_flag_dto.dart';

part 'feature_flag_repository.g.dart';

abstract class FeatureFlagRepository {
  FutureEither<List<FeatureFlag>> fetchAll({String? organizationId});
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
  FutureEither<List<FeatureFlag>> fetchAll({String? organizationId}) async {
    return TaskEither.tryCatch(
      () async {
        final filter = organizationId == null || organizationId.isEmpty
            ? null
            : 'organization = "$organizationId"';
        final records = await _collection.getFullList(
          filter: filter,
          sort: 'key',
        );
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

        final response = await _pb.send(
          '/api/feature-flags/${flag.id}',
          method: 'PATCH',
          body: {'enabled': flag.enabled},
        );
        if (response is Map<String, dynamic>) {
          return FeatureFlagDto.fromJson(response).toEntity();
        }
        final record = await _collection.getOne(flag.id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}

Future<List<FeatureFlag>> _flagsForCurrentOrg(Ref ref) async {
  final orgId = ref.watch(currentOrganizationIdProvider);
  final repo = ref.watch(featureFlagRepositoryProvider);
  final result = await repo.fetchAll(organizationId: orgId);
  return result.fold((_) => const [], (flags) => flags);
}

bool _flagEnabled(
  List<FeatureFlag> flags,
  String key, {
  required bool defaultValue,
}) {
  return flags.where((f) => f.key == key).firstOrNull?.enabled ?? defaultValue;
}

@Riverpod(keepAlive: true)
Future<List<FeatureFlag>> organizationFeatureFlags(Ref ref) {
  return _flagsForCurrentOrg(ref);
}

/// Returns the enabled state of the emailUpdatesEnabled flag.
/// Defaults to true (fail open) if the flag is missing or an error occurs.
@Riverpod(keepAlive: true)
Future<bool> emailUpdatesEnabled(Ref ref) async {
  final flags = await _flagsForCurrentOrg(ref);
  return _flagEnabled(
    flags,
    FeatureFlagKeys.emailUpdatesEnabled,
    defaultValue: true,
  );
}

/// Blocks moving to Processing if any service item has no machine assigned.
/// Defaults to false (fail closed — no blocking).
@Riverpod(keepAlive: true)
Future<bool> requireMachineEnabled(Ref ref) async {
  final flags = await _flagsForCurrentOrg(ref);
  return _flagEnabled(
    flags,
    FeatureFlagKeys.requireMachine,
    defaultValue: false,
  );
}

/// Blocks moving to Ready if sale has no packs set.
/// Defaults to false (fail closed — no blocking).
@Riverpod(keepAlive: true)
Future<bool> requirePackEnabled(Ref ref) async {
  final flags = await _flagsForCurrentOrg(ref);
  return _flagEnabled(
    flags,
    FeatureFlagKeys.requirePack,
    defaultValue: false,
  );
}

/// Blocks moving to Ready if any service item has no storage assigned.
/// Defaults to false (fail closed — no blocking).
@Riverpod(keepAlive: true)
Future<bool> requireStorageEnabled(Ref ref) async {
  final flags = await _flagsForCurrentOrg(ref);
  return _flagEnabled(
    flags,
    FeatureFlagKeys.requireStorage,
    defaultValue: false,
  );
}

/// Shows consumable usage on orders. Defaults to false (fail closed).
@Riverpod(keepAlive: true)
Future<bool> consumableUsageEnabled(Ref ref) async {
  final flags = await _flagsForCurrentOrg(ref);
  return _flagEnabled(
    flags,
    FeatureFlagKeys.consumableUsage,
    defaultValue: false,
  );
}
