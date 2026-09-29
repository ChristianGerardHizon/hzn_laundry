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
    test('categoryDestinations excludes given ids from category flyouts', () {
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
        administrationFlyoutDestinations(visible, t).map((d) => d.selectionKey),
        [AdminFlyoutId.organizations],
      );
    });

    test(
        'flyoutDestinationsFor splits Management into Setup and Administration',
        () {
      List<Object> keys(AppNavCategory c) =>
          flyoutDestinationsFor(c, allItems, const {}, t)
              .map((d) => d.selectionKey)
              .toList();

      expect(keys(AppNavCategory.setup), [
        AdminFlyoutId.branches,
        AdminFlyoutId.machines,
        AdminFlyoutId.storages,
        AdminFlyoutId.productCategories,
        AdminFlyoutId.quantityUnits,
        AdminFlyoutId.cashierGroups,
      ]);
      expect(keys(AppNavCategory.administration), [
        AdminFlyoutId.users,
        AdminFlyoutId.roles,
        AdminFlyoutId.organizations,
      ]);
    });

    test('visibleCategories lists every group in display order', () {
      expect(
        visibleCategories(allItems, const {}),
        [
          AppNavCategory.operations,
          AppNavCategory.people,
          AppNavCategory.insights,
          AppNavCategory.setup,
          AppNavCategory.administration,
        ],
      );
    });

    test('visibleCategories omits empty groups when items are hidden', () {
      final staffItems = _itemsWith({
        NavId.dashboard,
        NavId.customers,
        NavId.organizations,
      });

      expect(
        visibleCategories(staffItems, const {}),
        [AppNavCategory.people, AppNavCategory.administration],
      );
    });

    test('visibleCategories hides Setup without Management', () {
      final visible = _itemsWith({NavId.dashboard, NavId.organizations});

      expect(
        visibleCategories(visible, const {}),
        [AppNavCategory.administration],
      );
    });

    test('isDestinationSelected matches nav ids and admin paths', () {
      const customers = DesktopFlyoutDestination(
        selectionKey: NavId.customers,
        icon: Icons.people,
        selectedIcon: Icons.people,
        label: 'Customers',
      );
      const roles = DesktopFlyoutDestination(
        selectionKey: AdminFlyoutId.roles,
        icon: Icons.people,
        selectedIcon: Icons.people,
        label: 'Roles',
      );

      expect(isDestinationSelected(customers, NavId.customers, '/x'), isTrue);
      expect(isDestinationSelected(customers, NavId.products, '/x'), isFalse);
      expect(
        isDestinationSelected(roles, NavId.management, '/a/b/management/roles'),
        isTrue,
      );
      expect(
        isDestinationSelected(roles, NavId.customers, '/a/b/customers'),
        isFalse,
      );
    });

    group('pins', () {
      final all = [
        for (final c in appNavCategories)
          ...flyoutDestinationsFor(c, allItems, const {}, t),
      ];

      test('navPinKey is stable and distinguishes nav and admin ids', () {
        expect(navPinKey(NavId.customers), 'nav.customers');
        expect(navPinKey(AdminFlyoutId.roles), 'admin.roles');
      });

      test('defaults pin the four daily destinations', () {
        expect(defaultPinnedKeys, [
          'nav.salesHistory',
          'nav.products',
          'nav.services',
          'nav.customers',
        ]);
      });

      test('resolvePinnedDestinations keeps pin order and skips unknown keys',
          () {
        final resolved = resolvePinnedDestinations(
          ['nav.customers', 'nav.gone', 'admin.roles', 'nav.products'],
          all,
        );

        expect(
          resolved.map((d) => d.selectionKey),
          [NavId.customers, AdminFlyoutId.roles, NavId.products],
        );
      });

      test('resolvePinnedDestinations drops pins the user cannot see', () {
        final staff = _itemsWith({NavId.dashboard, NavId.customers});
        final available = [
          for (final c in appNavCategories)
            ...flyoutDestinationsFor(c, staff, const {}, t),
        ];

        expect(
          resolvePinnedDestinations(defaultPinnedKeys, available)
              .map((d) => d.selectionKey),
          [NavId.customers],
        );
      });
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
