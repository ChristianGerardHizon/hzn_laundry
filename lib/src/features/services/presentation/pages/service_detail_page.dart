import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../controllers/service_provider.dart';
import '../controllers/services_controller.dart';
import '../widgets/service_form_sheet.dart';

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
