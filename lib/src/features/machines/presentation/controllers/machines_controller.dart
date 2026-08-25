import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/machine_repository.dart';
import '../../domain/machine.dart';

part 'machines_controller.g.dart';

/// Controller for managing machine list state.
///
/// Machines are scoped to the current working branch. Unassigned machines
/// (no branch set) remain visible so existing org-wide records are not hidden.
@Riverpod(keepAlive: true)
class MachinesController extends _$MachinesController {
  MachineRepository get _repository => ref.read(machineRepositoryProvider);

  String? get _branchFilter => PBFilters.forBranchIncludingUnassigned(
        ref.read(currentBranchIdProvider),
      );

  @override
  Future<List<Machine>> build() async {
    ref.watch(currentBranchIdProvider);
    final result = await _repository.fetchAll(filter: _branchFilter);
    return result.fold(
      (failure) => throw failure,
      (machines) => machines,
    );
  }

  /// Refreshes the machine list.
  Future<void> refresh() async {
    state = const AsyncLoading();

    final result = await _repository.fetchAll(filter: _branchFilter);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (machines) => AsyncData(machines),
    );
  }

  /// Creates a new machine.
  Future<bool> createMachine(Machine machine) async {
    final result = await _repository.create(machine);

    return result.fold(
      (failure) => false,
      (newMachine) {
        final currentList = state.value ?? [];
        state = AsyncData([newMachine, ...currentList]);
        return true;
      },
    );
  }

  /// Updates an existing machine.
  Future<bool> updateMachine(Machine machine) async {
    final result = await _repository.update(machine);

    return result.fold(
      (failure) => false,
      (updatedMachine) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((m) {
          return m.id == updatedMachine.id ? updatedMachine : m;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Deletes a machine (soft delete).
  Future<bool> deleteMachine(String id) async {
    final result = await _repository.delete(id);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.where((m) => m.id != id).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }
}
