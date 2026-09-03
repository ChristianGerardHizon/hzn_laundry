import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../config/app_environment.dart';
import '../i18n/strings.g.dart';
import '../navigation/desktop_nav_presentation.dart';
import 'desktop_nav_flyout.dart';
import 'desktop_nav_item.dart';
import 'nav_permissions.dart';
import 'network_health_logo.dart';

/// Firebase-style sidebar for tablet-large and desktop layouts (>=900px).
class DesktopSideNav extends HookConsumerWidget {
  const DesktopSideNav({
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

  static const double expandedWidth = 260;
  static const double collapsedWidth = 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final collapsed = useState(false);
    final showAllShortcuts = useState(false);

    final width = collapsed.value ? collapsedWidth : expandedWidth;
    final safeSelected = visibleItems.isEmpty
        ? 0
        : selectedIndex.clamp(0, visibleItems.length - 1);
    final selectedId =
        visibleItems.isEmpty ? NavId.dashboard : visibleItems[safeSelected].id;

    final defaultShortcuts = visibleShortcutIds(visibleItems);
    final extraShortcuts =
        extraShortcutCandidates(visibleItems, defaultShortcuts);
    final shownShortcutIds = {
      ...defaultShortcuts,
      if (showAllShortcuts.value) ...extraShortcuts,
    };
    final categories = visibleCategories(visibleItems, shownShortcutIds);

    void tapItem(NavItem item) {
      final index = visibleItems.indexWhere((e) => e.id == item.id);
      if (index >= 0) onDestinationSelected(index);
    }

    void tapId(NavId id) {
      final item = navItemFor(id, visibleItems);
      if (item != null) tapItem(item);
    }

    Widget buildShortcutItem(NavId id) {
      final item = navItemFor(id, visibleItems);
      if (item == null) return const SizedBox.shrink();
      final selected = isNavItemSelected(selectedId, id);

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed.value ? 8 : 12,
          vertical: 2,
        ),
        child: DesktopNavItem(
          icon: selected ? item.selectedIcon : item.icon,
          label: item.label,
          selected: selected,
          collapsed: collapsed.value,
          onTap: () => tapId(id),
        ),
      );
    }

    final dashboardItem = navItemFor(NavId.dashboard, visibleItems);
    final systemItem = navItemFor(NavId.system, visibleItems);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              collapsed.value ? 12 : 20,
              20,
              collapsed.value ? 12 : 16,
              12,
            ),
            child: collapsed.value
                ? const Center(child: NetworkHealthLogo(size: 32))
                : Row(
                    children: [
                      const NetworkHealthLogo(size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              appTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.15,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Tooltip(
                              message: pocketbaseUrl,
                              child: Text(
                                pocketbaseUrl,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (dashboardItem != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: collapsed.value ? 8 : 12,
                      vertical: 2,
                    ),
                    child: DesktopNavItem(
                      icon: isNavItemSelected(selectedId, NavId.dashboard)
                          ? dashboardItem.selectedIcon
                          : dashboardItem.icon,
                      label: dashboardItem.label,
                      selected: isNavItemSelected(selectedId, NavId.dashboard),
                      collapsed: collapsed.value,
                      onTap: () => tapId(NavId.dashboard),
                    ),
                  ),
                if (defaultShortcuts.isNotEmpty) ...[
                  if (!collapsed.value)
                    DesktopNavSectionHeader(label: t.navigation.shortcuts),
                  for (final id in defaultShortcuts) buildShortcutItem(id),
                  if (!collapsed.value && extraShortcuts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: TextButton.icon(
                        onPressed: () =>
                            showAllShortcuts.value = !showAllShortcuts.value,
                        icon: Icon(
                          showAllShortcuts.value
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(
                          showAllShortcuts.value
                              ? t.navigation.showLess
                              : t.navigation.showMore,
                        ),
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  if (showAllShortcuts.value)
                    for (final id in extraShortcuts) buildShortcutItem(id),
                ],
                if (categories.isNotEmpty) ...[
                  if (!collapsed.value)
                    DesktopNavSectionHeader(label: t.navigation.categories),
                  for (final category in categories)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: collapsed.value ? 8 : 12,
                        vertical: 4,
                      ),
                      child: DesktopNavCategoryRow(
                        category: category,
                        destinations: categoryDestinations(
                          category,
                          visibleItems,
                          shownShortcutIds,
                        ),
                        selectedId: selectedId,
                        collapsed: collapsed.value,
                        selected: isNavCategorySelected(
                          selectedId,
                          category,
                          visibleItems,
                          shownShortcutIds,
                        ),
                        onDestinationTap: tapItem,
                      ),
                    ),
                ],
                if (systemItem != null) ...[
                  SizedBox(height: collapsed.value ? 8 : 12),
                  if (!collapsed.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Divider(height: 1),
                    ),
                  SizedBox(height: collapsed.value ? 4 : 8),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: collapsed.value ? 8 : 12,
                      vertical: 4,
                    ),
                    child: DesktopNavItem(
                      icon: isNavItemSelected(selectedId, NavId.system)
                          ? systemItem.selectedIcon
                          : systemItem.icon,
                      label: systemItem.label,
                      selected: isNavItemSelected(selectedId, NavId.system),
                      collapsed: collapsed.value,
                      onTap: () => tapId(NavId.system),
                      trailing: collapsed.value
                          ? null
                          : Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              collapsed.value ? 4 : 8,
              12,
              collapsed.value ? 4 : 8,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DesktopNavItem(
                  icon: Icons.logout,
                  label: t.auth.logoutButton,
                  selected: false,
                  collapsed: collapsed.value,
                  onTap: () => _confirmLogout(context, ref, t),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: collapsed.value
                        ? t.navigation.expandNav
                        : t.navigation.collapseNav,
                    icon: Icon(
                      collapsed.value
                          ? Icons.chevron_right
                          : Icons.chevron_left,
                    ),
                    onPressed: () => collapsed.value = !collapsed.value,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, Translations t) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.auth.logoutButton),
        content: Text(t.auth.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              dialogContext.pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text(t.auth.logoutButton),
          ),
        ],
      ),
    );
  }
}
