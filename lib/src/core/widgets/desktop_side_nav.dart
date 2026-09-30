import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/entitlements/presentation/controllers/organization_entitlements_provider.dart';
import '../i18n/strings.g.dart';
import '../navigation/desktop_nav_presentation.dart';
import '../navigation/nav_preferences.dart';
import '../navigation/nav_preferences_controller.dart';
import '../routing/org_scoped_navigation.dart';
import '../routing/routes/management.routes.dart';
import '../routing/routes/org_selection.routes.dart';
import '../routing/routes/organizations.routes.dart';
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

    final entitlements =
        ref.watch(currentOrganizationEntitlementsProvider).value;
    final isAdmin = ref.watch(currentUserRoleProvider).value?.isAdmin ?? false;

    // Local, per-user customisation. `null` while the first read is in flight.
    final prefsAsync = ref.watch(navPreferencesControllerProvider);
    final prefs =
        prefsAsync.hasError ? NavPreferences.defaults : prefsAsync.value;
    final prefsController = ref.read(navPreferencesControllerProvider.notifier);

    final location = GoRouterState.of(context).uri.path;

    // Keep Administration visible for system admins so the Super Admin
    // link remains reachable.
    final categories = [...visibleCategories(visibleItems, const {})];
    if (isAdmin && !categories.contains(AppNavCategory.administration)) {
      categories.add(AppNavCategory.administration);
    }
    final destinationsByCategory = {
      for (final category in categories)
        category: flyoutDestinationsFor(
          category,
          visibleItems,
          const {},
          t,
          isFeatureEnabled: entitlements?.isEnabled,
        ),
    };
    final pinned = prefs == null
        ? const <DesktopFlyoutDestination>[]
        : resolvePinnedDestinations(
            prefs.pinnedKeys,
            destinationsByCategory.values.expand((d) => d),
          );
    final pinnedKeys = {for (final d in pinned) navPinKey(d.selectionKey)};

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

    void navigateAdminSection(AdminFlyoutId id) {
      switch (id) {
        case AdminFlyoutId.users:
          const ManagementUsersRoute().goScoped(context);
        case AdminFlyoutId.roles:
          const ManagementRolesRoute().goScoped(context);
        case AdminFlyoutId.branches:
          const ManagementBranchesRoute().goScoped(context);
        case AdminFlyoutId.machines:
          const ManagementMachinesRoute().goScoped(context);
        case AdminFlyoutId.storages:
          const ManagementStoragesRoute().goScoped(context);
        case AdminFlyoutId.productCategories:
          const ManagementProductCategoriesRoute().goScoped(context);
        case AdminFlyoutId.quantityUnits:
          const ManagementQuantityUnitsRoute().goScoped(context);
        case AdminFlyoutId.cashierGroups:
          const ManagementCashierGroupsRoute().goScoped(context);
        case AdminFlyoutId.organizations:
          const OrganizationsRoute().goScoped(context);
      }
    }

    void tapDestination(DesktopFlyoutDestination dest) {
      final key = dest.selectionKey;
      if (key is AdminFlyoutId) {
        navigateAdminSection(key);
      } else {
        tapId(key as NavId);
      }
    }

    void tapSearchResult(NavItem item) {
      tapItem(item);
      clearSearch();
    }

    final superAdminFooter = isAdmin
        ? DesktopNavFlyoutFooter(
            icon: Icons.admin_panel_settings_outlined,
            label: t.organizations.superAdmin,
            onTap: () => const SuperAdminRoute().go(context),
          )
        : null;

    Widget pinnableTile(
      DesktopFlyoutDestination dest, {
      required bool isPinned,
      required String keyPrefix,
    }) {
      final pinKey = navPinKey(dest.selectionKey);
      final selected = isDestinationSelected(dest, selectedId, location);
      return Padding(
        key: ValueKey('$keyPrefix:$pinKey'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        child: DesktopPinnableNavItem(
          icon: selected ? dest.selectedIcon : dest.icon,
          label: dest.label,
          selected: selected,
          pinned: isPinned,
          pinTooltip: isPinned ? t.navigation.unpin : t.navigation.pinToTop,
          onTap: () => tapDestination(dest),
          onTogglePin: () => prefsController.togglePin(pinKey),
        ),
      );
    }

    Widget plainTile(NavItem? item, NavId id, {Widget? trailing}) {
      if (item == null) return const SizedBox.shrink();
      final selected = isNavItemSelected(selectedId, id);
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed.value ? 8 : 12,
          vertical: collapsed.value ? 2 : 1,
        ),
        child: DesktopNavItem(
          icon: selected ? item.selectedIcon : item.icon,
          label: item.label,
          selected: selected,
          collapsed: collapsed.value,
          onTap: () => tapId(id),
          trailing: collapsed.value ? null : trailing,
        ),
      );
    }

    Widget buildGroup(AppNavCategory category) {
      final entries = [
        for (final d in destinationsByCategory[category]!)
          if (!pinnedKeys.contains(navPinKey(d.selectionKey))) d,
      ];
      final showSuperAdmin =
          isAdmin && category == AppNavCategory.administration;
      if (entries.isEmpty && !showSuperAdmin) return const SizedBox.shrink();

      // Children are discarded while [prefs] is still loading.
      final isCollapsed = prefs?.isCollapsed(category) ?? false;
      // A collapsed group still shows the page you are on, so you never lose
      // your place in the sidebar.
      final shown = isCollapsed
          ? [
              for (final d in entries)
                if (isDestinationSelected(d, selectedId, location)) d,
            ]
          : entries;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesktopNavGroupHeader(
            label: appNavCategoryLabel(category, t),
            expanded: !isCollapsed,
            toggleTooltip: isCollapsed
                ? t.navigation.expandGroup
                : t.navigation.collapseGroup,
            onToggle: () => prefsController.toggleGroup(category),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final d in shown)
                  pinnableTile(d, isPinned: false, keyPrefix: 'group'),
                if (showSuperAdmin && !isCollapsed)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                    child: DesktopNavItem(
                      icon: superAdminFooter!.icon,
                      label: superAdminFooter.label,
                      selected: false,
                      onTap: superAdminFooter.onTap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    final dashboardItem = navItemFor(NavId.dashboard, visibleItems);
    final systemItem = navItemFor(NavId.system, visibleItems);
    final profileItem = navItemFor(NavId.profile, visibleItems);

    // Expanded: everything inline (no hover flyouts) so each page is one click.
    final expandedChildren = <Widget>[
      plainTile(dashboardItem, NavId.dashboard),
      if (pinned.isNotEmpty) ...[
        DesktopNavSectionHeader(label: t.navigation.pinned),
        for (final d in pinned)
          pinnableTile(d, isPinned: true, keyPrefix: 'pinned'),
      ],
      for (final category in categories) buildGroup(category),
    ];

    // Collapsed rail: icons only; groups open as flyouts on tap.
    final railChildren = <Widget>[
      plainTile(dashboardItem, NavId.dashboard),
      for (final d in pinned)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: DesktopNavItem(
            icon: isDestinationSelected(d, selectedId, location)
                ? d.selectedIcon
                : d.icon,
            label: d.label,
            selected: isDestinationSelected(d, selectedId, location),
            collapsed: true,
            onTap: () => tapDestination(d),
          ),
        ),
      if (pinned.isNotEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Divider(height: 1),
        ),
      for (final category in categories)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: DesktopNavCategoryRow(
            category: category,
            destinations: destinationsByCategory[category]!,
            selectedKey: flyoutSelectedKey(category, selectedId, location),
            collapsed: true,
            selected: destinationsByCategory[category]!.any(
              (d) => isDestinationSelected(d, selectedId, location),
            ),
            onDestinationTap: tapDestination,
            footer: category == AppNavCategory.administration
                ? superAdminFooter
                : null,
          ),
        ),
    ];

    final collapseButton = IconButton(
      tooltip:
          collapsed.value ? t.navigation.expandNav : t.navigation.collapseNav,
      style: IconButton.styleFrom(fixedSize: const Size.square(40)),
      icon: Icon(collapsed.value ? Icons.chevron_right : Icons.chevron_left),
      onPressed: () {
        final next = !collapsed.value;
        if (next) clearSearch();
        collapsed.value = next;
      },
    );

    final logoutItem = DesktopNavItem(
      icon: Icons.logout,
      label: t.auth.logoutButton,
      selected: false,
      collapsed: collapsed.value,
      onTap: () => _confirmLogout(context, ref, t),
    );

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
                  children: prefs == null
                      ? const <Widget>[]
                      : collapsed.value
                          ? railChildren
                          : expandedChildren,
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
          // Always-reachable footer: account, settings, sign out + collapse.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                plainTile(profileItem, NavId.profile),
                plainTile(
                  systemItem,
                  NavId.system,
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: collapsed.value ? 8 : 12,
                    vertical: 1,
                  ),
                  child: collapsed.value
                      ? Column(
                          children: [logoutItem, collapseButton],
                        )
                      : Row(
                          children: [
                            Expanded(child: logoutItem),
                            const SizedBox(width: 4),
                            collapseButton,
                          ],
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
                  tooltip:
                      MaterialLocalizations.of(context).deleteButtonTooltip,
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
