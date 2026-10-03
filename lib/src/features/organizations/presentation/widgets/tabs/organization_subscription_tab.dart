import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/routing/routes/subscriptions.routes.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/state/error_state.dart';
import '../../../../subscriptions/domain/billing_interval_unit.dart';
import '../../../../subscriptions/domain/organization_subscription.dart';
import '../../../../subscriptions/domain/subscription_payment.dart';
import '../../../../subscriptions/domain/subscription_payment_status.dart';
import '../../../../subscriptions/domain/subscription_status.dart';
import '../../../../subscriptions/presentation/controllers/organization_payments_controller.dart';
import '../../../../subscriptions/presentation/controllers/organization_subscription_provider.dart';
import '../super_admin/subscription_status_badge.dart';

/// Organization page tab: current package, Pay button, and payment history.
///
/// Only shown to organization billing admins (see `canManageOrgBilling`).
class OrganizationSubscriptionTab extends ConsumerWidget {
  const OrganizationSubscriptionTab({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isWide = Breakpoints.isMultiColumnOrLarger(context);
    final subAsync =
        ref.watch(organizationSubscriptionProvider(organizationId));
    final paymentsAsync =
        ref.watch(organizationPaymentsControllerProvider(organizationId));

    Future<void> refresh() async {
      ref.invalidate(organizationSubscriptionProvider(organizationId));
      await ref
          .read(organizationPaymentsControllerProvider(organizationId).notifier)
          .refresh();
    }

    final payments =
        paymentsAsync.asData?.value ?? const <SubscriptionPayment>[];
    final hasPending =
        payments.any((p) => p.status == SubscriptionPaymentStatus.pending);

    return RefreshIndicator(
      onRefresh: refresh,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 720 : double.infinity),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 24 : 16,
              vertical: 16,
            ),
            children: [
              subAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => ErrorState.fromError(
                  e,
                  onRetry: () => ref.invalidate(
                    organizationSubscriptionProvider(organizationId),
                  ),
                ),
                data: (sub) => sub == null
                    ? _NoSubscriptionCard(
                        message: t.subscriptions.noActiveSubscription)
                    : _PackageCard(
                        subscription: sub,
                        hasPendingPayment: hasPending,
                        onPay: () async {
                          await SubscriptionPayRoute(
                            organizationId: organizationId,
                          ).push<void>(context);
                          // Pick up a newly submitted proof / status change.
                          await refresh();
                        },
                      ),
              ),
              const SizedBox(height: 16),
              _PaymentHistoryCard(
                  paymentsAsync: paymentsAsync, onRetry: refresh),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoSubscriptionCard extends StatelessWidget {
  const _NoSubscriptionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.subscription,
    required this.hasPendingPayment,
    required this.onPay,
  });

  final OrganizationSubscription subscription;
  final bool hasPendingPayment;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final dateFormat = DateFormat.yMMMd();
    final sub = subscription;
    final graceEnds = sub.graceEndsAt;

    final notice = switch (sub.status) {
      SubscriptionStatus.grace => t.subscriptions.graceBanner,
      SubscriptionStatus.locked => t.subscriptions.lockedMessage,
      _ => null,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.subscriptions.currentPackage,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    sub.packageName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SubscriptionStatusBadge(
                  style: OrgStatusStyle.from(context, t, sub.status.name),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${currency.format(sub.price)} · ${_cycleLabel(t, sub)}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: t.subscriptions.periodStart,
              value: dateFormat.format(sub.periodStart.toLocal()),
            ),
            _DetailRow(
              label: t.subscriptions.nextPaymentDue,
              value: dateFormat.format(sub.periodEnd.toLocal()),
            ),
            if (sub.isInGrace && graceEnds != null)
              _DetailRow(
                label: t.subscriptions.graceEnds,
                value: dateFormat.format(graceEnds.toLocal()),
              ),
            if (notice != null) ...[
              const SizedBox(height: 12),
              Text(
                notice,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: sub.status == SubscriptionStatus.locked
                      ? theme.colorScheme.error
                      : Colors.orange.shade800,
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: hasPendingPayment ? null : onPay,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              icon: Icon(
                hasPendingPayment
                    ? Icons.hourglass_top_rounded
                    : Icons.payments_outlined,
              ),
              label: Text(
                hasPendingPayment
                    ? t.subscriptions.paymentUnderReview
                    : t.subscriptions.payAmount(
                        amount: currency.format(sub.price),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _cycleLabel(Translations t, OrganizationSubscription sub) {
    final count = sub.intervalCount;
    if (count <= 1) {
      return switch (sub.intervalUnit) {
        BillingIntervalUnit.day => t.subscriptions.cycleDaily,
        BillingIntervalUnit.month => t.subscriptions.cycleMonthly,
        BillingIntervalUnit.year => t.subscriptions.cycleYearly,
      };
    }
    final unit = switch (sub.intervalUnit) {
      BillingIntervalUnit.day => t.subscriptions.unitDays,
      BillingIntervalUnit.month => t.subscriptions.unitMonths,
      BillingIntervalUnit.year => t.subscriptions.unitYears,
    };
    return t.subscriptions.cycleEvery(count: count, unit: unit);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({
    required this.paymentsAsync,
    required this.onRetry,
  });

  final AsyncValue<List<SubscriptionPayment>> paymentsAsync;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                t.subscriptions.paymentHistory,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            paymentsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => ErrorState.fromError(
                e,
                title: t.subscriptions.paymentsLoadFailed,
                onRetry: onRetry,
              ),
              data: (payments) {
                if (payments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      t.subscriptions.noPayments,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final payment in payments)
                      _PaymentTile(payment: payment),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final SubscriptionPayment payment;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final created = payment.created?.toLocal();
    final proofUrl = payment.proofImageUrl;
    final (color, icon) = switch (payment.status) {
      SubscriptionPaymentStatus.pending => (
          Colors.orange.shade800,
          Icons.hourglass_top_rounded,
        ),
      SubscriptionPaymentStatus.approved => (
          Colors.green.shade700,
          Icons.check_circle_outline,
        ),
      SubscriptionPaymentStatus.rejected => (
          theme.colorScheme.error,
          Icons.cancel_outlined,
        ),
    };
    final adminNote = payment.adminNote;
    final subtitleParts = <String>[
      if (created != null) DateFormat.yMMMd().add_jm().format(created),
      if (payment.status == SubscriptionPaymentStatus.rejected &&
          adminNote != null &&
          adminNote.isNotEmpty)
        adminNote,
    ];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: color),
      title: Text(
        currency.format(payment.amount),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join('\n')),
      isThreeLine: subtitleParts.length > 1,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            payment.status.displayName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (proofUrl != null && proofUrl.isNotEmpty)
            Text(
              t.subscriptions.viewProof,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      onTap: proofUrl == null || proofUrl.isEmpty
          ? null
          : () => showDialog<void>(
                context: context,
                builder: (dialogContext) => Dialog(
                  child: InteractiveViewer(
                    child: Image.network(
                      proofUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Padding(
                        padding: const EdgeInsets.all(32),
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
