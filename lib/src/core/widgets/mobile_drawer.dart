import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../i18n/strings.g.dart';
import '../navigation/desktop_nav_presentation.dart';
import '../routing/routes/org_selection.routes.dart';
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
    final isAdmin =
        ref.watch(currentUserRoleProvider).value?.isAdmin ?? false;

    // Split visible items into primary (index <= 5) and secondary (index > 5).
    // Profile is rendered in its own Account section above logout.
    final primaryItems = visibleItems
        .where((item) => item.index <= 5 && item.id != NavId.profile)
        .toList();
    final secondaryItems = visibleItems
        .where((item) => item.index > 5 && item.id != NavId.profile)
        .toList();
    final profileItem = navItemFor(NavId.profile, visibleItems);

    Widget mapItem(NavItem item) {
      final visibleIndex = visibleItems.indexOf(item);
      return _DrawerItem(
        icon: item.icon,
        label: item.label,
        selected: selectedIndex == visibleIndex,
        onTap: () => _selectAndClose(context, visibleIndex),
      );
    }

    List<Widget> withSuperAdminAfterOrganizations(List<NavItem> items) {
      final widgets = <Widget>[];
      for (final item in items) {
        widgets.add(mapItem(item));
        if (isAdmin && item.id == NavId.organizations) {
          widgets.add(
            _DrawerItem(
              icon: Icons.admin_panel_settings_outlined,
              label: t.organizations.superAdmin,
              selected: false,
              onTap: () {
                Navigator.of(context).pop();
                const SuperAdminRoute().go(context);
              },
            ),
          );
        }
      }
      return widgets;
    }

    final orgsInPrimary =
        primaryItems.any((item) => item.id == NavId.organizations);
    final orgsInSecondary =
        secondaryItems.any((item) => item.id == NavId.organizations);

    return Drawer(
      // Edge-to-edge mobile drawer (M3 defaults round the trailing edge and
      // leave a floating gap against the viewport).
      shape: const RoundedRectangleBorder(),
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Compact header — avoid DrawerHeader's fixed 160px + bottom align.
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: OrganizationNavBrand(
                logoSize: 40,
                compact: true,
                showServerUrl: true,
              ),
            ),

            // Branch switcher
            const BranchSwitcher(),

            // Primary navigation items
            ...withSuperAdminAfterOrganizations(primaryItems),

            if (secondaryItems.isNotEmpty) const Divider(),

            // Secondary navigation items
            ...withSuperAdminAfterOrganizations(secondaryItems),

            // Super Admin fallback when Organizations is not in the drawer list
            if (isAdmin && !orgsInPrimary && !orgsInSecondary)
              _DrawerItem(
                icon: Icons.admin_panel_settings_outlined,
                label: t.organizations.superAdmin,
                selected: false,
                onTap: () {
                  Navigator.of(context).pop();
                  const SuperAdminRoute().go(context);
                },
              ),

            if (profileItem != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  t.navigation.account,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              mapItem(profileItem),
            ],

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
