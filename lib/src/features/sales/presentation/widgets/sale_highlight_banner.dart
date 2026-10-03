import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/payment_status.dart';

/// A prominent banner that highlights the most important status of a sale.
///
/// Priority logic:
/// 1. Refunded - special case, always show prominently
/// 2. Pending order - needs attention
/// 3. Ready for pickup + Unpaid - ready but needs payment first
/// 4. Ready for pickup + Paid - ready to release to customer
/// 5. Processing - in progress
/// 6. Picked up - completed
class SaleHighlightBanner extends StatelessWidget {
  const SaleHighlightBanner({
    super.key,
    required this.orderStatus,
    required this.isPaid,
    required this.saleStatus,
    this.paymentStatus = PaymentStatus.unpaid,
    this.balanceDue,
    this.voidedByName,
    this.voidedAt,
    this.isDelivery = false,
    this.onTap,
  });

  final OrderStatus orderStatus;
  final bool isPaid;
  final String saleStatus;
  final PaymentStatus paymentStatus;
  final num? balanceDue;
  final String? voidedByName;
  final DateTime? voidedAt;

  /// Delivery orders get delivery wording (ready / out for delivery / delivered).
  final bool isDelivery;

  /// When set, the banner is tappable (e.g. to change order status).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = _getHighlight();
    final interactive = onTap != null;

    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            highlight.color.withValues(alpha: 0.15),
            highlight.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight.color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlight.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              highlight.icon,
              color: highlight.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: highlight.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  highlight.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (highlight.secondaryInfo != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        highlight.secondaryIcon ?? Icons.info_outline,
                        size: 16,
                        color: highlight.secondaryColor ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          highlight.secondaryInfo!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: highlight.secondaryColor ??
                                theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (interactive)
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: highlight.color.withValues(alpha: 0.7),
            ),
        ],
      ),
    );

    if (!interactive) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }

  String _paymentSecondaryText() {
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    return switch (paymentStatus) {
      PaymentStatus.paid => 'Fully paid',
      PaymentStatus.partial => balanceDue != null
          ? 'Partially paid · ${currencyFormat.format(balanceDue)} remaining'
          : 'Partially paid',
      PaymentStatus.unpaid => 'Unpaid',
    };
  }

  Color _paymentSecondaryColor() {
    return switch (paymentStatus) {
      PaymentStatus.paid => Colors.green,
      PaymentStatus.partial => Colors.blue,
      PaymentStatus.unpaid => Colors.orange,
    };
  }

  IconData _paymentSecondaryIcon() {
    return switch (paymentStatus) {
      PaymentStatus.paid => Icons.check_circle,
      PaymentStatus.partial => Icons.timelapse,
      PaymentStatus.unpaid => Icons.pending,
    };
  }

  _HighlightInfo _getHighlight() {
    // Priority 1: Refunded sale
    if (saleStatus.toLowerCase() == 'refunded') {
      return _HighlightInfo(
        color: Colors.orange,
        icon: Icons.replay,
        title: 'Refunded',
        description: 'This sale has been refunded to the customer.',
      );
    }

    // Priority 2: Voided sale
    if (saleStatus.toLowerCase() == 'voided') {
      String? voidedSecondary;
      if (voidedByName != null && voidedByName!.isNotEmpty) {
        final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
        final when =
            voidedAt != null ? ' on ${dateFormat.format(voidedAt!)}' : '';
        voidedSecondary = 'Voided by $voidedByName$when';
      }
      return _HighlightInfo(
        color: Colors.red,
        icon: Icons.cancel,
        title: 'Voided',
        description: 'This sale was voided and cancelled.',
        secondaryInfo: voidedSecondary,
        secondaryIcon: Icons.person_outline,
        secondaryColor: Colors.red.shade700,
      );
    }

    // Priority 3: Pending order - needs attention
    if (orderStatus == OrderStatus.pending) {
      return _HighlightInfo(
        color: Colors.amber.shade700,
        icon: Icons.schedule,
        title: 'Pending',
        description: 'Order is waiting to be processed.',
        secondaryInfo: _paymentSecondaryText(),
        secondaryIcon: _paymentSecondaryIcon(),
        secondaryColor: _paymentSecondaryColor(),
      );
    }

    // Priority 4: Ready for pickup + Unpaid/Partial - needs payment before release
    if (orderStatus == OrderStatus.ready && !isPaid) {
      return _HighlightInfo(
        color: Colors.red.shade600,
        icon: Icons.payment,
        title: 'Ready - Awaiting Payment',
        description: isDelivery
            ? 'Order is ready. Collect payment on delivery or before dispatch.'
            : 'Order is ready but payment is required before pickup.',
        secondaryInfo: _paymentSecondaryText(),
        secondaryIcon: _paymentSecondaryIcon(),
        secondaryColor: _paymentSecondaryColor(),
      );
    }

    // Priority 5: Ready for pickup + Paid - ready to release
    if (orderStatus == OrderStatus.ready && isPaid) {
      return _HighlightInfo(
        color: Colors.green,
        icon: Icons.check_circle,
        title: isDelivery ? 'Ready for Delivery' : 'Ready for Pickup',
        description: isDelivery
            ? 'Order is complete and paid. Ready to be delivered.'
            : 'Order is complete and paid. Ready to release to customer.',
        secondaryInfo: _paymentSecondaryText(),
        secondaryIcon: _paymentSecondaryIcon(),
        secondaryColor: _paymentSecondaryColor(),
      );
    }

    // Priority 6: Processing
    if (orderStatus == OrderStatus.processing) {
      return _HighlightInfo(
        color: Colors.blue,
        icon: Icons.autorenew,
        title: 'Processing',
        description: 'Order is being processed.',
        secondaryInfo: _paymentSecondaryText(),
        secondaryIcon: _paymentSecondaryIcon(),
        secondaryColor: _paymentSecondaryColor(),
      );
    }

    // Out for delivery (delivery orders only)
    if (orderStatus == OrderStatus.forDelivery) {
      return _HighlightInfo(
        color: Colors.cyan.shade700,
        icon: Icons.delivery_dining,
        title: isPaid ? 'Out for Delivery' : 'Out for Delivery - Collect Payment',
        description: isPaid
            ? 'Order is on its way to the customer.'
            : 'Order is on its way. Collect payment on delivery (COD).',
        secondaryInfo: _paymentSecondaryText(),
        secondaryIcon: _paymentSecondaryIcon(),
        secondaryColor: _paymentSecondaryColor(),
      );
    }

    // Priority 7: Picked up + Unpaid/Partial (unusual case)
    if (orderStatus == OrderStatus.pickedUp && !isPaid) {
      return _HighlightInfo(
        color: Colors.red.shade600,
        icon: Icons.warning,
        title: isDelivery ? 'Delivered - Unpaid' : 'Picked Up - Unpaid',
        description: isDelivery
            ? 'Order was delivered but payment is still pending.'
            : 'Order was released but payment is still pending.',
        secondaryInfo: _paymentSecondaryText(),
        secondaryIcon: _paymentSecondaryIcon(),
        secondaryColor: _paymentSecondaryColor(),
      );
    }

    // Priority 8: Picked up + Paid - completed
    if (orderStatus == OrderStatus.pickedUp && isPaid) {
      return _HighlightInfo(
        color: Colors.grey,
        icon: Icons.task_alt,
        title: 'Completed',
        description: isDelivery
            ? 'Order has been delivered to the customer.'
            : 'Order has been picked up by the customer.',
        secondaryInfo: _paymentSecondaryText(),
        secondaryIcon: _paymentSecondaryIcon(),
        secondaryColor: _paymentSecondaryColor(),
      );
    }

    // Default fallback
    return _HighlightInfo(
      color: Colors.grey,
      icon: Icons.receipt_long,
      title: 'Sale',
      description: 'View sale details below.',
    );
  }
}

class _HighlightInfo {
  const _HighlightInfo({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    this.secondaryInfo,
    this.secondaryIcon,
    this.secondaryColor,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final String? secondaryInfo;
  final IconData? secondaryIcon;
  final Color? secondaryColor;
}
