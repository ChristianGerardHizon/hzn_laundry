import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../customers/domain/customer.dart';
import '../../../customers/presentation/controllers/customer_provider.dart';
import '../../../pos/domain/sale.dart';

/// Result of an order-status notification confirmation step.
class OrderNotificationConfirmResult {
  const OrderNotificationConfirmResult({
    required this.proceed,
    this.resend = false,
  });

  final bool proceed;
  final bool resend;
}

/// Loads the linked customer for [sale], if any.
Future<Customer?> loadSaleCustomer(WidgetRef ref, Sale sale) async {
  final customerId = sale.customerId;
  if (customerId == null || customerId.isEmpty) return null;
  try {
    return await ref.read(customerProvider(customerId).future);
  } catch (_) {
    return null;
  }
}

/// Confirms ready-for-pickup email send / optional resend.
Future<OrderNotificationConfirmResult> confirmReadyNotification({
  required BuildContext context,
  required Sale sale,
  required Customer? customer,
}) {
  return _confirmStatusNotification(
    context: context,
    sale: sale,
    customer: customer,
    alreadySent: sale.hasReadyNotificationBeenSent,
    firstTitle: 'Send ready notification?',
    firstBody: sale.isDelivery
        ? 'An email will be sent to {email} stating this order is ready '
            'for delivery. This cannot be revoked.'
        : 'An email will be sent to {email} stating this order is ready '
            'for pickup. This cannot be revoked.',
    firstConfirmLabel: 'Send & mark Ready',
    againTitle: 'Mark as Ready?',
    againBody: 'A ready notification was already sent to {email}.',
    againConfirmLabel: 'Mark Ready',
  );
}

/// Confirms picked-up email send / optional resend.
Future<OrderNotificationConfirmResult> confirmPickedUpNotification({
  required BuildContext context,
  required Sale sale,
  required Customer? customer,
}) {
  return _confirmStatusNotification(
    context: context,
    sale: sale,
    customer: customer,
    alreadySent: sale.hasPickedUpNotificationBeenSent,
    firstTitle: sale.isDelivery
        ? 'Send delivered notification?'
        : 'Send picked-up notification?',
    firstBody: sale.isDelivery
        ? 'An email will be sent to {email} stating this order has been '
            'delivered. This cannot be revoked.'
        : 'An email will be sent to {email} stating this order has been '
            'picked up. This cannot be revoked.',
    firstConfirmLabel: 'Send & mark Fulfilled',
    againTitle: 'Mark as Fulfilled?',
    againBody: sale.isDelivery
        ? 'A delivered notification was already sent to {email}.'
        : 'A picked-up notification was already sent to {email}.',
    againConfirmLabel: 'Mark Fulfilled',
  );
}

Future<OrderNotificationConfirmResult> _confirmStatusNotification({
  required BuildContext context,
  required Sale sale,
  required Customer? customer,
  required bool alreadySent,
  required String firstTitle,
  required String firstBody,
  required String firstConfirmLabel,
  required String againTitle,
  required String againBody,
  required String againConfirmLabel,
}) async {
  final email = customer?.email?.trim() ?? '';
  final hasEmail = email.isNotEmpty;

  if (!sale.sendNotification || !hasEmail) {
    return const OrderNotificationConfirmResult(proceed: true);
  }

  if (!alreadySent) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(firstTitle),
        content: Text(firstBody.replaceAll('{email}', email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(firstConfirmLabel),
          ),
        ],
      ),
    );
    return OrderNotificationConfirmResult(proceed: confirmed == true);
  }

  var resend = false;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(againTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(againBody.replaceAll('{email}', email)),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: resend,
                  onChanged: (value) =>
                      setState(() => resend = value ?? false),
                  title: const Text('Resend notification'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(againConfirmLabel),
              ),
            ],
          );
        },
      );
    },
  );

  return OrderNotificationConfirmResult(
    proceed: confirmed == true,
    resend: confirmed == true && resend,
  );
}

/// Short confirm before manually resending a status notification.
Future<bool> confirmResendStatusNotification({
  required BuildContext context,
  required String email,
  required String kindLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Resend notification?'),
      content: Text(
        'Send another $kindLabel email to $email?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Resend'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Back-compat alias for ready resend confirm.
Future<bool> confirmResendReadyNotification({
  required BuildContext context,
  required String email,
}) {
  return confirmResendStatusNotification(
    context: context,
    email: email,
    kindLabel: 'ready-for-pickup',
  );
}
