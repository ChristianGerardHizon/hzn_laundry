import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../../core/packages/theme/app_themes.dart';
import '../../domain/app_theme_mode.dart';

part 'theme_controller.g.dart';

/// Storage key for persisting theme preference.
const themePreferenceKey = 'THEME_PREFERENCE';

/// Secure storage options matching [secureStorageProvider].
FlutterSecureStorage createThemeSecureStorage() {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
}

/// Reads the persisted theme preference outside Riverpod (e.g. before runApp).
///
/// Returns [AppThemeMode.system] when unset or unrecognized.
Future<AppThemeMode> readPersistedThemeMode([
  FlutterSecureStorage? storage,
]) async {
  final store = storage ?? createThemeSecureStorage();
  final value = await store.read(key: themePreferenceKey);
  if (value == null) return AppThemeMode.system;

  return AppThemeMode.values.cast<AppThemeMode?>().firstWhere(
        (m) => m?.name == value,
        orElse: () => null,
      ) ??
      AppThemeMode.system;
}

/// Resolves light/dark theme ID from preference and platform brightness.
String effectiveAppThemeId(AppThemeMode mode, Brightness systemBrightness) {
  switch (mode) {
    case AppThemeMode.light:
      return AppThemes.lightId;
    case AppThemeMode.dark:
      return AppThemes.darkId;
    case AppThemeMode.system:
      return systemBrightness == Brightness.dark
          ? AppThemes.darkId
          : AppThemes.lightId;
  }
}

/// Theme mode loaded in [main] before [runApp], if any.
///
/// Overridden with [ProviderScope] so [ThemeController] can skip a second
/// secure-storage read on cold start.
@Riverpod(keepAlive: true)
AppThemeMode? bootstrappedThemeMode(Ref ref) => null;

/// Controller for managing app theme mode.
///
/// Handles light/dark/system theme switching with persistence.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  /// Whether cold-start bootstrap was already consumed.
  ///
  /// After the first build, later rebuilds/invalidations read secure storage so
  /// a post-[setThemeMode] refresh cannot snap back to the bootstrapped value.
  var _usedBootstrap = false;

  @override
  Future<AppThemeMode> build() async {
    if (!_usedBootstrap) {
      final bootstrapped = ref.read(bootstrappedThemeModeProvider);
      if (bootstrapped != null) {
        _usedBootstrap = true;
        return bootstrapped;
      }
    }
    return await _loadPersistedTheme() ?? AppThemeMode.system;
  }

  /// Gets the current effective theme ID based on mode and system brightness.
  String getEffectiveThemeId(Brightness systemBrightness) {
    final mode = state.value ?? AppThemeMode.system;
    return effectiveAppThemeId(mode, systemBrightness);
  }

  /// Sets the theme mode and persists the preference.
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = const AsyncLoading();
    await _persistTheme(mode);
    state = AsyncData(mode);
  }

  Future<AppThemeMode?> _loadPersistedTheme() async {
    final storage = ref.read(secureStorageProvider);
    final value = await storage.read(key: themePreferenceKey);
    if (value == null) return null;

    return AppThemeMode.values.cast<AppThemeMode?>().firstWhere(
          (m) => m?.name == value,
          orElse: () => null,
        );
  }

  Future<void> _persistTheme(AppThemeMode mode) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: themePreferenceKey, value: mode.name);
  }
}

/// Convenience provider for current theme mode.
@Riverpod(keepAlive: true)
AppThemeMode currentThemeMode(Ref ref) {
  return ref.watch(themeControllerProvider).value ?? AppThemeMode.system;
}
