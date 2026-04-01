import 'package:flutter/material.dart';

import '../../../../core/i18n/strings.g.dart';

/// Organization management modes.
enum OrganizationMode { users, roles, branches, machines, storages }

/// Vertical navigation panel for selecting organization mode.
///
/// Displays icons for Users and Roles in a NavigationRail-style layout.
class OrganizationNavPanel extends StatelessWidget {
  const OrganizationNavPanel({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  /// Currently selected mode.
  final OrganizationMode currentMode;

  /// Callback when mode is changed.
  final ValueChanged<OrganizationMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Header icon
          Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.business,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          // Users button
          _NavButton(
            icon: Icons.people_outlined,
            selectedIcon: Icons.people,
            label: t.navigation.users,
            isSelected: currentMode == OrganizationMode.users,
            onTap: () => onModeChanged(OrganizationMode.users),
          ),
          const SizedBox(height: 4),
          // Roles button
          _NavButton(
            icon: Icons.admin_panel_settings_outlined,
            selectedIcon: Icons.admin_panel_settings,
            label: t.navigation.roles,
            isSelected: currentMode == OrganizationMode.roles,
            onTap: () => onModeChanged(OrganizationMode.roles),
          ),
          const SizedBox(height: 4),
          // Branches button
          _NavButton(
            icon: Icons.store_outlined,
            selectedIcon: Icons.store,
            label: t.navigation.branches,
            isSelected: currentMode == OrganizationMode.branches,
            onTap: () => onModeChanged(OrganizationMode.branches),
          ),
          const SizedBox(height: 4),
          // Machines button
          _NavButton(
            icon: Icons.local_laundry_service_outlined,
            selectedIcon: Icons.local_laundry_service,
            label: 'Machines',
            isSelected: currentMode == OrganizationMode.machines,
            onTap: () => onModeChanged(OrganizationMode.machines),
          ),
          const SizedBox(height: 4),
          // Storages button
          _NavButton(
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
            label: 'Storages',
            isSelected: currentMode == OrganizationMode.storages,
            onTap: () => onModeChanged(OrganizationMode.storages),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.secondaryContainer : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
