import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/activities/presentation/pages/activities_page.dart';
import '../../../features/activities/presentation/pages/activity_log_detail_page.dart';

part 'activities.routes.g.dart';

/// Activities page route with nested activity log detail.
@TypedGoRoute<ActivitiesRoute>(
  path: ActivitiesRoute.path,
  routes: [
    TypedGoRoute<ActivityLogDetailRoute>(path: ':id'),
  ],
)
class ActivitiesRoute extends GoRouteData with $ActivitiesRoute {
  const ActivitiesRoute();

  static const path = '/activities';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ActivitiesPage();
  }
}

/// Activity log detail page route.
class ActivityLogDetailRoute extends GoRouteData with $ActivityLogDetailRoute {
  const ActivityLogDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ActivityLogDetailPage(activityLogId: id);
  }
}
