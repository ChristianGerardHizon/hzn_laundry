import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Riverpod observer that adds Sentry breadcrumbs for provider errors.
base class SentryProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: 'Provider error: ${context.provider.name ?? context.provider.runtimeType.toString()}',
      category: 'provider',
      level: SentryLevel.error,
      data: {'error': error.toString()},
    ));
  }
}
