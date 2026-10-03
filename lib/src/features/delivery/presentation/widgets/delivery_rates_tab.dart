import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../domain/delivery_rate.dart';
import '../controllers/delivery_rates_controller.dart';
import 'delivery_rate_form_dialog.dart';

/// "Delivery rates" tab of a branch: list, add, edit, set default, delete.
class DeliveryRatesTab extends ConsumerWidget {
  const DeliveryRatesTab({super.key, required this.branchId});

  final String branchId;

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    DeliveryRate rate,
  ) async {
    final error =
        await ref.read(deliveryRatesControllerProvider(branchId).notifier).save(rate);
    if (!context.mounted) return;
    if (error != null) showErrorSnackBar(context, message: error);
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    DeliveryRate? rate,
  }) async {
    final result = await showDeliveryRateFormDialog(
      context,
      branchId: branchId,
      rate: rate,
    );
    if (result == null || !context.mounted) return;
    await _save(context, ref, result);
  }

  Future<void> _setDefault(
    BuildContext context,
    WidgetRef ref,
    DeliveryRate rate,
  ) async {
    final error = await ref
        .read(deliveryRatesControllerProvider(branchId).notifier)
        .setDefault(rate);
    if (!context.mounted) return;
    if (error != null) {
      showErrorSnackBar(context, message: error);
    } else {
      showSuccessSnackBar(context, message: '"${rate.name}" is now the default');
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    DeliveryRate rate,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete delivery rate'),
        content: Text('Delete "${rate.name}"? Existing orders keep their fee.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await ref
        .read(deliveryRatesControllerProvider(branchId).notifier)
        .remove(rate.id);
    if (!context.mounted) return;
    if (error != null) showErrorSnackBar(context, message: error);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ratesAsync = ref.watch(deliveryRatesControllerProvider(branchId));

    return ratesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load delivery rates: $e')),
      data: (rates) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fee = base fee + rate per km beyond the included distance. '
                  'The default rate is preselected on new delivery orders.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _edit(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add rate'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (rates.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.local_shipping_outlined,
                        size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(
                      'No delivery rates yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a rate to charge delivery fees on orders. The first '
                      'rate you add becomes the default.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          for (final rate in rates)
            Card(
              child: ListTile(
                leading: Icon(
                  rate.isDefault ? Icons.star : Icons.local_shipping_outlined,
                  color: rate.isDefault ? theme.colorScheme.primary : null,
                ),
                title: Row(
                  children: [
                    Flexible(child: Text(rate.name)),
                    if (rate.isDefault) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: const Text('Default'),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                    ],
                  ],
                ),
                subtitle: Text(rate.summary),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Rate options',
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _edit(context, ref, rate: rate);
                      case 'default':
                        _setDefault(context, ref, rate);
                      case 'delete':
                        _delete(context, ref, rate);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (!rate.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Text('Set as default'),
                      ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () => _edit(context, ref, rate: rate),
              ),
            ),
        ],
      ),
    );
  }
}
