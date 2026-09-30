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
///
/// Destinations are grouped with the same categories as the desktop sidebar
/// (Operations / People / Insights / Administration) so both shells feel alike.
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
    final isAdmin = ref.watch(currentUserRoleProvider).value?.isAdmin ?? false;

    Widget mapItem(NavItem item) {
      final visibleIndex = visibleItems.indexOf(item);
      return _DrawerItem(
        icon: selectedIndex == visibleIndex ? item.selectedIcon : item.icon,
        label: item.label,
        selected: selectedIndex == visibleIndex,
        onTap: () => _selectAndClose(context, visibleIndex),
      );
    }

    Widget superAdminItem() => _DrawerItem(
          icon: Icons.admin_panel_settings_outlined,
          label: t.organizations.superAdmin,
          selected: false,
          onTap: () {
            Navigator.of(context).pop();
            const SuperAdminRoute().go(context);
          },
        );

    final dashboard = navItemFor(NavId.dashboard, visibleItems);
    final profileItem = navItemFor(NavId.profile, visibleItems);

    // Items with no category (e.g. System) sit with the Account section.
    final accountExtras = visibleItems
        .where((item) =>
            item.id != NavId.dashboard &&
            item.id != NavId.profile &&
            appNavCategoryFor(item.id) == null)
        .toList();

    final orgsVisible = navItemFor(NavId.organizations, visibleItems) != null;

    final sections = <Widget>[];
    for (final category in [
      AppNavCategory.operations,
      AppNavCategory.people,
      AppNavCategory.insights,
      AppNavCategory.administration,
    ]) {
      final items = visibleItems
          .where((item) => appNavCategoryFor(item.id) == category)
          .toList();
      final showSuperAdmin = category == AppNavCategory.administration &&
          isAdmin &&
          orgsVisible;
      if (items.isEmpty) continue;

      sections.add(_SectionLabel(appNavCategoryLabel(category, t)));
      for (final item in items) {
        sections.add(mapItem(item));
        if (showSuperAdmin && item.id == NavId.organizations) {
          sections.add(superAdminItem());
        }
      }
    }

    return Drawer(
      // Edge-to-edge mobile drawer (M3 defaults round the trailing edge and
      // leave a floating gap against the viewport).
      shape: const RoundedRectangleBorder(),
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            // Compact header — avoid DrawerHeader's fixed 160px + bottom align.
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: OrganizationNavBrand(
                logoSize: 40,
                compact: true,
                showServerUrl: true,
              ),
            ),

            // Same compact chip as the shell scope bar.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: BranchSwitcher(compact: true),
            ),
            const SizedBox(height: 8),

            if (dashboard != null) mapItem(dashboard),

            ...sections,

            // Super Admin fallback when Organizations is not in the drawer list
            if (isAdmin && !orgsVisible) ...[
              _SectionLabel(t.navigation.administration),
              superAdminItem(),
            ],

            if (profileItem != null || accountExtras.isNotEmpty) ...[
              _SectionLabel(t.navigation.account),
              if (profileItem != null) mapItem(profileItem),
              ...accountExtras.map(mapItem),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(indent: 16, endIndent: 16),
            ),

            _DrawerItem(
              icon: Icons.logout,
              label: t.auth.logoutButton,
              selected: false,
              color: theme.colorScheme.error,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// 56dp pill row (Material 3 navigation-drawer destination style).
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
    final scheme = Theme.of(context).colorScheme;
    final foreground = color ??
        (selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        shape: const StadiumBorder(),
        minTileHeight: 56,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        selected: selected,
        selectedTileColor: scheme.secondaryContainer,
        leading: Icon(icon, color: foreground),
        title: Text(
          label,
          style: TextStyle(
            color: color ?? (selected ? scheme.onSecondaryContainer : null),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
