import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/employee.dart';
import '../dto/employee_dto.dart';

part 'employee_repository.g.dart';

/// Repository interface for employee operations.
abstract class EmployeeRepository {
  /// Fetches all employees.
  FutureEither<List<Employee>> fetchAll({String? filter, String? sort});

  /// Fetches a single employee by ID.
  FutureEither<Employee> fetchOne(String id);

  /// Creates a new employee.
  FutureEither<Employee> create(Employee employee);

  /// Updates an existing employee.
  FutureEither<Employee> update(Employee employee);

  /// Soft deletes an employee by ID.
  FutureEither<void> delete(String id);

  /// Searches employees by name.
  FutureEither<List<Employee>> search(String query, {List<String>? fields});

  /// Invalidates the employee list cache.
  void invalidateCache();
}

/// Provides the EmployeeRepository instance.
@Riverpod(keepAlive: true)
EmployeeRepository employeeRepository(Ref ref) {
  return EmployeeRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [EmployeeRepository] using PocketBase.
class EmployeeRepositoryImpl implements EmployeeRepository {
  final PocketBase _pb;

  EmployeeRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.employees);

  // Cache for employee list
  List<Employee>? _cachedEmployees;
  DateTime? _cacheTimestamp;
  String? _cachedFilter;
  String? _cachedSort;

  // Cache TTL (5 minutes)
  static const _cacheTtl = Duration(minutes: 5);

  /// Checks if the cache is valid.
  bool _isCacheValid(String? filter, String? sort) {
    if (_cachedEmployees == null || _cacheTimestamp == null) return false;
    if (_cachedFilter != filter || _cachedSort != sort) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cachedEmployees = null;
    _cacheTimestamp = null;
    _cachedFilter = null;
    _cachedSort = null;
  }

  Employee _toEntity(RecordModel record) {
    return EmployeeDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<Employee>> fetchAll({String? filter, String? sort}) async {
    if (_isCacheValid(filter, sort)) {
      return Right(_cachedEmployees!);
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

        final employees = records.map(_toEntity).toList();

        // Update cache
        _cachedEmployees = employees;
        _cacheTimestamp = DateTime.now();
        _cachedFilter = filter;
        _cachedSort = sort;

        return employees;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Employee> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Employee ID cannot be empty',
            null,
            'invalid_employee_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Employee> create(Employee employee) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': employee.name,
          'baseSalary': employee.baseSalary,
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
  FutureEither<Employee> update(Employee employee) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': employee.name,
          'baseSalary': employee.baseSalary,
        };

        final record = await _collection.update(employee.id, body: body);
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
  FutureEither<List<Employee>> search(
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
}
