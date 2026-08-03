import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../i18n/strings.g.dart';

/// Toggles true fullscreen (hides the title bar and fills the screen),
/// similar to pressing F11 in a browser.
///
/// This is separate from the OS-native maximize button, which resizes the
/// window to fill the screen while keeping the title bar. Only renders on
/// desktop platforms (Windows, Linux, macOS).
class FullscreenToggleButton extends StatefulWidget {
  const FullscreenToggleButton({super.key});

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      [
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      ].contains(defaultTargetPlatform);

  @override
  State<FullscreenToggleButton> createState() =>
      _FullscreenToggleButtonState();
}

class _FullscreenToggleButtonState extends State<FullscreenToggleButton>
    with WindowListener {
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    if (!FullscreenToggleButton.isSupportedPlatform) return;

    windowManager.addListener(this);
    windowManager.isFullScreen().then((value) {
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
    await windowManager.setFullScreen(!_isFullScreen);
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
