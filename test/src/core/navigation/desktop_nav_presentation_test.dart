import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/navigation/desktop_nav_presentation.dart';
import 'package:hzn_laundry/src/core/widgets/nav_permissions.dart';

List<NavItem> _itemsWith(Set<NavId> ids) {
  return buildAllNavItems((key) => key)
      .where((item) => ids.contains(item.id))
      .toList();
}

void main() {
  final allItems = buildAllNavItems((key) => key);

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
    });
  });
}
