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

/// Categories that have at least one visible destination after exclusions.
List<AppNavCategory> visibleCategories(
  List<NavItem> items,
  Set<NavId> excludedIds,
) {
  return appNavCategories
      .where(
        (category) =>
            categoryDestinations(category, items, excludedIds).isNotEmpty,
      )
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
  return categoryDestinations(category, items, excludedIds)
      .any((item) => item.id == selectedId);
}

/// First matching item for [id], or null if it is not visible.
NavItem? navItemFor(NavId id, List<NavItem> items) {
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}
