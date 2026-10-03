import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:theme_provider/theme_provider.dart';

import 'core/i18n/strings.g.dart';
import 'core/packages/pocketbase/pocketbase_provider.dart';
import 'core/packages/theme/app_themes.dart';
import 'core/routing/router.dart';
import 'core/widgets/window_size_listener.dart';
import 'features/settings/domain/app_theme_mode.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';

/// Whether [FlutterNativeSplash.remove] has already been called this process.
var _nativeSplashRemoved = false;

/// Main application widget.
///
/// Sets up MaterialApp with GoRouter navigation and localization.
class Application extends HookConsumerWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeModeAsync = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);

    // Prefer bootstrapped/loaded mode; fall back to dark while async settles.
    final mode = themeModeAsync.value ??
        ref.read(bootstrappedThemeModeProvider) ??
        AppThemeMode.system;
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final defaultThemeId = effectiveAppThemeId(mode, platformBrightness);

    return ThemeProvider(
      themes: AppThemes.all,
      defaultThemeId: defaultThemeId,
      saveThemesOnChange: false,
      loadThemeOnInit: false,
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) {
            // Determine system brightness for system mode
            final systemBrightness =
                MediaQuery.platformBrightnessOf(themeContext);

            // Get effective theme based on mode
            final effectiveThemeId = themeModeAsync.whenOrNull(
                  data: (_) =>
                      themeController.getEffectiveThemeId(systemBrightness),
                ) ??
                effectiveAppThemeId(
                  ref.read(bootstrappedThemeModeProvider) ?? AppThemeMode.system,
                  systemBrightness,
                );

            // Apply theme via post-frame callback to avoid build-time mutations
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final controller = ThemeProvider.controllerOf(themeContext);
              if (controller.theme.id != effectiveThemeId) {
                controller.setTheme(effectiveThemeId);
              }
              if (!_nativeSplashRemoved) {
                _nativeSplashRemoved = true;
                FlutterNativeSplash.remove();
              }
            });

            return WindowSizeListener(
              child: MaterialApp.router(
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                title: appTitle,
                debugShowCheckedModeBanner: false,
                locale: TranslationProvider.of(context).flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates:
                    GlobalMaterialLocalizations.delegates,
                theme: ThemeProvider.themeOf(themeContext).data,
                routerConfig: router,
              ),
            );
          },
        ),
      ),
    );
  }
}
