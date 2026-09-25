import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/customer.dart';
import '../dto/customer_dto.dart';

part 'customer_repository.g.dart';

/// Repository interface for customer operations.
abstract class CustomerRepository {
  /// Fetches all customers.
  FutureEither<List<Customer>> fetchAll({String? filter, String? sort});

  /// Fetches a single customer by ID.
  FutureEither<Customer> fetchOne(String id);

  /// Creates a new customer.
  FutureEither<Customer> create(Customer customer);

  /// Updates an existing customer.
  FutureEither<Customer> update(Customer customer);

  /// Soft deletes a customer by ID (sets isDeleted = true).
  FutureEither<void> delete(String id);

  /// Fetches customers created within a date range.
  FutureEither<List<Customer>> fetchForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? branchScope,
  });

  /// Searches customers by name or phone.
  FutureEither<List<Customer>> search(
    String query, {
    List<String>? fields,
    String? branchId,
  });

  /// Invalidates the customer list cache.
  void invalidateCache();
}

/// Provides the CustomerRepository instance.
@Riverpod(keepAlive: true)
CustomerRepository customerRepository(Ref ref) {
  return CustomerRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [CustomerRepository] using PocketBase.
class CustomerRepositoryImpl implements CustomerRepository {
  final PocketBase _pb;

  CustomerRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.customers);

  // Cache for customer list
  List<Customer>? _cachedCustomers;
  DateTime? _cacheTimestamp;
  String? _cachedFilter;
  String? _cachedSort;

  // Cache TTL (5 minutes)
  static const _cacheTtl = Duration(minutes: 5);

  /// Checks if the cache is valid.
  bool _isCacheValid(String? filter, String? sort) {
    if (_cachedCustomers == null || _cacheTimestamp == null) return false;
    if (_cachedFilter != filter || _cachedSort != sort) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cachedCustomers = null;
    _cacheTimestamp = null;
    _cachedFilter = null;
    _cachedSort = null;
  }

  Customer _toEntity(RecordModel record) {
    return CustomerDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<Customer>> fetchAll({String? filter, String? sort}) async {
    if (_isCacheValid(filter, sort)) {
      return Right(_cachedCustomers!);
    }

    return TaskEither.tryCatch(
      () async {
        final filterString = PBFilters.combine(
          PBFilters.active.build(),
          filter,
        );

        final records = await _collection.getFullList(
          filter: filterString,
          sort: sort ?? 'name',
        );

        final customers = records.map(_toEntity).toList();

        // Update cache
        _cachedCustomers = customers;
        _cacheTimestamp = DateTime.now();
        _cachedFilter = filter;
        _cachedSort = sort;

        return customers;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Customer> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Customer ID cannot be empty',
            null,
            'invalid_customer_id',
          );
        }

        final record = await _collection.getOne(id);
        final customer = _toEntity(record);
        if (customer.isDeleted) {
          throw const DataFailure(
            'Customer not found',
            null,
            'customer_not_found',
          );
        }
        return customer;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Customer> create(Customer customer) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': customer.name,
          'phone': customer.phone,
          'email': customer.email,
          'address': customer.address,
          'notes': customer.notes,
          'isDeleted': false,
        };
        if (customer.branchId != null && customer.branchId!.isNotEmpty) {
          body['branch'] = customer.branchId;
        }

        final record = await _collection.create(body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Customer> update(Customer customer) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': customer.name,
          'phone': customer.phone,
          'email': customer.email,
          'address': customer.address,
          'notes': customer.notes,
        };
        if (customer.branchId != null && customer.branchId!.isNotEmpty) {
          body['branch'] = customer.branchId;
        }

        final record = await _collection.update(customer.id, body: body);
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
  FutureEither<List<Customer>> fetchForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? branchScope,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .notDeleted()
            .between('created', startDate, endDate);

        final records = await _collection.getFullList(
          filter: PBFilters.combine(filter.build(), branchScope),
          sort: '-created',
        );
        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Customer>> search(
    String query, {
    List<String>? fields,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final searchFields = fields ?? ['name', 'phone'];
        var filter =
            PBFilter().notDeleted().searchFields(query, searchFields);
        if (branchId != null && branchId.isNotEmpty) {
          filter = filter.relation('branch', branchId);
        }

        final records = await _collection.getFullList(
          filter: filter.build(),
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }
}
