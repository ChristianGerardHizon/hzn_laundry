import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/quantity_unit.dart';
import '../dto/quantity_unit_dto.dart';

part 'quantity_unit_repository.g.dart';

/// Repository interface for quantity unit operations.
abstract class QuantityUnitRepository {
  /// Fetches all quantity units.
  FutureEither<List<QuantityUnit>> fetchAll({String? filter, String? sort});

  /// Fetches a single quantity unit by ID.
  FutureEither<QuantityUnit> fetchOne(String id);

  /// Creates a new quantity unit.
  FutureEither<QuantityUnit> create(QuantityUnit unit);

  /// Updates an existing quantity unit.
  FutureEither<QuantityUnit> update(QuantityUnit unit);

  /// Soft deletes a quantity unit by ID.
  FutureEither<void> delete(String id);

  /// Invalidates the quantity unit list cache.
  void invalidateCache();
}

/// Provides the QuantityUnitRepository instance.
@Riverpod(keepAlive: true)
QuantityUnitRepository quantityUnitRepository(Ref ref) {
  return QuantityUnitRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [QuantityUnitRepository] using PocketBase.
class QuantityUnitRepositoryImpl implements QuantityUnitRepository {
  final PocketBase _pb;

  QuantityUnitRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.quantityUnits);

  // Cache for quantity unit list
  List<QuantityUnit>? _cachedUnits;
  DateTime? _cacheTimestamp;

  // Cache TTL (10 minutes - units change less frequently)
  static const _cacheTtl = Duration(minutes: 10);

  /// Checks if the cache is valid.
  bool _isCacheValid() {
    if (_cachedUnits == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  /// Invalidates the cache.
  @override
  void invalidateCache() {
    _cachedUnits = null;
    _cacheTimestamp = null;
  }

  QuantityUnit _toEntity(RecordModel record) {
    final dto = QuantityUnitDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<QuantityUnit>> fetchAll({
    String? filter,
    String? sort,
  }) async {
    // Return cached data if valid and no filter
    if (_isCacheValid() && filter == null) {
      return Right(_cachedUnits!);
    }

    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final filterString =
            filter != null ? '$baseFilter && $filter' : baseFilter;

        final records = await _collection.getFullList(
          filter: filterString,
          sort: sort ?? 'name',
        );

        final units = records.map(_toEntity).toList();

        // Update cache only if no filter
        if (filter == null) {
          _cachedUnits = units;
          _cacheTimestamp = DateTime.now();
        }

        return units;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<QuantityUnit> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Quantity unit ID cannot be empty',
            null,
            'invalid_quantity_unit_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<QuantityUnit> create(QuantityUnit unit) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': unit.name,
          'shortSingular': unit.shortSingular,
          'shortPlural': unit.shortPlural,
          'longSingular': unit.longSingular,
          'longPlural': unit.longPlural,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<QuantityUnit> update(QuantityUnit unit) async {
    return TaskEither.tryCatch(
      () async {
        if (unit.id.isEmpty) {
          throw const DataFailure(
            'Quantity unit ID cannot be empty',
            null,
            'invalid_quantity_unit_id',
          );
        }

        final body = <String, dynamic>{
          'name': unit.name,
          'shortSingular': unit.shortSingular,
          'shortPlural': unit.shortPlural,
          'longSingular': unit.longSingular,
          'longPlural': unit.longPlural,
        };

        final record = await _collection.update(unit.id, body: body);
        invalidateCache();
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
            'Quantity unit ID cannot be empty',
            null,
            'invalid_quantity_unit_id',
          );
        }

        // Soft delete
        await _collection.update(id, body: {'isDeleted': true});
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }
}
