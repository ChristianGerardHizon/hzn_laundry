import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/printing/claim_sheet_disclaimer.dart';
import '../../../pos/domain/order_status.dart';
import '../../../pos/domain/payment_status.dart';
import '../../domain/customer_history.dart';
import '../controllers/customer_history_controller.dart';
import 'print_helper.dart';

/// Public page (no auth) showing a customer's order history by token.
class CustomerHistoryPage extends HookConsumerWidget {
  const CustomerHistoryPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(customerHistoryProvider(token));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: asyncHistory.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (history) => _HistoryView(history: history, token: token),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Unable to load your orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'This link may have expired. Please contact Hizone Laundry for a new link.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.history, required this.token});
  final CustomerHistory history;
  final String token;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${history.customer.name}',
                  style: theme.textTheme.titleLarge,
                ),
                if (history.customer.phone != null &&
                    history.customer.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    history.customer.phone!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(
                      label: 'Pending',
                      count: history.pendingCount,
                      color: Colors.orange,
                    ),
                    _SummaryChip(
                      label: 'Unpaid',
                      count: history.unpaidCount,
                      color: Colors.red,
                    ),
                    _SummaryChip(
                      label: 'Total Orders',
                      count: history.sales.length,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (history.sales.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: Text('No orders yet.')),
          )
        else
          ...history.sales.map((s) => _SaleTile(sale: s, token: token)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

class _SaleTile extends HookConsumerWidget {
  const _SaleTile({required this.sale, required this.token});
  final CustomerHistorySale sale;
  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expanded = useState(false);
    final highlightColor = sale.isPending || sale.isUnpaid
        ? Colors.orange.withValues(alpha: 0.5)
        : null;

    final dateLabel = _formatDate(
      sale.postedDate ?? sale.created,
    );
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    final detailAsync = expanded.value
        ? ref.watch(customerHistorySaleDetailProvider(token, sale.id))
        : null;

    return Card(
      shape: highlightColor != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: highlightColor, width: 1.5),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => expanded.value = !expanded.value,
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            highlightColor: theme.colorScheme.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sale.receiptNumber.isEmpty
                              ? 'Order ${sale.id}'
                              : '#${sale.receiptNumber}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        currency.format(sale.totalAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        expanded.value ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  if (dateLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusBadge(
                        label: _orderStatusLabel(sale.orderStatus),
                        color: _orderStatusColor(sale.orderStatus),
                        icon: _orderStatusIcon(sale.orderStatus),
                      ),
                      _StatusBadge(
                        label: _paymentStatusLabel(sale.paymentStatus),
                        color: _paymentStatusColor(sale.paymentStatus),
                        icon: sale.paymentStatus == PaymentStatus.paid
                            ? Icons.check_circle
                            : Icons.payment,
                      ),
                      if (sale.packs > 0)
                        _StatusBadge(
                          label:
                              '${sale.packs} pack${sale.packs == 1 ? '' : 's'}',
                          color: Colors.blueGrey,
                          icon: Icons.shopping_bag_outlined,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded.value && detailAsync != null)
            _ExpandedDetail(detailAsync: detailAsync),
        ],
      ),
    );
  }

  String? _formatDate(DateTime? d) {
    if (d == null) return null;
    return DateFormat('MMM d, yyyy • h:mm a').format(d);
  }

  String _orderStatusLabel(OrderStatus s) => s.displayName;

  Color _orderStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.pickedUp:
        return Colors.grey;
    }
  }

  IconData _orderStatusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.ready:
        return Icons.check_circle_outline;
      case OrderStatus.pickedUp:
        return Icons.local_shipping;
    }
  }

  String _paymentStatusLabel(PaymentStatus s) => s.displayName;

  Color _paymentStatusColor(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.unpaid:
        return Colors.red;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
    }
  }
}

class _ExpandedDetail extends StatelessWidget {
  const _ExpandedDetail({required this.detailAsync});
  final AsyncValue<CustomerHistorySaleDetail> detailAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: detailAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('Unable to load details: $e'),
        data: (detail) => _DetailBody(detail: detail),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});
  final CustomerHistorySaleDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final sale = detail.sale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sale.receiptNumber.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '$claimSheetNumberLabel ${sale.receiptNumber}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (detail.services.isNotEmpty) ...[
          Text('Services', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          ...detail.services.map(
            (s) => _Line(
              name: s.serviceName,
              qty: s.quantity,
              unitPrice: s.unitPrice,
              subtotal: s.subtotal,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (detail.items.isNotEmpty) ...[
          Text('Items', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          ...detail.items.map(
            (it) => _Line(
              name: it.productName,
              qty: it.quantity,
              unitPrice: it.unitPrice,
              subtotal: it.subtotal,
            ),
          ),
          const SizedBox(height: 12),
        ],
        const Divider(),
        Row(
          children: [
            Text('Total', style: theme.textTheme.titleMedium),
            const Spacer(),
            Text(
              currency.format(sale.totalAmount),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (sale.notes != null && sale.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Notes', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(sale.notes!),
        ],
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        ...claimSheetDisclaimerLines.map(
          (line) => Text(
            line,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => printOrderDetail(detail),
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });

  final String name;
  final num qty;
  final num unitPrice;
  final num subtotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.bodyMedium),
                Text(
                  '$qty × ${currency.format(unitPrice)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            currency.format(subtotal),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
