import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../pos/domain/sale.dart';
import '../controllers/ready_for_pickup_controller.dart';

/// Section displaying ready-for-pickup orders on the dashboard.
///
/// Shows:
/// - Summary with paid/unpaid counts
/// - Up to 5 orders with customer name, amount, and payment status
/// - Navigation to sales history and individual sale details
class ReadyForPickupSection extends ConsumerWidget {
  const ReadyForPickupSection({super.key});

  /// Maximum items to show in the list.
  static const _maxItems = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(readyForPickupSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (!summary.hasReadySales) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ready for Pickup',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => const SalesHistoryRoute().go(context),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ReadyForPickupCard(
                summary: summary,
                maxItems: _maxItems,
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _LoadingCard(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ReadyForPickupCard extends StatelessWidget {
  const _ReadyForPickupCard({
    required this.summary,
    required this.maxItems,
  });

  final ReadyForPickupSummary summary;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final displayedSales = summary.sales.take(maxItems).toList();
    final remainingCount = summary.totalCount - displayedSales.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.totalCount} order${summary.totalCount > 1 ? 's' : ''} ready',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${summary.paidCount} paid • ${summary.unpaidCount} unpaid',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Sales list
            ...displayedSales.map((sale) => _SaleListTile(
                  sale: sale,
                  currencyFormat: currencyFormat,
                )),
            // Show remaining count
            if (remainingCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '+ $remainingCount more',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SaleListTile extends StatelessWidget {
  const _SaleListTile({
    required this.sale,
    required this.currencyFormat,
  });

  final Sale sale;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => SaleDetailRoute(id: sale.id).go(context),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Icon(
              Icons.circle,
              size: 6,
              color: sale.isPaid ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                sale.customerDisplay ?? sale.receiptNumber,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currencyFormat.format(sale.totalAmount),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            _PaymentStatusBadge(isPaid: sale.isPaid),
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Unpaid',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
