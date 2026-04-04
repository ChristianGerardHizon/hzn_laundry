import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../data/repositories/employee_attendance_repository.dart';
import '../../domain/employee_attendance.dart';

part 'attendance_controller.g.dart';

/// Controller for managing attendance records for a specific date.
@riverpod
class AttendanceController extends _$AttendanceController {
  EmployeeAttendanceRepository get _repository =>
      ref.read(employeeAttendanceRepositoryProvider);

  @override
  Future<List<EmployeeAttendance>> build(DateTime date) async {
    final result = await _repository.fetchForDate(date);

    return result.fold(
      (failure) => throw failure,
      (attendances) => attendances,
    );
  }

  /// Refreshes the attendance list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchForDate(date);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (attendances) => AsyncData(attendances),
    );
  }

  /// Toggles attendance for an employee.
  ///
  /// If no record exists for this employee on this date, creates one.
  /// If a record exists, updates its isPresent status.
  Future<bool> toggleAttendance({
    required String employeeId,
    required bool isPresent,
    String? existingId,
  }) async {
    final Either<Failure, EmployeeAttendance> result;
    if (existingId != null) {
      result = await _repository.updateAttendance(
        id: existingId,
        isPresent: isPresent,
      );
    } else {
      result = await _repository.createAttendance(
        employeeId: employeeId,
        date: date,
        isPresent: isPresent,
      );
    }
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}

/// Controller for fetching attendance records for a specific employee.
@riverpod
class EmployeeAttendanceController extends _$EmployeeAttendanceController {
  EmployeeAttendanceRepository get _repository =>
      ref.read(employeeAttendanceRepositoryProvider);

  @override
  Future<List<EmployeeAttendance>> build(String employeeId) async {
    final result = await _repository.fetchForEmployee(employeeId);

    return result.fold(
      (failure) => throw failure,
      (attendances) => attendances,
    );
  }

  /// Refreshes the attendance list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchForEmployee(employeeId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (attendances) => AsyncData(attendances),
    );
  }
}
