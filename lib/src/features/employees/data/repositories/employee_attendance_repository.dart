import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/employee_attendance.dart';
import '../dto/employee_attendance_dto.dart';

part 'employee_attendance_repository.g.dart';

/// Repository interface for employee attendance operations.
abstract class EmployeeAttendanceRepository {
  /// Fetches attendance records for a specific date.
  FutureEither<List<EmployeeAttendance>> fetchForDate(DateTime date);

  /// Fetches attendance records for an employee.
  FutureEither<List<EmployeeAttendance>> fetchForEmployee(String employeeId);

  /// Creates an attendance record for an employee on a date.
  FutureEither<EmployeeAttendance> createAttendance({
    required String employeeId,
    required DateTime date,
    required bool isPresent,
  });

  /// Updates an existing attendance record's isPresent status.
  FutureEither<EmployeeAttendance> updateAttendance({
    required String id,
    required bool isPresent,
  });

  /// Invalidates cache.
  void invalidateCache();
}

/// Provides the EmployeeAttendanceRepository instance.
@Riverpod(keepAlive: true)
EmployeeAttendanceRepository employeeAttendanceRepository(Ref ref) {
  return EmployeeAttendanceRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [EmployeeAttendanceRepository] using PocketBase.
class EmployeeAttendanceRepositoryImpl implements EmployeeAttendanceRepository {
  final PocketBase _pb;

  EmployeeAttendanceRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.employeeAttendances);

  // Cache
  List<EmployeeAttendance>? _cachedAttendances;
  DateTime? _cacheTimestamp;
  String? _cachedFilter;
  static const _cacheTtl = Duration(minutes: 2);

  bool _isCacheValid(String? filter) {
    if (_cachedAttendances == null || _cacheTimestamp == null) return false;
    if (_cachedFilter != filter) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cachedAttendances = null;
    _cacheTimestamp = null;
    _cachedFilter = null;
  }

  EmployeeAttendance _toEntity(RecordModel record) {
    return EmployeeAttendanceDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<EmployeeAttendance>> fetchForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final filter = PBFilter()
        .after('date', startOfDay)
        .before('date', endOfDay)
        .build();

    if (_isCacheValid(filter)) {
      return Right(_cachedAttendances!);
    }

    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(
          filter: filter,
          sort: '-date',
        );

        final attendances = records.map(_toEntity).toList();
        _cachedAttendances = attendances;
        _cacheTimestamp = DateTime.now();
        _cachedFilter = filter;

        return attendances;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<EmployeeAttendance>> fetchForEmployee(
    String employeeId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter().relation('employee', employeeId).build();

        final records = await _collection.getFullList(
          filter: filter,
          sort: '-date',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<EmployeeAttendance> createAttendance({
    required String employeeId,
    required DateTime date,
    required bool isPresent,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'employee': employeeId,
          'date': date.toUtcIso8601(),
          'isPresent': isPresent,
        };

        final record = await _collection.create(body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<EmployeeAttendance> updateAttendance({
    required String id,
    required bool isPresent,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'isPresent': isPresent,
        };

        final record = await _collection.update(id, body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}
