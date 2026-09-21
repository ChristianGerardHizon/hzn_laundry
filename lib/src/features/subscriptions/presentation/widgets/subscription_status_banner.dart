import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/org_selection.routes.dart';
import '../../../../core/routing/routes/subscriptions.routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../domain/subscription_status.dart';
import '../controllers/organization_subscription_provider.dart';

const _kBrandTeal = Color(0xFF45A9AB);
const _kInk = Color(0xFF0B0B0B);

/// Shows a grace / due-soon Material banner for the current organization.
///
/// Prefer wrapping app content with [SubscriptionLockGate], which also
/// replaces the child with a full-screen lock when the subscription is
/// effectively locked.
class SubscriptionStatusBanner extends HookConsumerWidget {
  const SubscriptionStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final org = orgAsync.asData?.value;
    if (org == null) return const SizedBox.shrink();

    final subAsync = ref.watch(organizationSubscriptionProvider(org.id));
    final sub = subAsync.asData?.value;
    if (sub == null) return const SizedBox.shrink();
    if (sub.isEffectivelyLocked) return const SizedBox.shrink();

    final dueSoon = _isDueSoon(sub.status, sub.periodEnd);
    if (!sub.isInGrace && !dueSoon) return const SizedBox.shrink();

    final message = sub.isInGrace
        ? t.subscriptions.graceBanner
        : t.subscriptions.dueSoonBanner;

    return MaterialBanner(
      backgroundColor: sub.isInGrace
          ? Colors.orange.shade900.withValues(alpha: 0.92)
          : _kBrandTeal.withValues(alpha: 0.25),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              SubscriptionPayRoute(organizationId: org.id).go(context),
          child: Text(
            t.subscriptions.goToPayment,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Wraps [child]; if the current org subscription is effectively locked,
/// shows a full-screen lock UI instead. Otherwise shows grace/due banner
/// above [child] when applicable.
class SubscriptionLockGate extends HookConsumerWidget {
  const SubscriptionLockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final org = orgAsync.asData?.value;

    if (org == null) return child;

    final subAsync = ref.watch(organizationSubscriptionProvider(org.id));

    return subAsync.when(
      loading: () => child,
      error: (_, __) => child,
      data: (sub) {
        if (sub == null) return child;

        if (sub.isEffectivelyLocked) {
          return _LockedScreen(
            organizationId: org.id,
            title: t.subscriptions.lockedTitle,
            message: t.subscriptions.lockedMessage,
            cta: t.subscriptions.goToPayment,
          );
        }

        final dueSoon = _isDueSoon(sub.status, sub.periodEnd);
        final showBanner = sub.isInGrace || dueSoon;

        if (!showBanner) return child;

        return Column(
          children: [
            const SubscriptionStatusBanner(),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _LockedScreen extends ConsumerWidget {
  const _LockedScreen({
    required this.organizationId,
    required this.title,
    required this.message,
    required this.cta,
  });

  final String organizationId;
  final String title;
  final String message;
  final String cta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);

    return Material(
      color: _kInk,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => SubscriptionPayRoute(
                  organizationId: organizationId,
                ).go(context),
                style: FilledButton.styleFrom(
                  backgroundColor: _kBrandTeal,
                  foregroundColor: _kInk,
                  minimumSize: const Size(220, 48),
                ),
                child: Text(cta),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => const SelectOrganizationRoute().go(context),
                child: Text(
                  t.organizations.selectTitle,
                  style: const TextStyle(color: _kBrandTeal),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                child: Text(
                  t.auth.logoutButton,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isDueSoon(SubscriptionStatus status, DateTime periodEnd) {
  if (status != SubscriptionStatus.active) return false;
  final now = DateTime.now();
  final windowEnd = now.add(const Duration(days: 3));
  return !periodEnd.isAfter(windowEnd);
}
