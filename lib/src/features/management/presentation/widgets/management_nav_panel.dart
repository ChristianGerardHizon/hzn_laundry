import 'package:flutter/material.dart';

import '../../../../core/i18n/strings.g.dart';

/// Organization management modes.
enum ManagementMode {
  users,
  roles,
  branches,
  machines,
  storages,
  productCategories,
  quantityUnits,
  cashierGroups,
  import,
  settings,
}

/// Vertical navigation panel for selecting organization mode.
class ManagementNavPanel extends StatelessWidget {
  const ManagementNavPanel({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  /// Currently selected mode.
  final ManagementMode currentMode;

  /// Callback when mode is changed.
  final ValueChanged<ManagementMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.business,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                _NavButton(
                  icon: Icons.people_outlined,
                  selectedIcon: Icons.people,
                  label: t.navigation.users,
                  isSelected: currentMode == ManagementMode.users,
                  onTap: () => onModeChanged(ManagementMode.users),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.admin_panel_settings_outlined,
                  selectedIcon: Icons.admin_panel_settings,
                  label: t.navigation.roles,
                  isSelected: currentMode == ManagementMode.roles,
                  onTap: () => onModeChanged(ManagementMode.roles),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.store_outlined,
                  selectedIcon: Icons.store,
                  label: t.navigation.branches,
                  isSelected: currentMode == ManagementMode.branches,
                  onTap: () => onModeChanged(ManagementMode.branches),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.local_laundry_service_outlined,
                  selectedIcon: Icons.local_laundry_service,
                  label: 'Machines',
                  isSelected: currentMode == ManagementMode.machines,
                  onTap: () => onModeChanged(ManagementMode.machines),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2,
                  label: 'Storages',
                  isSelected: currentMode == ManagementMode.storages,
                  onTap: () => onModeChanged(ManagementMode.storages),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.category_outlined,
                  selectedIcon: Icons.category,
                  label: 'Categories',
                  isSelected: currentMode == ManagementMode.productCategories,
                  onTap: () => onModeChanged(ManagementMode.productCategories),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.straighten_outlined,
                  selectedIcon: Icons.straighten,
                  label: 'Units',
                  isSelected: currentMode == ManagementMode.quantityUnits,
                  onTap: () => onModeChanged(ManagementMode.quantityUnits),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.point_of_sale_outlined,
                  selectedIcon: Icons.point_of_sale,
                  label: 'Cashier',
                  isSelected: currentMode == ManagementMode.cashierGroups,
                  onTap: () => onModeChanged(ManagementMode.cashierGroups),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.file_upload_outlined,
                  selectedIcon: Icons.file_upload,
                  label: 'Import',
                  isSelected: currentMode == ManagementMode.import,
                  onTap: () => onModeChanged(ManagementMode.import),
                ),
                const SizedBox(height: 4),
                _NavButton(
                  icon: Icons.tune_outlined,
                  selectedIcon: Icons.tune,
                  label: 'Settings',
                  isSelected: currentMode == ManagementMode.settings,
                  onTap: () => onModeChanged(ManagementMode.settings),
                ),
              ],
            ),
          ),
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
