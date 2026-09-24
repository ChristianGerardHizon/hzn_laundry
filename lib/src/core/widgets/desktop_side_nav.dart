import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../i18n/strings.g.dart';
import '../navigation/desktop_nav_presentation.dart';
import '../routing/routes/org_selection.routes.dart';
import 'desktop_nav_flyout.dart';
import 'desktop_nav_item.dart';
import 'nav_permissions.dart';
import 'organization_nav_brand.dart';

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
    final searchQuery = useState('');
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();

    final width = collapsed.value ? collapsedWidth : expandedWidth;
    final safeSelected = visibleItems.isEmpty
        ? 0
        : selectedIndex.clamp(0, visibleItems.length - 1);
    final selectedId =
        visibleItems.isEmpty ? NavId.dashboard : visibleItems[safeSelected].id;

    final isSearching = !collapsed.value && searchQuery.value.trim().isNotEmpty;
    final searchResults = isSearching
        ? filterNavItemsByQuery(visibleItems, searchQuery.value)
        : const <NavItem>[];

    final isAdmin =
        ref.watch(currentUserRoleProvider).value?.isAdmin ?? false;
    final defaultShortcuts = visibleShortcutIds(visibleItems);
    final extraShortcuts =
        extraShortcutCandidates(visibleItems, defaultShortcuts);
    final shownShortcutIds = {
      ...defaultShortcuts,
      if (showAllShortcuts.value) ...extraShortcuts,
    };
    final categories = [
      ...visibleCategories(visibleItems, shownShortcutIds),
    ];
    // Keep Administration visible for system admins so the Super Admin
    // footer remains reachable even when its destinations are shortcuts.
    if (isAdmin &&
        !categories.contains(AppNavCategory.administration)) {
      categories.add(AppNavCategory.administration);
    }
    final superAdminFooter = isAdmin
        ? DesktopNavFlyoutFooter(
            icon: Icons.admin_panel_settings_outlined,
            label: t.organizations.superAdmin,
            onTap: () => const SuperAdminRoute().go(context),
          )
        : null;

    void clearSearch() {
      searchQuery.value = '';
      searchController.clear();
      searchFocusNode.unfocus();
    }

    void tapItem(NavItem item) {
      final index = visibleItems.indexWhere((e) => e.id == item.id);
      if (index >= 0) onDestinationSelected(index);
    }

    void tapId(NavId id) {
      final item = navItemFor(id, visibleItems);
      if (item != null) tapItem(item);
    }

    void tapSearchResult(NavItem item) {
      tapItem(item);
      clearSearch();
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
                ? const Center(
                    child: OrganizationNavBrand(
                      logoSize: 32,
                      showLabel: false,
                    ),
                  )
                : const OrganizationNavBrand(logoSize: 32),
          ),
          if (!collapsed.value)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _NavSearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: t.navigation.searchNavHint,
                onChanged: (value) => searchQuery.value = value,
                onClear: clearSearch,
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ListView(
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
                          selected:
                              isNavItemSelected(selectedId, NavId.dashboard),
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
                            onPressed: () => showAllShortcuts.value =
                                !showAllShortcuts.value,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                            footer: category == AppNavCategory.administration
                                ? superAdminFooter
                                : null,
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
                if (isSearching)
                  Positioned(
                    left: 8,
                    right: 8,
                    top: 4,
                    child: _NavSearchResultsOverlay(
                      results: searchResults,
                      selectedId: selectedId,
                      resultsLabel: t.navigation.searchResults,
                      emptyLabel: t.navigation.noSearchResults,
                      onResultTap: tapSearchResult,
                    ),
                  ),
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
                    onPressed: () {
                      final next = !collapsed.value;
                      if (next) clearSearch();
                      collapsed.value = next;
                    },
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

class _NavSearchField extends StatelessWidget {
  const _NavSearchField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasText = controller.text.isNotEmpty;

    return Material(
      type: MaterialType.transparency,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: Icon(
                    Icons.cancel,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _NavSearchResultsOverlay extends StatelessWidget {
  const _NavSearchResultsOverlay({
    required this.results,
    required this.selectedId,
    required this.resultsLabel,
    required this.emptyLabel,
    required this.onResultTap,
  });

  final List<NavItem> results;
  final NavId selectedId;
  final String resultsLabel;
  final String emptyLabel;
  final ValueChanged<NavItem> onResultTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                resultsLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  emptyLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final item in results)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: DesktopNavItem(
                    icon: isNavItemSelected(selectedId, item.id)
                        ? item.selectedIcon
                        : item.icon,
                    label: item.label,
                    selected: isNavItemSelected(selectedId, item.id),
                    onTap: () => onResultTap(item),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
