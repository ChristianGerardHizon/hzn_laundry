import 'package:sentry_flutter/sentry_flutter.dart';

/// Adds a breadcrumb to Sentry for tracking user actions.
///
/// Use [category] to group breadcrumbs (e.g. 'auth', 'checkout', 'cart').
/// Use [data] to attach extra key-value pairs.
void addBreadcrumb(
  String message, {
  String category = 'app',
  SentryLevel level = SentryLevel.info,
  Map<String, dynamic>? data,
}) {
  Sentry.addBreadcrumb(Breadcrumb(
    message: message,
    category: category,
    level: level,
    data: data,
  ));
}
