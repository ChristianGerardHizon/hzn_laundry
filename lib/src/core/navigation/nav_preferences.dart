import 'desktop_nav_presentation.dart';

/// Per-user sidebar customisation: pinned destinations and collapsed groups.
///
/// Immutable; every mutation returns a new instance so it can be a notifier state.
class NavPreferences {
  const NavPreferences({
    required this.pinnedKeys,
    required this.collapsedGroups,
  });

  /// Pinned destination keys (see [navPinKey]) in display order.
  final List<String> pinnedKeys;

  /// [AppNavCategory.name]s of groups the user collapsed.
  final Set<String> collapsedGroups;

  /// What a user sees before ever customising the sidebar.
  static final NavPreferences defaults = NavPreferences(
    pinnedKeys: defaultPinnedKeys,
    collapsedGroups: defaultCollapsedGroups,
  );

  bool isPinned(String key) => pinnedKeys.contains(key);

  bool isCollapsed(AppNavCategory category) =>
      collapsedGroups.contains(category.name);

  /// Pins [key] at the end of the pinned list, or removes it when pinned.
  NavPreferences togglePin(String key) {
    final next = isPinned(key)
        ? pinnedKeys.where((k) => k != key).toList()
        : [...pinnedKeys, key];
    return NavPreferences(pinnedKeys: next, collapsedGroups: collapsedGroups);
  }

  NavPreferences toggleCollapsed(AppNavCategory category) {
    final next = {...collapsedGroups};
    if (!next.add(category.name)) next.remove(category.name);
    return NavPreferences(pinnedKeys: pinnedKeys, collapsedGroups: next);
  }
}
