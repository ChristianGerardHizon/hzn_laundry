import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/deduction_type.dart';
import '../../domain/deduction_value_type.dart';
import '../../domain/employee_deduction.dart';
import '../dto/employee_deduction_dto.dart';

part 'employee_deduction_repository.g.dart';

/// Repository interface for employee deduction operations.
abstract class EmployeeDeductionRepository {
  /// Fetches all deductions for an employee.
  FutureEither<List<EmployeeDeduction>> fetchForEmployee(String employeeId);

  /// Creates a new deduction.
  FutureEither<EmployeeDeduction> create({
    required String employeeId,
    required DeductionType type,
    required DeductionValueType valueType,
    required num value,
    String? name,
    DateTime? startMonth,
    DateTime? endMonth,
  });

  /// Updates an existing deduction.
  FutureEither<EmployeeDeduction> update({
    required String id,
    required DeductionType type,
    required DeductionValueType valueType,
    required num value,
    String? name,
    DateTime? startMonth,
    DateTime? endMonth,
    required bool isActive,
  });

  /// Deletes a deduction.
  FutureEither<void> delete(String id);

  /// Invalidates cache.
  void invalidateCache();
}

/// Provides the EmployeeDeductionRepository instance.
@Riverpod(keepAlive: true)
EmployeeDeductionRepository employeeDeductionRepository(Ref ref) {
  return EmployeeDeductionRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [EmployeeDeductionRepository] using PocketBase.
class EmployeeDeductionRepositoryImpl implements EmployeeDeductionRepository {
  final PocketBase _pb;

  EmployeeDeductionRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.employeeDeductions);

  // Cache
  final Map<String, List<EmployeeDeduction>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const _cacheTtl = Duration(minutes: 2);

  bool _isCacheValid(String employeeId) {
    final timestamp = _cacheTimestamps[employeeId];
    if (timestamp == null || !_cache.containsKey(employeeId)) return false;
    return DateTime.now().difference(timestamp) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  EmployeeDeduction _toEntity(RecordModel record) {
    return EmployeeDeductionDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<EmployeeDeduction>> fetchForEmployee(
    String employeeId,
  ) async {
    if (_isCacheValid(employeeId)) {
      return Right(_cache[employeeId]!);
    }

    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter().relation('employee', employeeId).build();

        final records = await _collection.getFullList(
          filter: filter,
          sort: '-created',
        );

        final deductions = records.map(_toEntity).toList();
        _cache[employeeId] = deductions;
        _cacheTimestamps[employeeId] = DateTime.now();

        return deductions;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<EmployeeDeduction> create({
    required String employeeId,
    required DeductionType type,
    required DeductionValueType valueType,
    required num value,
    String? name,
    DateTime? startMonth,
    DateTime? endMonth,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = EmployeeDeductionDto.toCreateBody(
          employeeId: employeeId,
          type: type,
          valueType: valueType,
          value: value,
          name: name,
          startMonth: startMonth,
          endMonth: endMonth,
        );

        final record = await _collection.create(body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<EmployeeDeduction> update({
    required String id,
    required DeductionType type,
    required DeductionValueType valueType,
    required num value,
    String? name,
    DateTime? startMonth,
    DateTime? endMonth,
    required bool isActive,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'type': type.name,
          'valueType': valueType.name,
          'value': value,
          'name': name ?? '',
          'isActive': isActive,
        };

        if (startMonth != null) {
          body['startMonth'] = startMonth.toUtcIso8601();
        } else {
          body['startMonth'] = '';
        }

        if (endMonth != null) {
          body['endMonth'] = endMonth.toUtcIso8601();
        } else {
          body['endMonth'] = '';
        }

        final record = await _collection.update(id, body: body);
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
        await _collection.delete(id);
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }
}
