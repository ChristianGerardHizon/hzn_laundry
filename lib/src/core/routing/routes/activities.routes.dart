import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/activities/presentation/pages/activities_page.dart';

part 'activities.routes.g.dart';

/// Activities page route.
@TypedGoRoute<ActivitiesRoute>(path: ActivitiesRoute.path)
class ActivitiesRoute extends GoRouteData with $ActivitiesRoute {
  const ActivitiesRoute();

  static const path = '/activities';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ActivitiesPage();
  }
}
