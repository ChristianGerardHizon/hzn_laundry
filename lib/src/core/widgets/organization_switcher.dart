import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/domain/organization.dart';
import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../i18n/strings.g.dart';
import '../routing/router_utils.dart';
import '../routing/routes/dashboard.routes.dart';

/// Compact org switcher shown only when the user belongs to 2+ organizations.
class OrganizationSwitcher extends ConsumerWidget {
  const OrganizationSwitcher({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSwitch = ref.watch(canSwitchOrganizationProvider);
    if (!canSwitch) return const SizedBox.shrink();

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
          onChanged: (id) {
            final targetOrg = orgs.firstWhere(
              (o) => o.id == id,
              orElse: () => orgs.first,
            );
            final routerState = GoRouterState.of(context);
            final isScoped = routerState.pathParameters['orgSlug'] != null;
            final currentLocation = routerState.uri.path;
            ref.read(currentOrganizationControllerProvider.notifier).switchOrganization(
              id,
              afterSelect: () async {
                if (!context.mounted) return;
                final branchSlug = await ref
                    .read(currentBranchControllerProvider.notifier)
                    .defaultBranchSlug();
                if (!context.mounted) return;
                final target = isScoped
                    ? RouterUtils.replaceScopeSegment(
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
    this.compact = false,
  });

  final String selectedId;
  final List<Organization> organizations;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final effectiveValue = organizations.any((o) => o.id == selectedId)
        ? selectedId
        : organizations.first.id;

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
          borderRadius: BorderRadius.circular(compact ? 8 : 8),
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
            selectedItemBuilder: (context) => organizations
                .map(
                  (org) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      org.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(),
            items: organizations
                .map(
                  (org) => DropdownMenuItem(
                    value: org.id,
                    child: Text(
                      org.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
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
