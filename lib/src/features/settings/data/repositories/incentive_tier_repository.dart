import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/incentive_tier.dart';
import '../dto/incentive_tier_dto.dart';

part 'incentive_tier_repository.g.dart';

/// Repository interface for incentive tier operations.
abstract class IncentiveTierRepository {
  /// Fetches all incentive tiers for a branch, sorted by sortOrder.
  FutureEither<List<IncentiveTier>> fetchForBranch(String branchId);

  /// Creates a new incentive tier.
  FutureEither<IncentiveTier> create({
    required String branchId,
    required num minAmount,
    num? maxAmount,
    required num incentiveAmount,
    required int sortOrder,
  });

  /// Updates an existing incentive tier.
  FutureEither<IncentiveTier> update({
    required String id,
    required num minAmount,
    num? maxAmount,
    required num incentiveAmount,
    required int sortOrder,
  });

  /// Deletes an incentive tier.
  FutureEither<void> delete(String id);

  /// Replaces all tiers for a branch with the given list.
  FutureEither<List<IncentiveTier>> replaceTiers({
    required String branchId,
    required List<IncentiveTierData> tiers,
  });
}

/// Data class for creating/updating a tier (without ID).
class IncentiveTierData {
  const IncentiveTierData({
    this.id,
    required this.minAmount,
    this.maxAmount,
    required this.incentiveAmount,
    required this.sortOrder,
  });

  final String? id;
  final num minAmount;
  final num? maxAmount;
  final num incentiveAmount;
  final int sortOrder;
}

/// Provides the IncentiveTierRepository instance.
@Riverpod(keepAlive: true)
IncentiveTierRepository incentiveTierRepository(Ref ref) {
  return IncentiveTierRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [IncentiveTierRepository] using PocketBase.
class IncentiveTierRepositoryImpl implements IncentiveTierRepository {
  final PocketBase _pb;

  IncentiveTierRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.incentiveTiers);

  IncentiveTier _toEntity(RecordModel record) {
    return IncentiveTierDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<IncentiveTier>> fetchForBranch(String branchId) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter().relation('branch', branchId).build();
        final records = await _collection.getFullList(
          filter: filter,
          sort: 'sortOrder',
        );
        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<IncentiveTier> create({
    required String branchId,
    required num minAmount,
    num? maxAmount,
    required num incentiveAmount,
    required int sortOrder,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'branch': branchId,
          'minAmount': minAmount,
          'maxAmount': maxAmount ?? 0,
          'incentiveAmount': incentiveAmount,
          'sortOrder': sortOrder,
        };
        final record = await _collection.create(body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<IncentiveTier> update({
    required String id,
    required num minAmount,
    num? maxAmount,
    required num incentiveAmount,
    required int sortOrder,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'minAmount': minAmount,
          'maxAmount': maxAmount ?? 0,
          'incentiveAmount': incentiveAmount,
          'sortOrder': sortOrder,
        };
        final record = await _collection.update(id, body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        await _collection.delete(id);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<IncentiveTier>> replaceTiers({
    required String branchId,
    required List<IncentiveTierData> tiers,
  }) async {
    return TaskEither.tryCatch(
      () async {
        // Fetch existing tiers
        final filter = PBFilter().relation('branch', branchId).build();
        final existing = await _collection.getFullList(filter: filter);
        final existingIds = existing.map((r) => r.id).toSet();

        // Determine which to keep, create, delete
        final incomingIds = tiers
            .where((t) => t.id != null && t.id!.isNotEmpty)
            .map((t) => t.id!)
            .toSet();
        final toDelete = existingIds.difference(incomingIds);

        // Delete removed tiers
        for (final id in toDelete) {
          await _collection.delete(id);
        }

        // Create or update tiers
        final results = <IncentiveTier>[];
        for (final tier in tiers) {
          final body = <String, dynamic>{
            'branch': branchId,
            'minAmount': tier.minAmount,
            'maxAmount': tier.maxAmount ?? 0,
            'incentiveAmount': tier.incentiveAmount,
            'sortOrder': tier.sortOrder,
          };

          RecordModel record;
          if (tier.id != null &&
              tier.id!.isNotEmpty &&
              existingIds.contains(tier.id)) {
            record = await _collection.update(tier.id!, body: body);
          } else {
            record = await _collection.create(body: body);
          }
          results.add(_toEntity(record));
        }

        return results;
      },
      Failure.handle,
    ).run();
  }
}
