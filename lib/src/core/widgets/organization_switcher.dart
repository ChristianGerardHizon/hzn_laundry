import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/domain/organization.dart';
import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../i18n/strings.g.dart';

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
            ref
                .read(currentOrganizationControllerProvider.notifier)
                .switchOrganization(id);
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

    return Container(
      width: compact ? null : 220,
      margin: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 12,
        vertical: compact ? 0 : 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: compact ? null : BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          isDense: compact,
          icon: Icon(Icons.apartment, size: compact ? 16 : 20),
          style: compact
              ? theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.bodyMedium,
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
          hint: Text(t.organizations.switchOrganization),
        ),
      ),
    );
  }
}
