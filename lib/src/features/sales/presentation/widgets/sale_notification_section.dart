import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../customers/presentation/controllers/customer_provider.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/sale.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_refresh.dart';
import 'ready_notification_confirm.dart';

/// Per-order send-notification toggle and resend controls.
class SaleNotificationSection extends HookConsumerWidget {
  const SaleNotificationSection({
    super.key,
    required this.sale,
    this.compact = false,
  });

  final Sale sale;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSaving = useState(false);
    final status = sale.status.toLowerCase();
    final isTerminal = status == 'refunded' || status == 'voided';
    final canEditToggle = !isTerminal &&
        sale.orderStatus != OrderStatus.ready &&
        sale.orderStatus != OrderStatus.pickedUp;

    final customerAsync = sale.customerId != null && sale.customerId!.isNotEmpty
        ? ref.watch(customerProvider(sale.customerId!))
        : null;
    final customerEmail = customerAsync?.value?.email?.trim() ?? '';
    final hasEmail = customerEmail.isNotEmpty;
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    Future<void> toggleSend(bool value) async {
      isSaving.value = true;
      final result = await ref
          .read(salesRepositoryProvider)
          .updateSendNotification(sale.id, value);
      isSaving.value = false;
      if (!context.mounted) return;
      result.fold(
        (failure) =>
            showErrorSnackBar(context, message: failure.messageString),
        (_) {
          refreshSaleRelatedProviders(ref, saleId: sale.id);
          ref.invalidate(saleProvider(sale.id));
        },
      );
    }

    Future<void> handleResendReady() async {
      if (!hasEmail) return;
      final confirmed = await confirmResendStatusNotification(
        context: context,
        email: customerEmail,
        kindLabel: 'ready-for-pickup',
      );
      if (!confirmed || !context.mounted) return;

      isSaving.value = true;
      final result =
          await ref.read(salesRepositoryProvider).resendReadyNotification(sale.id);
      isSaving.value = false;
      if (!context.mounted) return;
      result.fold(
        (failure) =>
            showErrorSnackBar(context, message: failure.messageString),
        (_) {
          refreshSaleRelatedProviders(ref, saleId: sale.id);
          ref.invalidate(saleProvider(sale.id));
          showSuccessSnackBar(
            context,
            message: 'Ready notification resent to $customerEmail',
          );
        },
      );
    }

    Future<void> handleResendPickedUp() async {
      if (!hasEmail) return;
      final confirmed = await confirmResendStatusNotification(
        context: context,
        email: customerEmail,
        kindLabel: 'picked-up',
      );
      if (!confirmed || !context.mounted) return;

      isSaving.value = true;
      final result = await ref
          .read(salesRepositoryProvider)
          .resendPickedUpNotification(sale.id);
      isSaving.value = false;
      if (!context.mounted) return;
      result.fold(
        (failure) =>
            showErrorSnackBar(context, message: failure.messageString),
        (_) {
          refreshSaleRelatedProviders(ref, saleId: sale.id);
          ref.invalidate(saleProvider(sale.id));
          showSuccessSnackBar(
            context,
            message: 'Picked-up notification resent to $customerEmail',
          );
        },
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: sale.sendNotification,
              onChanged: canEditToggle && !isSaving.value ? toggleSend : null,
              title: const Text('Send notification'),
              subtitle: Text(
                !hasEmail && sale.customerId != null
                    ? 'Customer has no email — notification will not be sent'
                    : sale.customerId == null
                        ? 'No customer linked'
                        : 'Email the customer when this order is Ready or Picked Up',
              ),
            ),
            if (sale.hasReadyNotificationBeenSent) ...[
              const SizedBox(height: 4),
              Text(
                'Ready notification sent'
                ' · ${dateFormat.format(sale.readyNotificationSentAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (sale.hasPickedUpNotificationBeenSent) ...[
              const SizedBox(height: 4),
              Text(
                'Picked-up notification sent'
                ' · ${dateFormat.format(sale.pickedUpNotificationSentAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (sale.sendNotification &&
                hasEmail &&
                sale.orderStatus == OrderStatus.ready) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isSaving.value ? null : handleResendReady,
                  icon: isSaving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.mark_email_read_outlined, size: 18),
                  label: Text(
                    isSaving.value
                        ? 'Sending...'
                        : sale.hasReadyNotificationBeenSent
                            ? 'Resend ready notification'
                            : 'Send ready notification',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
            if (sale.sendNotification &&
                hasEmail &&
                sale.orderStatus == OrderStatus.pickedUp) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isSaving.value ? null : handleResendPickedUp,
                  icon: isSaving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.mark_email_read_outlined, size: 18),
                  label: Text(
                    isSaving.value
                        ? 'Sending...'
                        : sale.hasPickedUpNotificationBeenSent
                            ? 'Resend picked-up notification'
                            : 'Send picked-up notification',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
