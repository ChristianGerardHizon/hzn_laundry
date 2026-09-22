import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/router_utils.dart';
import '../../../../core/routing/routes/org_selection.routes.dart';
import '../../../../core/routing/routes/subscriptions.routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../domain/organization_subscription.dart';
import '../../domain/subscription_due.dart';
import '../controllers/billing_settings_controller.dart';
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
    final settings =
        ref.watch(billingSettingsControllerProvider).asData?.value;
    final enforceWarnings = settings?.enforceWarnings ?? true;
    if (!enforceWarnings) return const SizedBox.shrink();

    final warningDays =
        settings?.warningDaysBeforeDue ?? kSubscriptionExpiringSoonDays;

    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final org = orgAsync.asData?.value;
    if (org == null) return const SizedBox.shrink();

    final subAsync = ref.watch(organizationSubscriptionProvider(org.id));
    final sub = subAsync.asData?.value;
    if (sub == null) return const SizedBox.shrink();

    final enforceLockout = settings?.enforceLockout ?? true;
    if (enforceLockout && sub.isEffectivelyLocked) {
      return const SizedBox.shrink();
    }

    final dueSoon = isSubscriptionDueSoon(
      sub.status,
      sub.periodEnd,
      warningDaysBeforeDue: warningDays,
    );
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
/// above [child] when applicable, and prompts once with an alert dialog.
class SubscriptionLockGate extends HookConsumerWidget {
  const SubscriptionLockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final org = orgAsync.asData?.value;
    final promptedForOrgId = useRef<String?>(null);
    // Must read inherited widgets in build — useEffect runs during initHook.
    final path = GoRouterState.of(context).uri.path;

    final settings =
        ref.watch(billingSettingsControllerProvider).asData?.value;
    final enforceWarnings = settings?.enforceWarnings ?? true;
    final enforceLockout = settings?.enforceLockout ?? true;
    final warningDays =
        settings?.warningDaysBeforeDue ?? kSubscriptionExpiringSoonDays;

    final subAsync = org != null
        ? ref.watch(organizationSubscriptionProvider(org.id))
        : null;
    final sub = subAsync?.asData?.value;

    useEffect(() {
      if (!enforceWarnings) return null;
      if (org == null || sub == null) return null;
      if (enforceLockout && sub.isEffectivelyLocked) return null;
      final needsPrompt = sub.isInGrace ||
          isSubscriptionDueSoon(
            sub.status,
            sub.periodEnd,
            warningDaysBeforeDue: warningDays,
          );
      if (!needsPrompt) return null;
      if (promptedForOrgId.value == org.id) return null;
      if (RouterUtils.isSubscriptionPayPath(path)) return null;

      promptedForOrgId.value = org.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _showSubscriptionDueDialog(
          context: context,
          organizationId: org.id,
          subscription: sub,
          warningDaysBeforeDue: warningDays,
        );
      });
      return null;
    }, [
      org?.id,
      sub?.id,
      sub?.status,
      sub?.periodEnd,
      path,
      enforceWarnings,
      enforceLockout,
      warningDays,
    ]);

    if (org == null || subAsync == null) return child;

    return subAsync.when(
      loading: () => child,
      error: (_, __) => child,
      data: (subscription) {
        if (subscription == null) return child;

        if (enforceLockout && subscription.isEffectivelyLocked) {
          return _LockedScreen(
            organizationId: org.id,
            title: t.subscriptions.lockedTitle,
            message: t.subscriptions.lockedMessage,
            cta: t.subscriptions.goToPayment,
          );
        }

        if (!enforceWarnings) return child;

        final dueSoon = isSubscriptionDueSoon(
          subscription.status,
          subscription.periodEnd,
          warningDaysBeforeDue: warningDays,
        );
        final showBanner = subscription.isInGrace || dueSoon;

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

Future<void> _showSubscriptionDueDialog({
  required BuildContext context,
  required String organizationId,
  required OrganizationSubscription subscription,
  required int warningDaysBeforeDue,
}) {
  final t = Translations.of(context);
  final isGrace = subscription.isInGrace;
  final title = isGrace
      ? t.subscriptions.graceDialogTitle
      : t.subscriptions.dueSoonDialogTitle;
  final message = isGrace
      ? t.subscriptions.graceDialogMessage
      : t.subscriptions.dueSoonDialogMessage(
          n: subscriptionDaysRemaining(
            subscription.periodEnd,
            warningDaysBeforeDue: warningDaysBeforeDue,
          ),
        );

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        isGrace ? Icons.warning_amber_rounded : Icons.event_busy_outlined,
        color: isGrace ? Colors.orangeAccent : _kBrandTeal,
        size: 36,
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t.subscriptions.remindLater),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            SubscriptionPayRoute(organizationId: organizationId).go(context);
          },
          child: Text(t.subscriptions.goToPayment),
        ),
      ],
    ),
  );
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
