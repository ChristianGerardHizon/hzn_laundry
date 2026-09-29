import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/navigation/desktop_nav_presentation.dart';
import 'package:hzn_laundry/src/core/navigation/nav_preferences.dart';
import 'package:hzn_laundry/src/core/navigation/nav_preferences_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NavPreferences', () {
    test('defaults pin daily destinations and collapse admin groups', () {
      final prefs = NavPreferences.defaults;

      expect(prefs.isPinned('nav.customers'), isTrue);
      expect(prefs.isPinned('nav.reports'), isFalse);
      expect(prefs.isCollapsed(AppNavCategory.setup), isTrue);
      expect(prefs.isCollapsed(AppNavCategory.administration), isTrue);
      expect(prefs.isCollapsed(AppNavCategory.operations), isFalse);
    });

    test('togglePin appends then removes without mutating the original', () {
      const base = NavPreferences(pinnedKeys: ['a'], collapsedGroups: {});

      final pinned = base.togglePin('b');
      expect(pinned.pinnedKeys, ['a', 'b']);
      expect(base.pinnedKeys, ['a']);

      expect(pinned.togglePin('a').pinnedKeys, ['b']);
    });

    test('toggleCollapsed flips a group', () {
      const base = NavPreferences(pinnedKeys: [], collapsedGroups: {});

      final collapsed = base.toggleCollapsed(AppNavCategory.people);
      expect(collapsed.isCollapsed(AppNavCategory.people), isTrue);
      expect(
        collapsed.toggleCollapsed(AppNavCategory.people).isCollapsed(
              AppNavCategory.people,
            ),
        isFalse,
      );
    });
  });

  group('NavPreferencesController', () {
    ProviderContainer makeContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container;
    }

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('starts from defaults when nothing is stored', () async {
      final container = makeContainer();

      final prefs =
          await container.read(navPreferencesControllerProvider.future);

      expect(prefs.pinnedKeys, defaultPinnedKeys);
      expect(prefs.collapsedGroups, defaultCollapsedGroups);
    });

    test('persists pins locally and restores them', () async {
      final first = makeContainer();
      await first.read(navPreferencesControllerProvider.future);
      final controller = first.read(navPreferencesControllerProvider.notifier);

      await controller.togglePin('nav.reports');
      await controller.togglePin('nav.customers');

      // New container = app restart; SharedPreferences mock keeps the data.
      final second = makeContainer();
      final restored =
          await second.read(navPreferencesControllerProvider.future);

      expect(restored.pinnedKeys, [
        'nav.salesHistory',
        'nav.products',
        'nav.services',
        'nav.reports',
      ]);
    });

    test('an empty pin list is remembered, not reset to defaults', () async {
      SharedPreferences.setMockInitialValues({
        'nav.pinned.anonymous': <String>[],
      });
      final container = makeContainer();

      final prefs =
          await container.read(navPreferencesControllerProvider.future);

      expect(prefs.pinnedKeys, isEmpty);
    });

    test('persists collapsed groups', () async {
      final first = makeContainer();
      await first.read(navPreferencesControllerProvider.future);
      await first
          .read(navPreferencesControllerProvider.notifier)
          .toggleGroup(AppNavCategory.setup);

      final second = makeContainer();
      final restored =
          await second.read(navPreferencesControllerProvider.future);

      expect(restored.isCollapsed(AppNavCategory.setup), isFalse);
      expect(restored.isCollapsed(AppNavCategory.administration), isTrue);
    });
  });
}
