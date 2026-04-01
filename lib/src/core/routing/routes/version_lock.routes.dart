import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/version_lock/presentation/pages/force_update_page.dart';
import '../../../features/version_lock/presentation/pages/web_update_page.dart';

part 'version_lock.routes.g.dart';

/// Force update page route - shown when app version is below minimum.
@TypedGoRoute<ForceUpdateRoute>(path: ForceUpdateRoute.path)
class ForceUpdateRoute extends GoRouteData with $ForceUpdateRoute {
  const ForceUpdateRoute();

  static const path = '/force-update';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ForceUpdatePage();
  }
}

/// Web update page route - shown on web when a newer version is deployed.
@TypedGoRoute<WebUpdateRoute>(path: WebUpdateRoute.path)
class WebUpdateRoute extends GoRouteData with $WebUpdateRoute {
  const WebUpdateRoute();

  static const path = '/web-update';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebUpdatePage();
  }
}
