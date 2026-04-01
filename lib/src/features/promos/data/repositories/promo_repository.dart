import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/promo.dart';
import '../dto/promo_dto.dart';

part 'promo_repository.g.dart';

/// Repository interface for promo operations.
abstract class PromoRepository {
  FutureEither<List<Promo>> fetchAll({String? filter, String? sort});
  FutureEither<Promo> fetchOne(String id);
  FutureEither<Promo> create(Promo promo);
  FutureEither<Promo> update(Promo promo);
  FutureEither<void> delete(String id);
  FutureEither<List<Promo>> search(String query, {List<String>? fields});
  FutureEither<List<Promo>> fetchActive({String? branchFilter});
  void invalidateCache();
}

/// Provides the PromoRepository instance.
@Riverpod(keepAlive: true)
PromoRepository promoRepository(Ref ref) {
  return PromoRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [PromoRepository] using PocketBase.
class PromoRepositoryImpl implements PromoRepository {
  final PocketBase _pb;

  PromoRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.promos);

  // Cache for promo list
  List<Promo>? _cachedPromos;
  DateTime? _cacheTimestamp;
  String? _cachedFilter;
  String? _cachedSort;
  static const _cacheTtl = Duration(minutes: 5);

  bool _isCacheValid(String? filter, String? sort) {
    if (_cachedPromos == null || _cacheTimestamp == null) return false;
    if (_cachedFilter != filter || _cachedSort != sort) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cachedPromos = null;
    _cacheTimestamp = null;
    _cachedFilter = null;
    _cachedSort = null;
  }

  Promo _toEntity(RecordModel record) {
    final dto = PromoDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<Promo>> fetchAll({String? filter, String? sort}) async {
    if (_isCacheValid(filter, sort)) {
      return Right(_cachedPromos!);
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

        final promos = records.map(_toEntity).toList();

        _cachedPromos = promos;
        _cacheTimestamp = DateTime.now();
        _cachedFilter = filter;
        _cachedSort = sort;

        return promos;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Promo> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Promo ID cannot be empty',
            null,
            'invalid_promo_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Promo> create(Promo promo) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': promo.name,
          'description': promo.description,
          'startDate': promo.startDate.toUtcIso8601(),
          'endDate': promo.endDate.toUtcIso8601(),
          'requiredOrders': promo.requiredOrders,
          'rewardFreeWeight': promo.rewardFreeWeight,
          'isActive': promo.isActive,
          'branch': promo.branch,
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
  FutureEither<Promo> update(Promo promo) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': promo.name,
          'description': promo.description,
          'startDate': promo.startDate.toUtcIso8601(),
          'endDate': promo.endDate.toUtcIso8601(),
          'requiredOrders': promo.requiredOrders,
          'rewardFreeWeight': promo.rewardFreeWeight,
          'isActive': promo.isActive,
          'branch': promo.branch,
        };

        final record = await _collection.update(promo.id, body: body);
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
        await _collection.update(id, body: {'isDeleted': true});
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Promo>> search(
    String query, {
    List<String>? fields,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final searchFields = fields ?? ['name'];
        final filter = PBFilter()
            .notDeleted()
            .searchFields(query, searchFields)
            .build();

        final records = await _collection.getFullList(
          filter: filter,
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Promo>> fetchActive({String? branchFilter}) async {
    return TaskEither.tryCatch(
      () async {
        final now = DateTime.now().toPocketBaseUtc();
        final filter = PBFilter()
            .notDeleted()
            .isActive()
            .build();
        final dateFilter = "startDate <= '$now' && endDate >= '$now'";
        final combined = branchFilter != null
            ? '$filter && $dateFilter && $branchFilter'
            : '$filter && $dateFilter';

        final records = await _collection.getFullList(
          filter: combined,
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }
}
