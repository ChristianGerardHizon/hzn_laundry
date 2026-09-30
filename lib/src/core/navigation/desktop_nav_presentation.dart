import 'package:flutter/material.dart';

import '../../features/entitlements/domain/feature_key.dart';
import '../i18n/strings.g.dart';
import '../widgets/nav_permissions.dart';

/// Sidebar grouping for desktop navigation.
///
/// - [operations]: day-to-day work (orders, catalog, promos)
/// - [people]: customers and staff
/// - [insights]: reports and audit trail
/// - [setup]: business configuration (branches, machines, catalog structure)
/// - [administration]: access control and organizations
enum AppNavCategory {
  operations,
  people,
  insights,
  setup,
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

/// Stable key used to persist a pinned destination (a [NavId] or [AdminFlyoutId]).
String navPinKey(Object selectionKey) => switch (selectionKey) {
      NavId id => 'nav.${id.name}',
      AdminFlyoutId id => 'admin.${id.name}',
      _ => selectionKey.toString(),
    };

/// Destinations pinned for a user who has never customised the sidebar.
final List<String> defaultPinnedKeys = [
  NavId.salesHistory,
  NavId.products,
  NavId.services,
  NavId.customers,
].map(navPinKey).toList(growable: false);

/// Groups collapsed by default (rarely used configuration areas).
final Set<String> defaultCollapsedGroups = {
  AppNavCategory.setup.name,
  AppNavCategory.administration.name,
};

/// All categories in display order.
const List<AppNavCategory> appNavCategories = [
  AppNavCategory.operations,
  AppNavCategory.people,
  AppNavCategory.insights,
  AppNavCategory.setup,
  AppNavCategory.administration,
];

/// Which admin group an [AdminFlyoutId] belongs to.
AppNavCategory adminFlyoutCategory(AdminFlyoutId id) {
  switch (id) {
    case AdminFlyoutId.users:
    case AdminFlyoutId.roles:
    case AdminFlyoutId.organizations:
      return AppNavCategory.administration;
    case AdminFlyoutId.branches:
    case AdminFlyoutId.machines:
    case AdminFlyoutId.storages:
    case AdminFlyoutId.productCategories:
    case AdminFlyoutId.quantityUnits:
    case AdminFlyoutId.cashierGroups:
      return AppNavCategory.setup;
  }
}

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
    case NavId.profile:
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
    case AppNavCategory.setup:
      return t.navigation.setup;
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
    case AppNavCategory.setup:
      return Icons.tune_outlined;
    case AppNavCategory.administration:
      return Icons.admin_panel_settings_outlined;
  }
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
///
/// [isFeatureEnabled] hides Storages / Cashier Layout when their feature is
/// off for the organization (defaults to everything enabled).
List<DesktopFlyoutDestination> administrationFlyoutDestinations(
  List<NavItem> items,
  Translations t, {
  bool Function(FeatureKey feature)? isFeatureEnabled,
}) {
  bool featureOn(FeatureKey feature) =>
      isFeatureEnabled == null || isFeatureEnabled(feature);
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
      if (featureOn(FeatureKey.storages))
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
      if (featureOn(FeatureKey.posGroups))
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

/// Destinations for [category]. Setup and Administration use section
/// deep-links; the other groups use top-level nav items.
List<DesktopFlyoutDestination> flyoutDestinationsFor(
  AppNavCategory category,
  List<NavItem> items,
  Set<NavId> excludedIds,
  Translations t, {
  bool Function(FeatureKey feature)? isFeatureEnabled,
}) {
  if (category == AppNavCategory.setup ||
      category == AppNavCategory.administration) {
    return administrationFlyoutDestinations(
      items,
      t,
      isFeatureEnabled: isFeatureEnabled,
    )
        .where(
          (d) =>
              adminFlyoutCategory(d.selectionKey as AdminFlyoutId) == category,
        )
        .toList(growable: false);
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
  return appNavCategories.where((category) {
    if (category == AppNavCategory.setup) {
      return navItemFor(NavId.management, items) != null;
    }
    if (category == AppNavCategory.administration) {
      return hasAdministrationFlyoutDestinations(items);
    }
    return categoryDestinations(category, items, excludedIds).isNotEmpty;
  }).toList(growable: false);
}

/// Whether [selectedId] matches [id].
bool isNavItemSelected(NavId selectedId, NavId id) => selectedId == id;

/// Whether [destination] is the active page.
///
/// [NavId] destinations match [selectedId]; [AdminFlyoutId] destinations match
/// the current [location] (org-scoped paths supported).
bool isDestinationSelected(
  DesktopFlyoutDestination destination,
  NavId selectedId,
  String location,
) {
  final key = destination.selectionKey;
  if (key is AdminFlyoutId) return adminFlyoutIdFromPath(location) == key;
  return key == selectedId;
}

/// Pinned destinations in the user's pin order.
///
/// Keys with no matching destination (permission/feature removed) are skipped
/// but should stay in storage so they reappear if access returns.
List<DesktopFlyoutDestination> resolvePinnedDestinations(
  List<String> pinnedKeys,
  Iterable<DesktopFlyoutDestination> available,
) {
  final byKey = {for (final d in available) navPinKey(d.selectionKey): d};
  return [
    for (final key in pinnedKeys)
      if (byKey[key] != null) byKey[key]!,
  ];
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
  if (category == AppNavCategory.setup ||
      category == AppNavCategory.administration) {
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
