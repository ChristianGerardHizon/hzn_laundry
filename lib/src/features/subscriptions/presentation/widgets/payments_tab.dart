import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../domain/subscription_payment.dart';
import '../controllers/pending_subscription_payments_controller.dart';

const _kBrandTeal = Color(0xFF45A9AB);
const _kInk = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kSurfaceBorder = Color(0xFF2A2A2A);
const _kMuted = Color(0xFF9CA3AF);

/// Super Admin tab: pending subscription payment proofs.
class PaymentsTab extends HookConsumerWidget {
  const PaymentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final paymentsAsync =
        ref.watch(pendingSubscriptionPaymentsControllerProvider);
    final currency = useMemoized(
      () => NumberFormat.currency(symbol: '₱', decimalDigits: 2),
    );

    return paymentsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: _kBrandTeal),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorState.fromError(
            e,
            onRetry: () => ref
                .read(pendingSubscriptionPaymentsControllerProvider.notifier)
                .refresh(),
          ),
        ),
      ),
      data: (payments) {
        return RefreshIndicator(
          color: _kBrandTeal,
          onRefresh: () => ref
              .read(pendingSubscriptionPaymentsControllerProvider.notifier)
              .refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    t.subscriptions.pendingPayments,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              if (payments.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      t.subscriptions.noPendingPayments,
                      style: const TextStyle(color: _kMuted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList.separated(
                    itemCount: payments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _PaymentCard(
                        payment: payments[index],
                        currency: currency,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentCard extends HookConsumerWidget {
  const _PaymentCard({
    required this.payment,
    required this.currency,
  });

  final SubscriptionPayment payment;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isBusy = useState(false);
    final dateFmt = useMemoized(() => DateFormat.yMMMd().add_jm());

    Future<void> review({required bool approved}) async {
      final note = await _promptAdminNote(context, approved: approved);
      if (note == null || !context.mounted) return;
      if (isBusy.value) return;
      isBusy.value = true;
      try {
        final ok = await ref
            .read(pendingSubscriptionPaymentsControllerProvider.notifier)
            .reviewPayment(
              payment.id,
              approved: approved,
              adminNote: note.isEmpty ? null : note,
            );
        if (!context.mounted) return;
        if (ok) {
          showSuccessSnackBar(
            context,
            message: approved
                ? t.subscriptions.paymentApproved
                : t.subscriptions.paymentRejected,
            useRootMessenger: false,
          );
        } else {
          showErrorSnackBar(
            context,
            message: t.subscriptions.reviewFailed,
            useRootMessenger: false,
          );
        }
      } finally {
        if (context.mounted) isBusy.value = false;
      }
    }

    final orgLabel = payment.organizationName?.isNotEmpty == true
        ? payment.organizationName!
        : payment.organizationId;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kSurfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orgLabel,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${t.subscriptions.amount}: ${currency.format(payment.amount)}',
                        style: const TextStyle(
                          color: _kBrandTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (payment.created != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${t.subscriptions.submitted}: '
                          '${dateFmt.format(payment.created!.toLocal())}',
                          style: const TextStyle(color: _kMuted, fontSize: 12),
                        ),
                      ],
                      if (payment.note?.isNotEmpty == true) ...[
                        const SizedBox(height: 6),
                        Text(
                          payment.note!,
                          style: const TextStyle(color: _kMuted, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                if (payment.proofImageUrl != null &&
                    payment.proofImageUrl!.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showProofPreview(
                      context,
                      payment.proofImageUrl!,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: NetworkImage(payment.proofImageUrl!),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: _kInk,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: _kMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy.value ? null : () => review(approved: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    child: Text(t.subscriptions.reject),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: isBusy.value ? null : () => review(approved: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kBrandTeal,
                      foregroundColor: _kInk,
                    ),
                    child: isBusy.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.subscriptions.approve),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Returns admin note string, or `null` if cancelled.
  Future<String?> _promptAdminNote(
    BuildContext context, {
    required bool approved,
  }) async {
    final t = Translations.of(context);
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormBuilderState>();
        return ScaffoldMessenger(
          child: Builder(
            builder: (ctx) => AlertDialog(
              backgroundColor: _kSurface,
              title: Text(
                approved
                    ? t.subscriptions.approve
                    : t.subscriptions.reject,
              ),
              content: FormBuilder(
                key: formKey,
                child: FormBuilderTextField(
                  name: 'adminNote',
                  decoration: InputDecoration(
                    labelText: t.subscriptions.adminNote,
                  ),
                  maxLines: 3,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => ctx.pop(),
                  child: Text(t.common.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    formKey.currentState?.save();
                    final note = formKey.currentState?.value['adminNote']
                            as String? ??
                        '';
                    ctx.pop(note.trim());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        approved ? _kBrandTeal : Colors.redAccent,
                    foregroundColor: approved ? _kInk : Colors.white,
                  ),
                  child: Text(
                    approved
                        ? t.subscriptions.approve
                        : t.subscriptions.reject,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProofPreview(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _kInk,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
          child: InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
