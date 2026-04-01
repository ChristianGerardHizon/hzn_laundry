import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/service_category.dart';
import '../dto/service_category_dto.dart';

part 'service_category_repository.g.dart';

/// Repository interface for service category operations.
abstract class ServiceCategoryRepository {
  /// Fetches all service categories.
  FutureEither<List<ServiceCategory>> fetchAll({String? filter, String? sort});

  /// Fetches a single category by ID.
  FutureEither<ServiceCategory> fetchOne(String id);

  /// Creates a new category.
  FutureEither<ServiceCategory> create(ServiceCategory category);

  /// Updates an existing category.
  FutureEither<ServiceCategory> update(ServiceCategory category);

  /// Soft deletes a category by ID.
  FutureEither<void> delete(String id);

  /// Invalidates the category list cache.
  void invalidateCache();
}

/// Provides the ServiceCategoryRepository instance.
@Riverpod(keepAlive: true)
ServiceCategoryRepository serviceCategoryRepository(Ref ref) {
  return ServiceCategoryRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [ServiceCategoryRepository] using PocketBase.
class ServiceCategoryRepositoryImpl implements ServiceCategoryRepository {
  final PocketBase _pb;

  ServiceCategoryRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.serviceCategories);

  // Cache for category list
  List<ServiceCategory>? _cachedCategories;
  DateTime? _cacheTimestamp;

  // Cache TTL (10 minutes - categories change less frequently)
  static const _cacheTtl = Duration(minutes: 10);

  /// Checks if the cache is valid.
  bool _isCacheValid() {
    if (_cachedCategories == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  /// Invalidates the cache.
  @override
  void invalidateCache() {
    _cachedCategories = null;
    _cacheTimestamp = null;
  }

  ServiceCategory _toEntity(RecordModel record) {
    final dto = ServiceCategoryDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<ServiceCategory>> fetchAll({
    String? filter,
    String? sort,
  }) async {
    // Return cached data if valid and no filter
    if (_isCacheValid() && filter == null) {
      return Right(_cachedCategories!);
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

        final categories = records.map(_toEntity).toList();

        // Update cache only if no filter
        if (filter == null) {
          _cachedCategories = categories;
          _cacheTimestamp = DateTime.now();
        }

        return categories;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<ServiceCategory> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Category ID cannot be empty',
            null,
            'invalid_category_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<ServiceCategory> create(ServiceCategory category) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': category.name,
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
  FutureEither<ServiceCategory> update(ServiceCategory category) async {
    return TaskEither.tryCatch(
      () async {
        if (category.id.isEmpty) {
          throw const DataFailure(
            'Category ID cannot be empty',
            null,
            'invalid_category_id',
          );
        }

        final body = <String, dynamic>{
          'name': category.name,
        };

        final record = await _collection.update(category.id, body: body);
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
            'Category ID cannot be empty',
            null,
            'invalid_category_id',
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
