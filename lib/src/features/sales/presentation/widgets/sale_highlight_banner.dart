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
  });

  final OrderStatus orderStatus;
  final bool isPaid;
  final String saleStatus;
  final PaymentStatus paymentStatus;
  final num? balanceDue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = _getHighlight();

    return Container(
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
                      Text(
                        highlight.secondaryInfo!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: highlight.secondaryColor ??
                              theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _paymentSecondaryText() {
    final currencyFormat =
        NumberFormat.currency(symbol: '₱', decimalDigits: 2);
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
      return _HighlightInfo(
        color: Colors.red,
        icon: Icons.cancel,
        title: 'Voided',
        description: 'This sale has been voided and cancelled.',
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
        description: 'Order is ready but payment is required before pickup.',
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
        title: 'Ready for Pickup',
        description: 'Order is complete and paid. Ready to release to customer.',
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

    // Priority 7: Picked up + Unpaid/Partial (unusual case)
    if (orderStatus == OrderStatus.pickedUp && !isPaid) {
      return _HighlightInfo(
        color: Colors.red.shade600,
        icon: Icons.warning,
        title: 'Picked Up - Unpaid',
        description: 'Order was released but payment is still pending.',
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
        description: 'Order has been picked up by the customer.',
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
