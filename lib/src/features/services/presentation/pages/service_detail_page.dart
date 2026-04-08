import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/service_price_tier.dart';
import '../controllers/service_price_tiers_provider.dart';
import '../controllers/service_provider.dart';
import '../controllers/services_controller.dart';
import '../widgets/service_form_sheet.dart';
import '../widgets/service_price_tier_form_dialog.dart';

/// Service detail page showing service information.
class ServiceDetailPage extends HookConsumerWidget {
  const ServiceDetailPage({
    super.key,
    required this.serviceId,
  });

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceProvider(serviceId));
    final isTablet = Breakpoints.isTabletOrLarger(context);

    return serviceAsync.when(
      data: (service) {
        if (service == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Service Not Found'),
              automaticallyImplyLeading: !isTablet,
            ),
            body: const Center(
              child: Text('The requested service could not be found.'),
            ),
          );
        }

        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(service.name),
            automaticallyImplyLeading: !isTablet,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(serviceProvider(serviceId));
                  showInfoSnackBar(
                    context,
                    message: 'Refreshing...',
                    duration: const Duration(seconds: 1),
                  );
                },
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSheet(context, ref),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, ref, value, service.id),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Service info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Information',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        label: 'Name',
                        value: service.name,
                      ),
                      if (service.description != null &&
                          service.description!.isNotEmpty)
                        _InfoRow(
                          label: 'Description',
                          value: service.description!,
                        ),
                      if (service.categoryName != null)
                        _InfoRow(
                          label: 'Category',
                          value: service.categoryName!,
                        ),
                      _InfoRow(
                        label: 'Price',
                        value: service.hasVariablePrice
                            ? 'Variable'
                            : service.price.toCurrency(),
                      ),
                      if (service.estimatedDuration != null)
                        _InfoRow(
                          label: 'Est. Duration',
                          value: service.durationDisplay ?? '',
                        ),
                      _InfoRow(
                        label: 'Weight Based',
                        value: service.weightBased ? 'Yes' : 'No',
                      ),
                      _InfoRow(
                        label: 'Variable Price',
                        value: service.isVariablePrice ? 'Yes' : 'No',
                      ),
                      _InfoRow(
                        label: 'Quantity Prompt',
                        value: service.showPrompt ? 'Yes' : 'No',
                      ),
                      _InfoRow(
                        label: 'Max Quantity',
                        value: (service.maxQuantity != null && service.maxQuantity! > 0)
                            ? service.maxQuantity.toString()
                            : 'N/A',
                      ),
                      if (service.maxQuantity != null && service.maxQuantity! > 0)
                        _InfoRow(
                          label: 'Allow Excess',
                          value: service.allowExcess ? 'Yes' : 'No',
                        ),
                    ],
                  ),
                ),
              ),

              // Price tiers card
              const SizedBox(height: 16),
              _PriceTiersCard(
                serviceId: serviceId,
                unitLabel: service.quantityUnit?.shortPlural ??
                    (service.weightBased ? 'kg' : 'pcs'),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !isTablet,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !isTablet,
        ),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) async {
    final service =
        ref.read(serviceProvider(serviceId)).value;
    if (service == null) return;

    final result = await showServiceFormSheet(
      context,
      service: service,
    );

    if (result == true) {
      ref.invalidate(serviceProvider(serviceId));
      ref.read(servicesControllerProvider.notifier).refresh();
    }
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    String id,
  ) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Service'),
          content:
              const Text('Are you sure you want to delete this service?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await ref
            .read(servicesControllerProvider.notifier)
            .deleteService(id);
        if (success && context.mounted) {
          showSuccessSnackBar(context, message: 'Service deleted');
          context.pop();
        } else if (context.mounted) {
          showErrorSnackBar(context, message: 'Failed to delete service');
        }
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Price Tiers Card ────────────────────────────────────────────────────────

class _PriceTiersCard extends ConsumerWidget {
  const _PriceTiersCard({required this.serviceId, required this.unitLabel});

  final String serviceId;
  final String unitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tiersAsync = ref.watch(servicePriceTiersProvider(serviceId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Price Tiers',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add tier',
                  onPressed: () => _addTier(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 8),
            tiersAsync.when(
              data: (tiers) {
                if (tiers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No price tiers configured. The base price will be used for all quantities.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                final sorted = [...tiers]
                  ..sort(
                      (a, b) => a.minQuantity.compareTo(b.minQuantity));

                return Column(
                  children: [
                    for (int i = 0; i < sorted.length; i++)
                      _PriceTierRow(
                        tier: sorted[i],
                        serviceId: serviceId,
                        unitLabel: unitLabel,
                        nextTierMin: i + 1 < sorted.length
                            ? sorted[i + 1].minQuantity
                            : null,
                        allTiers: sorted,
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (error, _) => Text(
                'Error loading tiers: $error',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTier(BuildContext context, WidgetRef ref) async {
    final existingTiers =
        ref.read(servicePriceTiersProvider(serviceId)).value ?? [];
    final result = await showServicePriceTierFormDialog(
      context,
      serviceId: serviceId,
      existingTiers: existingTiers,
    );
    if (result == true) {
      ref.invalidate(servicePriceTiersProvider(serviceId));
    }
  }
}

class _PriceTierRow extends ConsumerWidget {
  const _PriceTierRow({
    required this.tier,
    required this.serviceId,
    required this.unitLabel,
    required this.allTiers,
    this.nextTierMin,
  });

  final ServicePriceTier tier;
  final String serviceId;
  final String unitLabel;
  final num? nextTierMin;
  final List<ServicePriceTier> allTiers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rangeText = tier.displayRange(unitLabel, nextTierMin: nextTierMin);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        rangeText,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${tier.pricePerUnit.toCurrency()}/$unitLabel',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            tooltip: 'Edit',
            onPressed: () => _editTier(context, ref),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
            tooltip: 'Delete',
            onPressed: () => _deleteTier(context, ref),
          ),
        ],
      ),
    );
  }

  void _editTier(BuildContext context, WidgetRef ref) async {
    final result = await showServicePriceTierFormDialog(
      context,
      serviceId: serviceId,
      tier: tier,
      existingTiers: allTiers,
    );
    if (result == true) {
      ref.invalidate(servicePriceTiersProvider(serviceId));
    }
  }

  void _deleteTier(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Price Tier'),
        content: const Text('Are you sure you want to delete this price tier?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final pb = ref.read(pocketbaseProvider);
        await pb
            .collection(PocketBaseCollections.servicePriceTiers)
            .delete(tier.id);
        ref.invalidate(servicePriceTiersProvider(serviceId));
        if (context.mounted) {
          showSuccessSnackBar(context, message: 'Tier deleted');
        }
      } catch (e) {
        if (context.mounted) {
          showErrorSnackBar(context, message: 'Failed to delete tier: $e');
        }
      }
    }
  }
}
