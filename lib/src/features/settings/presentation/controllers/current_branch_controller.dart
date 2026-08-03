import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../pos/presentation/cart_controller.dart';
import '../../../users/presentation/controllers/user_provider.dart';
import '../../../users/presentation/controllers/user_role_provider.dart';
import '../../domain/branch.dart';
import 'branches_controller.dart';

part 'current_branch_controller.g.dart';

/// Storage key for persisting admin's selected branch.
const _currentBranchStorageKey = 'CURRENT_BRANCH_ID';

/// Sentinel persisted when an admin selects All Branches mode.
const kAllBranchesSentinel = '__ALL__';

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches (or All Branches), persists selection
/// - For regular users: Locked to their assigned branch
@Riverpod(keepAlive: true)
class CurrentBranchController extends _$CurrentBranchController {
  bool _isAllBranchesMode = false;

  /// Whether All Branches mode is active (admin only).
  bool get isAllBranchesMode => _isAllBranchesMode;

  @override
  Future<Branch?> build() async {
    final auth = ref.watch(currentAuthProvider);
    if (auth == null) {
      _isAllBranchesMode = false;
      return null;
    }

    final userBranchId = auth.user.branch;
    final isAdmin = await _checkIsAdmin();

    if (isAdmin) {
      final persistedBranchId = await _loadPersistedBranch();

      if (persistedBranchId == kAllBranchesSentinel) {
        _isAllBranchesMode = true;
        return null;
      }

      _isAllBranchesMode = false;
      final branchId = persistedBranchId ?? userBranchId;
      return branchId != null ? await _fetchBranch(branchId) : null;
    } else {
      _isAllBranchesMode = false;
      return userBranchId != null ? await _fetchBranch(userBranchId) : null;
    }
  }

  /// Whether the current user can switch branches (admin only).
  Future<bool> canSwitchBranch() async => await _checkIsAdmin();

  /// Switches to All Branches mode (admin only).
  Future<void> switchToAllBranches() async {
    if (!await _checkIsAdmin()) return;

    await _persistBranch(kAllBranchesSentinel);
    _isAllBranchesMode = true;
    state = const AsyncData(null);

    // Cart reads branch once and does not watch — force reload.
    ref.invalidate(cartControllerProvider);
  }

  /// Switches to a different branch (admin only).
  Future<void> switchBranch(String branchId) async {
    if (!await _checkIsAdmin()) return;

    await _persistBranch(branchId);
    _isAllBranchesMode = false;

    final branch = await _fetchBranch(branchId);
    state = AsyncData(branch);

    // Cart reads branch once and does not watch — force reload.
    ref.invalidate(cartControllerProvider);
  }

  Future<bool> _checkIsAdmin() async {
    final auth = ref.read(currentAuthProvider);
    if (auth == null) return false;

    final fullUser = await ref.read(userProvider(auth.user.id).future);
    if (fullUser == null || fullUser.roleId == null || fullUser.roleId!.isEmpty) {
      return false;
    }

    final userRole = await ref.read(userRoleProvider(fullUser.roleId!).future);
    return userRole?.isAdmin ?? false;
  }

  Future<Branch?> _fetchBranch(String branchId) async {
    final branches = await ref.read(branchesControllerProvider.future);
    return branches.cast<Branch?>().firstWhere(
          (b) => b?.id == branchId,
          orElse: () => null,
        );
  }

  Future<String?> _loadPersistedBranch() async {
    try {
      final storage = ref.read(secureStorageProvider);
      return await storage.read(key: _currentBranchStorageKey);
    } catch (e, st) {
      // Secure storage can throw PlatformException on Windows/web (corrupt
      // credentials, missing options). Fall back to no persisted selection.
      assert(() {
        debugPrint('Failed to load persisted branch: $e\n$st');
        return true;
      }());
      return null;
    }
  }

  Future<void> _persistBranch(String branchId) async {
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: _currentBranchStorageKey, value: branchId);
    } catch (e, st) {
      assert(() {
        debugPrint('Failed to persist branch: $e\n$st');
        return true;
      }());
    }
  }
}

/// Whether the admin has selected All Branches mode.
@Riverpod(keepAlive: true)
bool isAllBranches(Ref ref) {
  ref.watch(currentBranchControllerProvider);
  return ref.read(currentBranchControllerProvider.notifier).isAllBranchesMode;
}

/// Convenience provider for current branch ID.
///
/// Returns null when All Branches is selected or no branch is available.
@Riverpod(keepAlive: true)
String? currentBranchId(Ref ref) {
  return ref.watch(currentBranchControllerProvider).value?.id;
}

/// Convenience provider for branch filter string.
///
/// Returns a filter string like `branch = "id"` or null if All Branches / none.
@Riverpod(keepAlive: true)
String? currentBranchFilter(Ref ref) {
  final branchId = ref.watch(currentBranchIdProvider);
  if (branchId == null) return null;
  return PBFilters.forBranch(branchId).build();
}
