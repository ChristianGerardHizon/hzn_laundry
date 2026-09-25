import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/domain/organization.dart';
import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../i18n/strings.g.dart';
import '../routing/router_utils.dart';
import '../routing/routes/dashboard.routes.dart';
import '../routing/routes/org_selection.routes.dart';
import 'nav_permissions.dart';

/// Sentinel dropdown value for the Super Admin footer action.
const kSuperAdminSentinel = '__SUPER_ADMIN__';

/// Compact org switcher when the user has 2+ orgs, or is a system admin.
class OrganizationSwitcher extends ConsumerWidget {
  const OrganizationSwitcher({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSwitch = ref.watch(canSwitchOrganizationProvider);
    final isAdmin = ref.watch(currentUserRoleProvider).value?.isAdmin ?? false;
    if (!canSwitch && !isAdmin) return const SizedBox.shrink();

    final currentAsync = ref.watch(currentOrganizationControllerProvider);
    return currentAsync.when(
      data: (current) {
        final orgs = ref
            .read(currentOrganizationControllerProvider.notifier)
            .switchableOrganizations();
        if (orgs.isEmpty) return const SizedBox.shrink();

        final selectedId = current?.id ?? orgs.first.id;
        return _OrgDropdown(
          selectedId: selectedId,
          organizations: orgs,
          compact: compact,
          showSuperAdmin: isAdmin,
          onChanged: (id) {
            if (id == kSuperAdminSentinel) {
              const SuperAdminRoute().go(context);
              return;
            }
            final targetOrg = orgs.firstWhere(
              (o) => o.id == id,
              orElse: () => orgs.first,
            );
            final routerState = GoRouterState.of(context);
            final isScoped = routerState.pathParameters['orgSlug'] != null;
            final currentLocation = routerState.uri.path;
            ref
                .read(currentOrganizationControllerProvider.notifier)
                .switchOrganization(
              id,
              afterSelect: () async {
                if (!context.mounted) return;
                final branchSlug = await ref
                    .read(currentBranchControllerProvider.notifier)
                    .defaultBranchSlug();
                if (!context.mounted) return;
                final target = isScoped
                    ? RouterUtils.pathAfterOrganizationSwitch(
                        currentLocation,
                        orgSlug: targetOrg.slug,
                        branchSlug: branchSlug,
                      )
                    : '/${targetOrg.slug}/$branchSlug${DashboardRoute.path}';
                context.go(target);
              },
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _OrgDropdown extends StatelessWidget {
  const _OrgDropdown({
    required this.selectedId,
    required this.organizations,
    required this.onChanged,
    required this.showSuperAdmin,
    this.compact = false,
  });

  final String selectedId;
  final List<Organization> organizations;
  final ValueChanged<String> onChanged;
  final bool showSuperAdmin;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final effectiveValue = organizations.any((o) => o.id == selectedId)
        ? selectedId
        : organizations.first.id;
    final iconSize = compact ? 14.0 : 18.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: compact ? 160 : 220,
      ),
      child: Container(
        width: compact ? double.infinity : 220,
        height: compact ? 40 : null,
        margin: compact
            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 0 : 4,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: effectiveValue,
            isDense: true,
            isExpanded: true,
            icon: Icon(
              Icons.apartment,
              size: compact ? 16 : 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            style: (compact
                    ? theme.textTheme.labelMedium
                    : theme.textTheme.bodyMedium)
                ?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.2,
            ),
            selectedItemBuilder: (context) => [
              for (final org in organizations)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    org.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              if (showSuperAdmin)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    t.organizations.superAdmin,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
            items: [
              for (final org in organizations)
                DropdownMenuItem(
                  value: org.id,
                  child: Text(
                    org.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (showSuperAdmin)
                DropdownMenuItem(
                  value: kSuperAdminSentinel,
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined, size: iconSize),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.organizations.superAdmin,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            hint: Text(
              t.organizations.switchOrganization,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
