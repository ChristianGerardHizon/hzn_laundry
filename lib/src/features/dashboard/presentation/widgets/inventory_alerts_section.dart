import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';

import '../../../../core/routing/routes/products.routes.dart';
import '../../domain/inventory_alert.dart';
import '../controllers/inventory_alerts_controller.dart';

/// Section displaying inventory alerts on the dashboard.
///
/// Shows:
/// - Low stock items (both lot-tracked and non-lot-tracked products)
/// - Products/lots near expiration
/// - Expired products/lots
class InventoryAlertsSection extends ConsumerWidget {
  const InventoryAlertsSection({super.key});

  /// Maximum items to show in each alert category.
  static const _maxItems = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsSummaryAsync = ref.watch(inventoryAlertsSummaryProvider);

    return alertsSummaryAsync.when(
      data: (summary) {
        if (!summary.hasAlerts) {
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
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Inventory Alerts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => const ProductsRoute().goScoped(context),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Expired products alert
              if (summary.expiredAlerts.isNotEmpty)
                _AlertCard(
                  icon: Icons.error_outline,
                  title: 'Expired Products',
                  subtitle:
                      '${summary.expiredCount} item${summary.expiredCount > 1 ? 's' : ''} expired',
                  color: Colors.red,
                  onTap: () => const ProductsRoute().goScoped(context),
                ),

              // Low stock alert
              if (summary.lowStockAlerts.isNotEmpty)
                _AlertCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Low Stock',
                  subtitle:
                      '${summary.lowStockCount} item${summary.lowStockCount > 1 ? 's' : ''} need restocking',
                  color: Colors.orange,
                  alerts: summary.lowStockAlerts.take(_maxItems).toList(),
                  totalCount: summary.lowStockCount,
                  onTap: () => const ProductsRoute().goScoped(context),
                ),

              // Near expiration alert
              if (summary.nearExpirationAlerts.isNotEmpty)
                _AlertCard(
                  icon: Icons.schedule,
                  title: 'Expiring Soon',
                  subtitle:
                      '${summary.nearExpirationCount} item${summary.nearExpirationCount > 1 ? 's' : ''} expiring within 30 days',
                  color: Colors.amber.shade700,
                  alerts: summary.nearExpirationAlerts.take(_maxItems).toList(),
                  totalCount: summary.nearExpirationCount,
                  onTap: () => const ProductsRoute().goScoped(context),
                ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _LoadingAlertCard(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.alerts,
    this.totalCount,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<InventoryAlert>? alerts;
  final int? totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              // Show alert list if available
              if (alerts != null && alerts!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...alerts!.map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert.displayLabel,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (alert.currentQuantity != null)
                            Text(
                              'Qty: ${alert.quantityDisplay}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    )),
                if (totalCount != null && totalCount! > alerts!.length) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+ ${totalCount! - alerts!.length} more',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingAlertCard extends StatelessWidget {
  const _LoadingAlertCard();

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
