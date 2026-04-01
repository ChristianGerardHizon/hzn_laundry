import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/service.dart';
import '../dto/service_dto.dart';

part 'service_repository.g.dart';

/// Repository interface for service operations.
abstract class ServiceRepository {
  /// Fetches all services.
  FutureEither<List<Service>> fetchAll({String? filter, String? sort});

  /// Fetches a single service by ID.
  FutureEither<Service> fetchOne(String id);

  /// Creates a new service.
  FutureEither<Service> create(Service service);

  /// Updates an existing service.
  FutureEither<Service> update(Service service);

  /// Soft deletes a service by ID.
  FutureEither<void> delete(String id);

  /// Searches services by the specified fields.
  FutureEither<List<Service>> search(String query, {List<String>? fields});

  /// Invalidates the service list cache.
  void invalidateCache();
}

/// Provides the ServiceRepository instance.
@Riverpod(keepAlive: true)
ServiceRepository serviceRepository(Ref ref) {
  return ServiceRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [ServiceRepository] using PocketBase.
class ServiceRepositoryImpl implements ServiceRepository {
  final PocketBase _pb;

  ServiceRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.services);
  String get _expand => 'category,quantityUnit';

  // Cache for service list
  List<Service>? _cachedServices;
  DateTime? _cacheTimestamp;
  String? _cachedFilter;
  String? _cachedSort;

  // Cache TTL (5 minutes)
  static const _cacheTtl = Duration(minutes: 5);

  /// Checks if the cache is valid.
  bool _isCacheValid(String? filter, String? sort) {
    if (_cachedServices == null || _cacheTimestamp == null) return false;
    if (_cachedFilter != filter || _cachedSort != sort) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  /// Invalidates the cache.
  @override
  void invalidateCache() {
    _cachedServices = null;
    _cacheTimestamp = null;
    _cachedFilter = null;
    _cachedSort = null;
  }

  Service _toEntity(RecordModel record) {
    final dto = ServiceDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<Service>> fetchAll({String? filter, String? sort}) async {
    // Return cached data if valid
    if (_isCacheValid(filter, sort)) {
      return Right(_cachedServices!);
    }

    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final filterString =
            filter != null ? '$baseFilter && $filter' : baseFilter;

        final records = await _collection.getFullList(
          expand: _expand,
          filter: filterString,
          sort: sort ?? 'name',
        );

        final services = records.map(_toEntity).toList();

        // Update cache
        _cachedServices = services;
        _cacheTimestamp = DateTime.now();
        _cachedFilter = filter;
        _cachedSort = sort;

        return services;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Service> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Service ID cannot be empty',
            null,
            'invalid_service_id',
          );
        }

        final record = await _collection.getOne(id, expand: _expand);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Service> create(Service service) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': service.name,
          'description': service.description,
          'category': service.categoryId,
          'branch': service.branch,
          'price': service.price,
          'isVariablePrice': service.isVariablePrice,
          'estimatedDuration': service.estimatedDuration,
          'weightBased': service.weightBased,
          'showPrompt': service.showPrompt,
          'maxQuantity': service.maxQuantity,
          'allowExcess': service.allowExcess,
          'quantityUnit': service.quantityUnitId,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body, expand: _expand);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Service> update(Service service) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': service.name,
          'description': service.description,
          'category': service.categoryId,
          'branch': service.branch,
          'price': service.price,
          'isVariablePrice': service.isVariablePrice,
          'estimatedDuration': service.estimatedDuration,
          'weightBased': service.weightBased,
          'showPrompt': service.showPrompt,
          'maxQuantity': service.maxQuantity,
          'allowExcess': service.allowExcess,
          'quantityUnit': service.quantityUnitId,
        };

        final record =
            await _collection.update(service.id, body: body, expand: _expand);
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
  FutureEither<List<Service>> search(
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
          expand: _expand,
          filter: filter,
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }
}
