import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'desktop_nav_presentation.dart';
import 'nav_preferences.dart';

part 'nav_preferences_controller.g.dart';

/// Loads and saves the current user's sidebar preferences on this device.
///
/// Stored locally (not on the server) and namespaced by user id so people who
/// share a machine keep separate pins.
@Riverpod(keepAlive: true)
class NavPreferencesController extends _$NavPreferencesController {
  static String _pinsKey(String userId) => 'nav.pinned.$userId';
  static String _collapsedKey(String userId) => 'nav.collapsed.$userId';

  String get _userId => ref.read(currentAuthProvider)?.user.id ?? 'anonymous';

  @override
  Future<NavPreferences> build() async {
    final userId = ref.watch(currentAuthProvider)?.user.id ?? 'anonymous';
    final prefs = await SharedPreferences.getInstance();
    final pins = prefs.getStringList(_pinsKey(userId));
    final collapsed = prefs.getStringList(_collapsedKey(userId));
    // null = never customised -> defaults; an empty list is a real choice.
    return NavPreferences(
      pinnedKeys: pins ?? defaultPinnedKeys,
      collapsedGroups: collapsed?.toSet() ?? defaultCollapsedGroups,
    );
  }

  Future<void> togglePin(String key) async {
    final current = state.value ?? NavPreferences.defaults;
    final next = current.togglePin(key);
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinsKey(_userId), next.pinnedKeys);
  }

  Future<void> toggleGroup(AppNavCategory category) async {
    final current = state.value ?? NavPreferences.defaults;
    final next = current.toggleCollapsed(category);
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _collapsedKey(_userId),
      next.collapsedGroups.toList(),
    );
  }
}
