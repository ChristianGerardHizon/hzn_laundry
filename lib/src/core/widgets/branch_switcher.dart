import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/domain/branch.dart';
import '../../features/settings/presentation/controllers/branches_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../i18n/strings.g.dart';
import 'nav_permissions.dart';

/// Branch switcher widget for the sidebar/drawer and app branch bar.
///
/// Shows current branch with optional dropdown for admins.
/// - For admins: Dropdown to switch between all branches (incl. All Branches)
/// - For regular users: Display-only (no dropdown)
class BranchSwitcher extends ConsumerWidget {
  const BranchSwitcher({
    super.key,
    this.compact = false,
  });

  /// When true, uses tighter padding suited for the top branch bar.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentBranchAsync = ref.watch(currentBranchControllerProvider);
    final branchesAsync = ref.watch(branchesControllerProvider);
    final roleAsync = ref.watch(currentUserRoleProvider);
    final isAllBranches = ref.watch(isAllBranchesProvider);
    final canSwitch = roleAsync.value?.isAdmin ?? false;

    return currentBranchAsync.when(
      data: (currentBranch) {
        if (canSwitch) {
          return branchesAsync.when(
            data: (branches) {
              if (branches.isEmpty && !isAllBranches) {
                if (currentBranch == null) {
                  return _NoBranchDisplay(theme: theme, compact: compact);
                }
                return _BranchDisplay(
                  branch: currentBranch,
                  compact: compact,
                );
              }

              final selectedValue = isAllBranches
                  ? kAllBranchesSentinel
                  : currentBranch?.id;

              // Fall back if persisted branch is missing from list
              final effectiveValue = selectedValue == kAllBranchesSentinel ||
                      (selectedValue != null &&
                          branches.any((b) => b.id == selectedValue))
                  ? selectedValue
                  : (branches.isNotEmpty ? branches.first.id : null);

              if (effectiveValue == null) {
                return _NoBranchDisplay(theme: theme, compact: compact);
              }

              return _AdminBranchDropdown(
                selectedValue: effectiveValue,
                branches: branches,
                compact: compact,
                onChanged: (value) {
                  final notifier =
                      ref.read(currentBranchControllerProvider.notifier);
                  if (value == kAllBranchesSentinel) {
                    notifier.switchToAllBranches();
                  } else {
                    notifier.switchBranch(value);
                  }
                },
              );
            },
            loading: () => currentBranch != null
                ? _BranchDisplay(
                    branch: currentBranch,
                    isLoading: true,
                    compact: compact,
                  )
                : _BranchLoadingState(compact: compact),
            error: (_, __) => currentBranch != null
                ? _BranchDisplay(branch: currentBranch, compact: compact)
                : _NoBranchDisplay(theme: theme, compact: compact),
          );
        }

        if (currentBranch == null) {
          return _NoBranchDisplay(theme: theme, compact: compact);
        }

        return _BranchDisplay(branch: currentBranch, compact: compact);
      },
      loading: () => _BranchLoadingState(compact: compact),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AdminBranchDropdown extends StatelessWidget {
  const _AdminBranchDropdown({
    required this.selectedValue,
    required this.branches,
    required this.onChanged,
    this.compact = false,
  });

  final String selectedValue;
  final List<Branch> branches;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return Container(
      width: compact ? double.infinity : null,
      margin: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 12,
        vertical: compact ? 0 : 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: compact ? null : BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          isDense: compact,
          icon: Icon(
            Icons.swap_horiz,
            size: compact ? 16 : 20,
          ),
          style: compact
              ? theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.bodyMedium,
          items: [
            DropdownMenuItem(
              value: kAllBranchesSentinel,
              child: Row(
                children: [
                  Icon(Icons.storefront, size: compact ? 14 : 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.navigation.allBranches,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ...branches.map((branch) {
              return DropdownMenuItem(
                value: branch.id,
                child: Row(
                  children: [
                    Icon(Icons.store, size: compact ? 14 : 18),
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
            }),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
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
    this.compact = false,
  });

  final Branch branch;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: compact ? double.infinity : null,
      margin: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 12,
        vertical: compact ? 6 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: compact ? null : BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.store,
            size: compact ? 14 : 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              branch.name,
              style: compact
                  ? theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )
                  : theme.textTheme.bodyMedium,
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
  const _NoBranchDisplay({
    required this.theme,
    this.compact = false,
  });

  final ThemeData theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Container(
      width: compact ? double.infinity : null,
      margin: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 12,
        vertical: compact ? 6 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: compact ? null : BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.store_outlined,
            size: compact ? 14 : 18,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.navigation.noBranch,
              style: (compact
                      ? theme.textTheme.labelSmall
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
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
  const _BranchLoadingState({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : null,
      margin: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 12,
        vertical: compact ? 6 : 12,
      ),
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
