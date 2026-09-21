import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/subscriptions/presentation/pages/subscription_pay_page.dart';

part 'subscriptions.routes.g.dart';

/// Authenticated organization subscription payment screen (email deep link).
@TypedGoRoute<SubscriptionPayRoute>(path: SubscriptionPayRoute.path)
class SubscriptionPayRoute extends GoRouteData with $SubscriptionPayRoute {
  const SubscriptionPayRoute({required this.organizationId});

  static const path = '/subscription/pay/:organizationId';

  final String organizationId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SubscriptionPayPage(organizationId: organizationId);
  }
}
