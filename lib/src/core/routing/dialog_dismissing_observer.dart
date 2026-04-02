import 'package:flutter/material.dart';

import 'router.dart';

/// A [NavigatorObserver] that dismisses all open dialogs, bottom sheets, and
/// modals whenever a new page route is pushed.
///
/// Register on the root navigator via [GoRouter.observers] so that navigating
/// to a new page automatically cleans up any overlay routes (dialogs, sheets).
class DialogDismissingObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) {
      _dismissOverlays();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is PageRoute) {
      _dismissOverlays();
    }
  }

  void _dismissOverlays() {
    final nav = navigator;
    if (nav == null || !nav.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!nav.mounted) return;
      nav.popUntil((route) => route is PageRoute || route.isFirst);
    });
  }

  /// Pops all dialogs/bottom sheets/modals from the root navigator.
  ///
  /// Call this before [GoRouter.go()] navigations that originate from inside
  /// a dialog, since `.go()` replaces within the shell and doesn't trigger
  /// the observer's [didPush].
  static void dismissAllDialogs() {
    final nav = rootNavigatorKey.currentState;
    if (nav == null || !nav.mounted) return;
    nav.popUntil((route) => route is PageRoute || route.isFirst);
  }
}
