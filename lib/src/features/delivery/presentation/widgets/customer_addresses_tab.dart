import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../domain/customer_address.dart';
import '../../domain/delivery_rate.dart';
import '../controllers/customer_addresses_controller.dart';
import '../controllers/delivery_rates_controller.dart';
import 'customer_address_form_dialog.dart';

/// "Addresses" tab of a customer: saved delivery addresses with a default.
class CustomerAddressesTab extends ConsumerWidget {
  const CustomerAddressesTab({
    super.key,
    required this.customerId,
    this.branchId,
  });

  final String customerId;

  /// The customer's branch; its delivery rates can be attached to addresses.
  final String? branchId;

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    CustomerAddress? address,
  }) async {
    final rates = branchId == null || branchId!.isEmpty
        ? const <DeliveryRate>[]
        : (ref.read(deliveryRatesControllerProvider(branchId!)).value ??
            const <DeliveryRate>[]);
    final result = await showCustomerAddressFormDialog(
      context,
      customerId: customerId,
      rates: rates,
      address: address,
    );
    if (result == null || !context.mounted) return;
    final error = await ref
        .read(customerAddressesControllerProvider(customerId).notifier)
        .save(result);
    if (!context.mounted) return;
    if (error != null) showErrorSnackBar(context, message: error);
  }

  Future<void> _setDefault(
    BuildContext context,
    WidgetRef ref,
    CustomerAddress address,
  ) async {
    final error = await ref
        .read(customerAddressesControllerProvider(customerId).notifier)
        .setDefault(address);
    if (!context.mounted) return;
    if (error != null) {
      showErrorSnackBar(context, message: error);
    } else {
      showSuccessSnackBar(context, message: 'Default delivery address updated');
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CustomerAddress address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address'),
        content: Text('Delete "${address.displayName}"?'),
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
        .read(customerAddressesControllerProvider(customerId).notifier)
        .remove(address.id);
    if (!context.mounted) return;
    if (error != null) showErrorSnackBar(context, message: error);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addressesAsync =
        ref.watch(customerAddressesControllerProvider(customerId));
    final rates = branchId == null || branchId!.isEmpty
        ? const <DeliveryRate>[]
        : (ref.watch(deliveryRatesControllerProvider(branchId!)).value ??
            const <DeliveryRate>[]);
    String? rateName(String? id) {
      if (id == null) return null;
      for (final r in rates) {
        if (r.id == id) return r.name;
      }
      return null;
    }

    return addressesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load addresses: $e')),
      data: (addresses) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Saved delivery addresses. The default is preselected when '
                  'creating a delivery order for this customer.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _edit(context, ref),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add address'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (addresses.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.location_off_outlined,
                        size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(
                      'No saved addresses',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The first address you add becomes the default.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          for (final a in addresses)
            Card(
              child: ListTile(
                isThreeLine: true,
                leading: Icon(
                  a.isDefault ? Icons.star : Icons.location_on_outlined,
                  color: a.isDefault ? theme.colorScheme.primary : null,
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        (a.label != null && a.label!.isNotEmpty)
                            ? a.label!
                            : a.address,
                      ),
                    ),
                    if (a.isDefault) ...[
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
                subtitle: Text(
                  [
                    if (a.label != null && a.label!.isNotEmpty) a.address,
                    if (a.distanceKm != null) '${a.distanceKm} km',
                    if (rateName(a.deliveryRateId) != null)
                      'Rate: ${rateName(a.deliveryRateId)}',
                    if (a.notes != null) a.notes!,
                  ].join('\n'),
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Address options',
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _edit(context, ref, address: a);
                      case 'default':
                        _setDefault(context, ref, a);
                      case 'delete':
                        _delete(context, ref, a);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (!a.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Text('Set as default'),
                      ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () => _edit(context, ref, address: a),
              ),
            ),
        ],
      ),
    );
  }
}
