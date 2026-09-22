import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:url_launcher/url_launcher.dart';

/// Opens the OAuth vendor URL for PocketBase all-in-one auth.
///
/// Web uses a blank tab/popup. Android uses a partial Chrome Custom Tab so the
/// Flutter activity stays foreground and the realtime `@oauth2` subscription
/// survives until auth completes.
Future<bool> launchOAuthVendorUrl(Uri url) async {
  if (kIsWeb) {
    return launchUrl(url, webOnlyWindowName: '_blank');
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;

    await custom_tabs.launchUrl(
      url,
      customTabsOptions: custom_tabs.CustomTabsOptions.partial(
        configuration: custom_tabs.PartialCustomTabsConfiguration.adaptiveSheet(
          initialHeight: size.height,
          initialWidth: size.width,
          activitySideSheetMaximizationEnabled: true,
          activitySideSheetDecorationType:
              custom_tabs.CustomTabsActivitySideSheetDecorationType.shadow,
          activitySideSheetRoundedCornersPosition: custom_tabs
              .CustomTabsActivitySideSheetRoundedCornersPosition.top,
          cornerRadius: 16,
        ),
      ),
    );
    return true;
  }

  return launchUrl(url, mode: LaunchMode.inAppBrowserView);
}

/// Closes an Android Custom Tab opened by [launchOAuthVendorUrl], if any.
Future<void> closeOAuthBrowser() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android) return;
  await custom_tabs.closeCustomTabs();
}
