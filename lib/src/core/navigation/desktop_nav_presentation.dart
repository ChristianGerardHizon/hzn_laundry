import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';
import '../widgets/nav_permissions.dart';

/// Sidebar grouping for Firebase-style desktop navigation.
enum AppNavCategory {
  operations,
  people,
  insights,
  administration,
}

/// Direct destinations under the Administration flyout (management sections + orgs).
enum AdminFlyoutId {
  users,
  roles,
  branches,
  machines,
  storages,
  productCategories,
  quantityUnits,
  cashierGroups,
  organizations,
}

/// A single row in a desktop category flyout.
class DesktopFlyoutDestination {
  const DesktopFlyoutDestination({
    required this.selectionKey,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// [NavId] for normal categories, or [AdminFlyoutId] for Administration.
  final Object selectionKey;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Default daily shortcuts shown before "Show more".
const List<NavId> defaultShortcutIds = [
  NavId.salesHistory,
  NavId.products,
  NavId.services,
  NavId.customers,
];

/// All categories in display order.
const List<AppNavCategory> appNavCategories = [
  AppNavCategory.operations,
  AppNavCategory.people,
  AppNavCategory.insights,
  AppNavCategory.administration,
];

/// Maps a destination to its sidebar category, if any.
AppNavCategory? appNavCategoryFor(NavId id) {
  switch (id) {
    case NavId.salesHistory:
    case NavId.products:
    case NavId.services:
    case NavId.promos:
      return AppNavCategory.operations;
    case NavId.customers:
    case NavId.employees:
      return AppNavCategory.people;
    case NavId.reports:
    case NavId.activities:
      return AppNavCategory.insights;
    case NavId.management:
    case NavId.organizations:
      return AppNavCategory.administration;
    case NavId.dashboard:
    case NavId.system:
      return null;
  }
}

/// Localized label for [category].
String appNavCategoryLabel(AppNavCategory category, Translations t) {
  switch (category) {
    case AppNavCategory.operations:
      return t.navigation.operations;
    case AppNavCategory.people:
      return t.navigation.people;
    case AppNavCategory.insights:
      return t.navigation.insights;
    case AppNavCategory.administration:
      return t.navigation.administration;
  }
}

IconData appNavCategoryIcon(AppNavCategory category) {
  switch (category) {
    case AppNavCategory.operations:
      return Icons.storefront_outlined;
    case AppNavCategory.people:
      return Icons.groups_outlined;
    case AppNavCategory.insights:
      return Icons.insights_outlined;
    case AppNavCategory.administration:
      return Icons.admin_panel_settings_outlined;
  }
}

/// Visible shortcut ids from [items], preserving [defaultShortcutIds] order.
List<NavId> visibleShortcutIds(List<NavItem> items) {
  final visible = items.map((item) => item.id).toSet();
  return defaultShortcutIds.where(visible.contains).toList(growable: false);
}

/// Extra visible destinations suitable for "Show more" (not dashboard/system/shortcuts).
List<NavId> extraShortcutCandidates(
  List<NavItem> items,
  List<NavId> shownShortcutIds,
) {
  final shown = {...shownShortcutIds, NavId.dashboard, NavId.system};
  return items
      .map((item) => item.id)
      .where((id) => !shown.contains(id))
      .toList(growable: false);
}

/// Category items from [items] excluding ids already shown as shortcuts.
List<NavItem> categoryDestinations(
  AppNavCategory category,
  List<NavItem> items,
  Set<NavId> excludedIds,
) {
  return items
      .where(
        (item) =>
            appNavCategoryFor(item.id) == category &&
            !excludedIds.contains(item.id),
      )
      .toList(growable: false);
}

/// Whether Administration can show any flyout destinations for [items].
bool hasAdministrationFlyoutDestinations(List<NavItem> items) {
  return navItemFor(NavId.management, items) != null ||
      navItemFor(NavId.organizations, items) != null;
}

/// Administration flyout: management sections + Organizations (no Management hub).
///
/// Visibility follows the parent Management / Organizations nav permissions.
/// Shortcut exclusions do not hide these rows — sections stay under Administration.
List<DesktopFlyoutDestination> administrationFlyoutDestinations(
  List<NavItem> items,
  Translations t,
) {
  final destinations = <DesktopFlyoutDestination>[];

  if (navItemFor(NavId.management, items) != null) {
    destinations.addAll([
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.users,
        icon: Icons.people_outlined,
        selectedIcon: Icons.people,
        label: t.navigation.users,
      ),
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.roles,
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings,
        label: t.navigation.roles,
      ),
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.branches,
        icon: Icons.store_outlined,
        selectedIcon: Icons.store,
        label: t.navigation.branches,
      ),
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.machines,
        icon: Icons.local_laundry_service_outlined,
        selectedIcon: Icons.local_laundry_service,
        label: t.navigation.machines,
      ),
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.storages,
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: t.navigation.storages,
      ),
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.productCategories,
        icon: Icons.category_outlined,
        selectedIcon: Icons.category,
        label: t.navigation.productCategories,
      ),
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.quantityUnits,
        icon: Icons.straighten_outlined,
        selectedIcon: Icons.straighten,
        label: t.navigation.units,
      ),
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.cashierGroups,
        icon: Icons.point_of_sale_outlined,
        selectedIcon: Icons.point_of_sale,
        label: t.navigation.cashierGroups,
      ),
    ]);
  }

  if (navItemFor(NavId.organizations, items) != null) {
    final orgs = navItemFor(NavId.organizations, items)!;
    destinations.add(
      DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.organizations,
        icon: orgs.icon,
        selectedIcon: orgs.selectedIcon,
        label: orgs.label,
      ),
    );
  }

  return destinations;
}

