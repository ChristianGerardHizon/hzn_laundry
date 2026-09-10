import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'window_storage_service.dart';

class WindowUtils {
  /// Default sizes.
  static const _mobileSize = Size(380, 700);
  static const _defaultDesktopSize = Size(1000, 800);

  /// Minimum window size.
  static const _minimumSize = Size(380, 700);

  static bool get isDesktopPlatform =>
      !kIsWeb &&
      [
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      ].contains(defaultTargetPlatform);

  /// Register the WindowManager for desktop platforms.
  ///
  /// Sets window title and size, restoring last used size if available.
  static Future<void> register() async {
    // Skip on web and non-desktop platforms
    if (!isDesktopPlatform) return;

    await windowManager.ensureInitialized();

    // Try to load saved window size
    final savedSize = await WindowStorageService.loadWindowSize();

    // Use saved size if available, otherwise fall back to defaults
    final initialSize =
        savedSize ?? (kDebugMode ? _mobileSize : _defaultDesktopSize);

    final windowOptions = WindowOptions(
      minimumSize: _minimumSize,
      size: initialSize,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// Whether the window is currently in true fullscreen (no title bar).
  static Future<bool> isFullScreen() async {
    if (!isDesktopPlatform) return false;
    return windowManager.isFullScreen();
  }

  /// Enters or leaves true fullscreen.
  ///
  /// On Windows, window_manager can leave the window frameless after exit
  /// (title bar missing). Restore [TitleBarStyle.normal] so min/max/close
  /// return. Returns the actual fullscreen state after the call.
  static Future<bool> setFullScreen(bool isFullScreen) async {
    if (!isDesktopPlatform) return false;

    await windowManager.setFullScreen(isFullScreen);

    if (!isFullScreen && defaultTargetPlatform == TargetPlatform.windows) {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.normal,
        windowButtonVisibility: true,
      );
    }

    return windowManager.isFullScreen();
  }

  /// Toggles true fullscreen using the plugin's current state as source of
  /// truth (Windows fullscreen events often do not fire).
  static Future<bool> toggleFullScreen() async {
    final currentlyFull = await isFullScreen();
    return setFullScreen(!currentlyFull);
  }
}
