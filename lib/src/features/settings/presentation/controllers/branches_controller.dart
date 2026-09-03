import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/branch_repository.dart';
import '../../domain/branch.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';

part 'branches_controller.g.dart';

/// Controller for managing branch list state.
///
/// Provides methods for fetching and CRUD operations on branches.
@Riverpod(keepAlive: true)
class BranchesController extends _$BranchesController {
  BranchRepository get _repository => ref.read(branchRepositoryProvider);

  @override
  Future<List<Branch>> build() async {
    final orgId = ref.watch(currentOrganizationIdProvider);
    final result = await _repository.fetchAll();
    final branches = result.fold(
      (failure) => throw failure,
      (value) => value,
    );
    return _scopedToOrg(branches, orgId);
  }

  List<Branch> _scopedToOrg(List<Branch> branches, String? orgId) {
    if (orgId == null || orgId.isEmpty) return branches;
    return branches
        .where(
          (b) =>
              b.organizationId == orgId ||
              b.organizationId == null ||
              b.organizationId!.isEmpty,
        )
        .toList();
  }

  /// Refreshes the branch list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    final orgId = ref.read(currentOrganizationIdProvider);
    final result = await _repository.fetchAll();
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (branches) => AsyncData(_scopedToOrg(branches, orgId)),
    );
  }

  /// Creates a new branch.
  Future<bool> createBranch(Branch branch) async {
    final stamped =
        branch.organizationId == null || branch.organizationId!.isEmpty
            ? branch.copyWith(
                organizationId: ref.read(currentOrganizationIdProvider))
            : branch;
    final result = await _repository.create(stamped);

    return result.fold(
      (failure) => false,
      (newBranch) {
        final currentList = state.value ?? [];
        state = AsyncData([newBranch, ...currentList]);
        return true;
      },
    );
  }

  /// Updates an existing branch.
  Future<bool> updateBranch(Branch branch) async {
    final result = await _repository.update(branch);

    return result.fold(
      (failure) => false,
      (updatedBranch) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((b) {
          return b.id == updatedBranch.id ? updatedBranch : b;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Deletes a branch (soft delete).
  Future<bool> deleteBranch(String id) async {
    final result = await _repository.delete(id);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.where((b) => b.id != id).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }
}
