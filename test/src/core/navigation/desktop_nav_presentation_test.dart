import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/i18n/strings.g.dart';
import 'package:hzn_laundry/src/core/navigation/desktop_nav_presentation.dart';
import 'package:hzn_laundry/src/core/widgets/nav_permissions.dart';

List<NavItem> _itemsWith(Set<NavId> ids) {
  return buildAllNavItems((key) => key)
      .where((item) => ids.contains(item.id))
      .toList();
}

void main() {
  final allItems = buildAllNavItems((key) => key);
  final t = AppLocale.en.buildSync();

  group('desktop_nav_presentation', () {
    test(
        'visibleShortcutIds preserves default order for permitted destinations',
        () {
      final shortcuts = visibleShortcutIds(allItems);

      expect(
        shortcuts,
        [
          NavId.salesHistory,
          NavId.products,
          NavId.services,
          NavId.customers,
        ],
      );
    });

    test('visibleShortcutIds omits destinations the user cannot see', () {
      final visible = _itemsWith({
        NavId.dashboard,
        NavId.products,
        NavId.customers,
        NavId.organizations,
      });

      expect(
        visibleShortcutIds(visible),
        [NavId.products, NavId.customers],
      );
    });

    test('extraShortcutCandidates follow nav order excluding dashboard/system',
        () {
      final extras = extraShortcutCandidates(
        allItems,
        visibleShortcutIds(allItems),
      );

      expect(
        extras,
        [
          NavId.employees,
          NavId.reports,
          NavId.activities,
          NavId.management,
          NavId.organizations,
          NavId.promos,
        ],
      );
    });

    test('categoryDestinations excludes shortcuts from category flyouts', () {
      const excluded = {
        NavId.salesHistory,
        NavId.products,
        NavId.services,
        NavId.customers,
      };

      expect(
        categoryDestinations(AppNavCategory.operations, allItems, excluded)
            .map((item) => item.id),
        [NavId.promos],
      );
      expect(
        categoryDestinations(AppNavCategory.people, allItems, excluded)
            .map((item) => item.id),
        [NavId.employees],
      );
      expect(
        categoryDestinations(AppNavCategory.insights, allItems, excluded)
            .map((item) => item.id),
        [NavId.reports, NavId.activities],
      );
      expect(
        categoryDestinations(AppNavCategory.administration, allItems, excluded)
            .map((item) => item.id),
        [NavId.management, NavId.organizations],
      );
    });

    test('administrationFlyoutDestinations lists sections then Organizations',
        () {
      final destinations = administrationFlyoutDestinations(allItems, t);

      expect(
        destinations.map((d) => d.selectionKey),
        [
          AdminFlyoutId.users,
          AdminFlyoutId.roles,
          AdminFlyoutId.branches,
          AdminFlyoutId.machines,
          AdminFlyoutId.storages,
          AdminFlyoutId.productCategories,
          AdminFlyoutId.quantityUnits,
          AdminFlyoutId.cashierGroups,
          AdminFlyoutId.organizations,
        ],
      );
    });

    test('administrationFlyoutDestinations omits sections without Management',
        () {
      final visible = _itemsWith({
        NavId.dashboard,
        NavId.organizations,
      });

      expect(
        administrationFlyoutDestinations(visible, t)
            .map((d) => d.selectionKey),
        [AdminFlyoutId.organizations],
      );
    });

    test('visibleCategories keeps Administration when Management is a shortcut',
        () {
      final excluded = {
        ...visibleShortcutIds(allItems),
        NavId.management,
        NavId.organizations,
      };

      expect(
        visibleCategories(allItems, excluded),
        contains(AppNavCategory.administration),
      );
    });

    test('visibleCategories omits empty groups when items are hidden', () {
      final staffItems = _itemsWith({
        NavId.dashboard,
        NavId.customers,
        NavId.organizations,
      });
      final excluded = visibleShortcutIds(staffItems).toSet();

      expect(
        visibleCategories(staffItems, excluded),
        [AppNavCategory.administration],
      );
    });

    test('isNavCategorySelected is true when a category child is active', () {
      const excluded = {
        NavId.salesHistory,
        NavId.products,
        NavId.services,
        NavId.customers,
      };

      expect(
        isNavCategorySelected(
          NavId.employees,
          AppNavCategory.people,
          allItems,
          excluded,
        ),
        isTrue,
      );
      expect(
        isNavCategorySelected(
          NavId.customers,
          AppNavCategory.people,
          allItems,
          excluded,
        ),
        isFalse,
      );
      expect(
        isNavCategorySelected(
          NavId.management,
          AppNavCategory.administration,
          allItems,
          {...excluded, NavId.management, NavId.organizations},
        ),
        isTrue,
      );
    });

    test('adminFlyoutIdFromPath resolves management and org locations', () {
      expect(
        adminFlyoutIdFromPath('/acme/main/management/roles'),
        AdminFlyoutId.roles,
      );
      expect(
        adminFlyoutIdFromPath('/acme/main/management/users/abc'),
        AdminFlyoutId.users,
      );
      expect(
        adminFlyoutIdFromPath('/acme/main/organizations/xyz'),
        AdminFlyoutId.organizations,
      );
      expect(adminFlyoutIdFromPath('/acme/main/dashboard'), isNull);
    });

    group('filterNavItemsByQuery', () {
      final items = buildAllNavItems((key) => switch (key) {
            'dashboard' => 'Dashboard',
            'customers' => 'Customers',
            'employees' => 'Employees',
            'reports' => 'Reports',
            _ => key,
          });

      test('empty or whitespace query returns empty list', () {
        expect(filterNavItemsByQuery(items, ''), isEmpty);
        expect(filterNavItemsByQuery(items, '   '), isEmpty);
      });

      test('matches case-insensitively by label contains', () {
        final results = filterNavItemsByQuery(items, 'EMP');

        expect(
          results.map((item) => item.id),
          [NavId.employees],
        );
      });

      test('returns empty list when nothing matches', () {
        expect(filterNavItemsByQuery(items, 'xyz'), isEmpty);
      });
    });
  });
}
