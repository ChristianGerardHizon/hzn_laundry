import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/kanban_sales_controller.dart';
import 'orders_by_resource_dialog.dart';

/// Dashboard section showing a summary of orders grouped by resource
/// (machine/storage) with a "View" button to open the full dialog.
class OrdersByResourceSection extends ConsumerWidget {
  const OrdersByResourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final kanbanAsync = ref.watch(kanbanSalesProvider);

    return kanbanAsync.when(
      data: (data) {
        // Derive summary from already-loaded kanban data
        final allServiceItems = data.serviceItemsBySale.values.expand((l) => l);
        final machineIds = allServiceItems
            .where((i) => i.machineId != null && i.machineId!.isNotEmpty)
            .map((i) => i.machineId!)
            .toSet();
        final storageIds = allServiceItems
            .expand((i) => i.storageIds)
            .toSet();
        final totalOrders = data.totalCount;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.hub_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Orders by Resource',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => showOrdersByResourceDialog(context),
                    child: const Text('View'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryChip(
                    icon: Icons.local_laundry_service,
                    label: '${machineIds.length} machine${machineIds.length == 1 ? '' : 's'} in use',
                  ),
                  _SummaryChip(
                    icon: Icons.inventory_2_outlined,
                    label: '${storageIds.length} storage${storageIds.length == 1 ? '' : 's'} in use',
                  ),
                  _SummaryChip(
                    icon: Icons.receipt_long,
                    label: '$totalOrders order${totalOrders == 1 ? '' : 's'}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(
        label,
        style: theme.textTheme.bodySmall,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
