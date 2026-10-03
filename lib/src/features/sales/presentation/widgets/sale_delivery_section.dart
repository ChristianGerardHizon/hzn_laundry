import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../pos/domain/sale.dart';

/// Delivery details (address, distance, fee, notes, proof photo) for delivery
/// orders. Renders nothing for pickup orders.
class SaleDeliverySection extends ConsumerWidget {
  const SaleDeliverySection({
    super.key,
    required this.sale,
    this.compact = false,
  });

  final Sale sale;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!sale.isDelivery) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final baseUrl = ref.watch(pocketbaseProvider).baseURL;
    final photo = sale.deliveryPhoto;
    final photoUrl = photo == null
        ? null
        : '$baseUrl/api/files/sales/${sale.id}/${Uri.encodeComponent(photo)}';

    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
            ],
          ),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 12 : 16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.delivery_dining,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Delivery',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (sale.deliveryAddress != null)
                row(Icons.location_on_outlined, 'Address',
                    sale.deliveryAddress!),
              if (sale.distanceKm != null)
                row(Icons.route, 'Distance', '${sale.distanceKm} km'),
              row(
                Icons.local_shipping_outlined,
                'Delivery fee',
                '${sale.deliveryFee.toCurrency()}'
                '${sale.deliveryFeeOverridden ? ' (manual)' : ''}',
              ),
              if (sale.deliveryNotes != null)
                row(Icons.sticky_note_2_outlined, 'Notes',
                    sale.deliveryNotes!),
              if (sale.forDeliveryAt != null)
                row(
                  Icons.schedule,
                  'Dispatched',
                  DateFormat('MMM dd, yyyy hh:mm a')
                      .format(sale.forDeliveryAt!),
                ),
              if (photoUrl != null) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photoUrl,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text(
                      'Delivery photo unavailable',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
