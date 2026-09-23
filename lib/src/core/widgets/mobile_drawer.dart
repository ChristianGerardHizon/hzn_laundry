import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../i18n/strings.g.dart';
import 'branch_switcher.dart';
import 'nav_permissions.dart';
import 'organization_nav_brand.dart';

/// Mobile drawer with permission-filtered navigation menu.
class MobileDrawer extends ConsumerWidget {
  const MobileDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.visibleItems,
  });

  /// Currently selected navigation index (within visible items).
  final int selectedIndex;

  /// Callback when a destination is selected (visible index).
  final ValueChanged<int> onDestinationSelected;

  /// Permission-filtered navigation items.
  final List<NavItem> visibleItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    // Split visible items into primary (index <= 5) and secondary (index > 5)
    final primaryItems = visibleItems.where((item) => item.index <= 5).toList();
    final secondaryItems =
        visibleItems.where((item) => item.index > 5).toList();

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: OrganizationNavBrand(
                  logoSize: 48,
                  compact: true,
                  showServerUrl: true,
                ),
              ),
            ),

            // Branch switcher
            const BranchSwitcher(),

            // Primary navigation items
            ...primaryItems.map((item) {
              final visibleIndex = visibleItems.indexOf(item);
              return _DrawerItem(
                icon: item.icon,
                label: item.label,
                selected: selectedIndex == visibleIndex,
                onTap: () => _selectAndClose(context, visibleIndex),
              );
            }),

            if (secondaryItems.isNotEmpty) const Divider(),

            // Secondary navigation items
            ...secondaryItems.map((item) {
              final visibleIndex = visibleItems.indexOf(item);
              return _DrawerItem(
                icon: item.icon,
                label: item.label,
                selected: selectedIndex == visibleIndex,
                onTap: () => _selectAndClose(context, visibleIndex),
              );
            }),

            const Divider(),

            // Logout
            _DrawerItem(
              icon: Icons.logout,
              label: t.auth.logoutButton,
              selected: false,
              color: Colors.red,
              onTap: () => _confirmLogout(context, ref, t),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAndClose(BuildContext context, int index) {
    Navigator.of(context).pop();
    onDestinationSelected(index);
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, Translations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.auth.logoutButton),
        content: Text(t.auth.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text(t.auth.logoutButton),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: color != null ? TextStyle(color: color) : null),
      selected: selected,
      onTap: onTap,
    );
  }
}