/// Flyout rows for [category] (Administration uses section deep-links).
List<DesktopFlyoutDestination> flyoutDestinationsFor(
  AppNavCategory category,
  List<NavItem> items,
  Set<NavId> excludedIds,
  Translations t,
) {
  if (category == AppNavCategory.administration) {
    return administrationFlyoutDestinations(items, t);
  }
  return categoryDestinations(category, items, excludedIds)
      .map(
        (item) => DesktopFlyoutDestination(
          selectionKey: item.id,
          icon: item.icon,
          selectedIcon: item.selectedIcon,
          label: item.label,
        ),
      )
      .toList(growable: false);
}

/// Categories that have at least one visible destination after exclusions.
List<AppNavCategory> visibleCategories(
  List<NavItem> items,
  Set<NavId> excludedIds,
) {
  return appNavCategories
      .where((category) {
        if (category == AppNavCategory.administration) {
          return hasAdministrationFlyoutDestinations(items);
        }
        return categoryDestinations(category, items, excludedIds).isNotEmpty;
      })
      .toList(growable: false);
}

/// Whether [selectedId] matches [id].
bool isNavItemSelected(NavId selectedId, NavId id) => selectedId == id;

/// Whether any destination in [category] is the selected item.
bool isNavCategorySelected(
  NavId selectedId,
  AppNavCategory category,
  List<NavItem> items,
  Set<NavId> excludedIds,
) {
  if (category == AppNavCategory.administration) {
    return selectedId == NavId.management ||
        selectedId == NavId.organizations;
  }
  return categoryDestinations(category, items, excludedIds)
      .any((item) => item.id == selectedId);
}

/// Resolves which Administration flyout row matches [location] (org-scoped OK).
AdminFlyoutId? adminFlyoutIdFromPath(String location) {
  if (location.contains('/organizations')) {
    return AdminFlyoutId.organizations;
  }
  if (!location.contains('/management')) return null;
  if (location.contains('/management/roles')) return AdminFlyoutId.roles;
  if (location.contains('/management/branches')) {
    return AdminFlyoutId.branches;
  }
  if (location.contains('/management/machines')) {
    return AdminFlyoutId.machines;
  }
  if (location.contains('/management/storages')) {
    return AdminFlyoutId.storages;
  }
  if (location.contains('/management/product-categories')) {
    return AdminFlyoutId.productCategories;
  }
  if (location.contains('/management/quantity-units')) {
    return AdminFlyoutId.quantityUnits;
  }
  if (location.contains('/management/cashier-groups')) {
    return AdminFlyoutId.cashierGroups;
  }
  // /management, /management/users, and unknown management children.
  return AdminFlyoutId.users;
}

/// Selection key for highlighting a flyout row.
Object flyoutSelectedKey(
  AppNavCategory category,
  NavId selectedId,
  String location,
) {
  if (category == AppNavCategory.administration) {
    return adminFlyoutIdFromPath(location) ?? selectedId;
  }
  return selectedId;
}

/// First matching item for [id], or null if it is not visible.
NavItem? navItemFor(NavId id, List<NavItem> items) {
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

/// Items whose [NavItem.label] contains [query] (case-insensitive).
///
/// Empty/whitespace [query] returns an empty list so callers show normal nav.
List<NavItem> filterNavItemsByQuery(List<NavItem> items, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return items
      .where((item) => item.label.toLowerCase().contains(q))
      .toList(growable: false);
}
