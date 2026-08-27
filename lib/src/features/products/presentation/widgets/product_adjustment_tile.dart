import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/product_adjustment.dart';
import '../../domain/product_adjustment_type.dart';

/// List tile showing a single stock adjustment (delta, old → new, type, date).
class ProductAdjustmentTile extends StatelessWidget {
  const ProductAdjustmentTile({super.key, required this.adjustment});

  final ProductAdjustment adjustment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.Hm();

    final bool isIncrease = adjustment.isIncrease;
    final Color avatarColor =
        isIncrease ? Colors.green.shade100 : Colors.red.shade100;
    final Color iconColor = isIncrease ? Colors.green : Colors.red;
    final IconData icon = isIncrease ? Icons.add_circle : Icons.remove_circle;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: Icon(icon, color: iconColor),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isIncrease
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              adjustment.deltaDisplay,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${adjustment.oldValueDisplay} → ${adjustment.newValueDisplay}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                adjustment.type == ProductAdjustmentType.productStock
                    ? Icons.layers
                    : Icons.inventory_2,
                size: 14,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                adjustment.type.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
              const SizedBox(width: 8),
              if (adjustment.created != null)
                Flexible(
                  child: Text(
                    '${dateFormat.format(adjustment.created!)} at ${timeFormat.format(adjustment.created!)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          if (adjustment.reason != null && adjustment.reason!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              adjustment.reason!,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      isThreeLine: adjustment.reason != null && adjustment.reason!.isNotEmpty,
    );
  }
}
