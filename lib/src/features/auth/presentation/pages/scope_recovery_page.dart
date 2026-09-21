import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../organizations/domain/organization.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/auth_controller.dart';

const _kInk = Color(0xFF0B0B0B);
const _kBrandTeal = Color(0xFF45A9AB);

/// Shown when auth succeeds but org/branch scope cannot resolve a home path.
///
/// Prevents an endless splash when memberships, slugs, or branches are missing.
class ScopeRecoveryPage extends HookConsumerWidget {
  const ScopeRecoveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isBusy = useState(false);

    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final branchAsync = ref.watch(currentBranchControllerProvider);
    final memberships =
        ref.watch(currentOrganizationControllerProvider.notifier).memberships;

    final message = _resolveMessage(
      t: t,
      orgAsync: orgAsync,
      branchAsync: branchAsync,
      membershipCount: memberships.length,
      isAllBranches: ref
          .read(currentBranchControllerProvider.notifier)
          .isAllBranchesMode,
    );

    Future<void> handleRetry() async {
      if (isBusy.value) return;
      isBusy.value = true;
      try {
        ref.invalidate(currentOrganizationControllerProvider);
        ref.invalidate(branchesControllerProvider);
        ref.invalidate(currentBranchControllerProvider);
        await Future.wait([
          ref.read(currentOrganizationControllerProvider.future).catchError(
                (_) => null,
              ),
          ref.read(currentBranchControllerProvider.future).catchError(
                (_) => null,
              ),
        ]);
      } finally {
        if (context.mounted) isBusy.value = false;
      }
    }

    Future<void> handleLogout() async {
      if (isBusy.value) return;
      isBusy.value = true;
      try {
        await ref.read(authControllerProvider.notifier).logout();
      } finally {
        if (context.mounted) isBusy.value = false;
      }
    }

    return Scaffold(
      backgroundColor: _kInk,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Assets.icons.appIconTransparent.image(
                      width: 72,
                      height: 72,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.auth.scopeRecoveryTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: isBusy.value ? null : handleRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: _kBrandTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isBusy.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.common.retry),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isBusy.value ? null : handleLogout,
                    child: Text(t.auth.logoutButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _resolveMessage({
    required Translations t,
    required AsyncValue<Organization?> orgAsync,
    required AsyncValue<Branch?> branchAsync,
    required int membershipCount,
    required bool isAllBranches,
  }) {
    if (orgAsync.hasError) {
      return Failure.displayErrorMessage(orgAsync.error);
    }
    if (branchAsync.hasError) {
      return Failure.displayErrorMessage(branchAsync.error);
    }

    final org = orgAsync.value;
    if (org == null) {
      if (membershipCount == 0) {
        return t.auth.scopeRecoveryNoMembership;
      }
      return t.auth.scopeRecoveryOrgUnavailable;
    }
    if (org.slug.isEmpty) {
      return t.auth.scopeRecoveryEmptyOrgSlug;
    }

    if (isAllBranches) {
      return t.auth.scopeRecoveryGeneric;
    }

    final branch = branchAsync.value;
    if (branch == null) {
      return t.auth.scopeRecoveryNoBranch;
    }
    if (branch.slug.isEmpty) {
      return t.auth.scopeRecoveryEmptyBranchSlug;
    }

    return t.auth.scopeRecoveryGeneric;
  }
}
