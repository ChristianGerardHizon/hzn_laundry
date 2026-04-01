import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/domain/branch.dart';
import '../../features/settings/presentation/controllers/branches_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../i18n/strings.g.dart';

/// Branch switcher widget for the sidebar/drawer.
///
/// Shows current branch with optional dropdown for admins.
/// - For admins: Dropdown to switch between all branches
/// - For regular users: Display-only (no dropdown)
class BranchSwitcher extends HookConsumerWidget {
  const BranchSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentBranchAsync = ref.watch(currentBranchControllerProvider);
    final branchesAsync = ref.watch(branchesControllerProvider);

    // Check if user can switch branches
    final canSwitchFuture = useMemoized(
      () => ref.read(currentBranchControllerProvider.notifier).canSwitchBranch(),
      [currentBranchAsync],
    );
    final canSwitchSnapshot = useFuture(canSwitchFuture);

    return currentBranchAsync.when(
      data: (currentBranch) {
        if (currentBranch == null) {
          return _NoBranchDisplay(theme: theme);
        }

        final canSwitch = canSwitchSnapshot.data ?? false;

        if (canSwitch) {
          // Admin: Show dropdown
          return branchesAsync.when(
            data: (branches) => _AdminBranchDropdown(
              currentBranch: currentBranch,
              branches: branches,
              onChanged: (branch) {
                ref
                    .read(currentBranchControllerProvider.notifier)
                    .switchBranch(branch.id);
              },
            ),
            loading: () => _BranchDisplay(branch: currentBranch, isLoading: true),
            error: (_, __) => _BranchDisplay(branch: currentBranch),
          );
        } else {
          // Regular user: Display only
          return _BranchDisplay(branch: currentBranch);
        }
      },
      loading: () => const _BranchLoadingState(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AdminBranchDropdown extends StatelessWidget {
  const _AdminBranchDropdown({
    required this.currentBranch,
    required this.branches,
    required this.onChanged,
  });

  final Branch currentBranch;
  final List<Branch> branches;
  final ValueChanged<Branch> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentBranch.id,
          isExpanded: true,
          icon: const Icon(Icons.swap_horiz, size: 20),
          items: branches.map((branch) {
            return DropdownMenuItem(
              value: branch.id,
              child: Row(
                children: [
                  const Icon(Icons.store, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      branch.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (branchId) {
            if (branchId != null) {
              final branch = branches.firstWhere((b) => b.id == branchId);
              onChanged(branch);
            }
          },
        ),
      ),
    );
  }
}

class _BranchDisplay extends StatelessWidget {
  const _BranchDisplay({
    required this.branch,
    this.isLoading = false,
  });

  final Branch branch;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.store,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              branch.name,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class _NoBranchDisplay extends StatelessWidget {
  const _NoBranchDisplay({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.store_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.navigation.noBranch,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchLoadingState extends StatelessWidget {
  const _BranchLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
