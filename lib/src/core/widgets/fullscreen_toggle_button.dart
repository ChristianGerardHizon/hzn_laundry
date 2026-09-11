import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../i18n/strings.g.dart';
import '../utils/window_utils.dart';

/// Toggles true fullscreen (hides the title bar and fills the screen),
/// similar to pressing F11 in a browser.
///
/// This is separate from the OS-native maximize button, which resizes the
/// window to fill the screen while keeping the title bar. Only renders on
/// desktop platforms (Windows, Linux, macOS).
class FullscreenToggleButton extends StatefulWidget {
  const FullscreenToggleButton({super.key});

  static bool get isSupportedPlatform => WindowUtils.isDesktopPlatform;

  @override
  State<FullscreenToggleButton> createState() => _FullscreenToggleButtonState();
}

class _FullscreenToggleButtonState extends State<FullscreenToggleButton>
    with WindowListener {
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    if (!FullscreenToggleButton.isSupportedPlatform) return;

    windowManager.addListener(this);
    WindowUtils.isFullScreen().then((value) {
      if (mounted) setState(() => _isFullScreen = value);
    });
  }

  @override
  void dispose() {
    if (FullscreenToggleButton.isSupportedPlatform) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() {
    if (mounted) setState(() => _isFullScreen = true);
  }

  @override
  void onWindowLeaveFullScreen() {
    if (mounted) setState(() => _isFullScreen = false);
  }

  Future<void> _toggle() async {
    final currentlyFull = await WindowUtils.isFullScreen();
    final next = !currentlyFull;
    if (mounted) setState(() => _isFullScreen = next);

    try {
      final actual = await WindowUtils.setFullScreen(next);
      if (mounted && actual != _isFullScreen) {
        setState(() => _isFullScreen = actual);
      }
    } catch (_) {
      if (mounted) setState(() => _isFullScreen = currentlyFull);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!FullscreenToggleButton.isSupportedPlatform) {
      return const SizedBox.shrink();
    }

    final t = Translations.of(context);

    return IconButton(
      icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
      tooltip: _isFullScreen ? t.common.exitFullScreen : t.common.fullScreen,
      onPressed: _toggle,
    );
  }
}
