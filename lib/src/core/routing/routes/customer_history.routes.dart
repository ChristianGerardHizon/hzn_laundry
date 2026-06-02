import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/customer_history/presentation/pages/customer_history_page.dart';

part 'customer_history.routes.g.dart';

/// Public customer order history page route — no auth required.
@TypedGoRoute<CustomerHistoryRoute>(
  path: CustomerHistoryRoute.path,
)
class CustomerHistoryRoute extends GoRouteData with $CustomerHistoryRoute {
  const CustomerHistoryRoute({required this.token});

  static const path = '/history/:token';

  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CustomerHistoryPage(token: token);
  }
}
