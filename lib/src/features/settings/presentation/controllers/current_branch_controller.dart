import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../../core/routing/route_scope_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../pos/presentation/cart_controller.dart';
import '../../../users/presentation/controllers/user_provider.dart';
import '../../../users/presentation/controllers/user_role_provider.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../domain/branch.dart';
import 'branches_controller.dart';

part 'current_branch_controller.g.dart';

/// Storage key for persisting admin's selected branch.
const _currentBranchStorageKey = 'CURRENT_BRANCH_ID';

/// Sentinel persisted when an admin selects All Branches mode.
const kAllBranchesSentinel = '__ALL__';

/// Reserved `branchSlug` URL segment for "All branches" (admin) mode.
const allBranchesSlug = 'all';

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches (or All Branches), persists selection
/// - For regular users: Locked to their assigned branch
/// - Once a validated route scope exists, the URL is the source of truth
@Riverpod(keepAlive: true)
class CurrentBranchController extends _$CurrentBranchController {
  bool _isAllBranchesMode = false;

  /// Whether All Branches mode is active (admin only).
  bool get isAllBranchesMode => _isAllBranchesMode;

  @override
  Future<Branch?> build() async {
    ref.watch(currentOrganizationIdProvider);
    final routeScope = ref.watch(currentRouteScopeProvider);
    final auth = ref.watch(currentAuthProvider);
    if (auth == null) {
      _isAllBranchesMode = false;
      return null;
    }

    final userBranchId = auth.user.branch;
    final isAdmin = await _checkIsAdmin();
    final orgBranches = await ref.watch(branchesControllerProvider.future);

    // URL is source of truth once redirect has validated the scope.
    if (routeScope != null) {
      if (routeScope.branchSlug == allBranchesSlug) {
        if (isAdmin) {
          await _persistBranch(kAllBranchesSentinel);
          _isAllBranchesMode = true;
          return null;
        }
      } else {
        final match = orgBranches.cast<Branch?>().firstWhere(
              (b) => b?.slug == routeScope.branchSlug,
              orElse: () => null,
            );
        if (match != null) {
          await _persistBranch(match.id);
          _isAllBranchesMode = false;
          return match;
        }
      }
    }

    if (isAdmin) {
      final persistedBranchId = await _loadPersistedBranch();

      if (persistedBranchId == kAllBranchesSentinel) {
        _isAllBranchesMode = true;
        return null;
      }

      _isAllBranchesMode = false;
      final branchId = persistedBranchId ?? userBranchId;
      final matched = branchId != null ? await _fetchBranch(branchId) : null;
      if (matched != null) return matched;
      return orgBranches.isNotEmpty ? orgBranches.first : null;
    } else {
      _isAllBranchesMode = false;
      if (userBranchId != null) {
        final matched = await _fetchBranch(userBranchId);
        if (matched != null) return matched;
      }
      return orgBranches.isNotEmpty ? orgBranches.first : null;
    }
  }

  /// Whether the current user can switch branches (admin only).
  Future<bool> canSwitchBranch() async => await _checkIsAdmin();

  /// Whether the user may select the "All branches" option (admins only).
  Future<bool> canViewAllBranches() async => await _checkIsAdmin();

  /// Branch IDs available in the switcher for the current user.
  Future<List<String>> switchableBranchIds() async {
    if (await _checkIsAdmin()) {
      final branches = await ref.read(branchesControllerProvider.future);
      return branches.map((b) => b.id).toList();
    }
    final auth = ref.read(currentAuthProvider);
    final id = auth?.user.branch;
    return id != null && id.isNotEmpty ? [id] : const [];
  }

  /// Switches to All Branches mode (admin only).
  Future<void> switchToAllBranches() async {
    if (!await _checkIsAdmin()) return;

    await _persistBranch(kAllBranchesSentinel);
    _isAllBranchesMode = true;
    state = const AsyncData(null);

    ref.invalidate(cartControllerProvider);
  }

  /// Switches to a different branch (admin only).
  Future<void> switchBranch(String branchId) async {
    if (!await _checkIsAdmin()) return;

    await _persistBranch(branchId);
    _isAllBranchesMode = false;

    final branch = await _fetchBranch(branchId);
    state = AsyncData(branch);

    ref.invalidate(cartControllerProvider);
  }

  Future<bool> _checkIsAdmin() async {
    final auth = ref.read(currentAuthProvider);
    if (auth == null) return false;

    final fullUser = await ref.read(userProvider(auth.user.id).future);
    if (fullUser == null ||
        fullUser.roleId == null ||
        fullUser.roleId!.isEmpty) {
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
/// - Specific branch: `branch = "id" && isDeleted = false`
/// - All Branches + current org: `branch.organization = "orgId"`
/// - No org selected: null
@Riverpod(keepAlive: true)
String? currentBranchFilter(Ref ref) {
  final branchId = ref.watch(currentBranchIdProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);
  if (branchId != null && branchId.isNotEmpty) {
    return PBFilters.forBranch(branchId).build();
  }
  if (orgId != null && orgId.isNotEmpty) {
    return PBFilters.forOrganization(orgId);
  }
  return null;
}

/// Same scope as [currentBranchFilter] but without soft-delete, for appending
/// to existing filter strings (` && …`).
@Riverpod(keepAlive: true)
String currentBranchScopeClause(Ref ref) {
  final branchId = ref.watch(currentBranchIdProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);
  final scope = PBFilters.forBranchOrOrganization(
    branchId: branchId,
    organizationId: orgId,
  );
  if (scope == null || scope.isEmpty) return '';
  return ' && $scope';
}

/// Payment / nested-sale scope: `sale.branch = "id"` or
/// `sale.branch.organization = "orgId"`.
@Riverpod(keepAlive: true)
String currentSaleBranchScopeClause(Ref ref) {
  final branchId = ref.watch(currentBranchIdProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);
  final scope = PBFilters.forBranchOrOrganization(
    branchId: branchId,
    organizationId: orgId,
    branchField: 'sale.branch',
  );
  if (scope == null || scope.isEmpty) return '';
  return ' && $scope';
}

/// Flat branch-id filter for SQL views (no relation traversal).
///
/// - Specific branch: `branch = "id"`
/// - All Branches: `(branch = "a" || branch = "b" || …)` for current org
@Riverpod(keepAlive: true)
String? currentBranchIdsFilter(Ref ref) {
  final branchId = ref.watch(currentBranchIdProvider);
  if (branchId != null && branchId.isNotEmpty) {
    return 'branch = "$branchId"';
  }
  // Rebuild when org changes even if branch stays null (All → All).
  ref.watch(currentOrganizationIdProvider);
  final branches =
      ref.watch(branchesControllerProvider).asData?.value ?? const [];
  return PBFilters.forBranchIds(branches.map((b) => b.id));
}
