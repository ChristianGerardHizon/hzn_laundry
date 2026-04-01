import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/promo.dart';
import '../controllers/promo_provider.dart';
import '../controllers/promos_controller.dart';
import '../widgets/customer_promo_list.dart';
import '../widgets/promo_form_dialog.dart';

/// Promo detail page showing promo information and enrolled customers.
class PromoDetailPage extends HookConsumerWidget {
  const PromoDetailPage({
    super.key,
    required this.promoId,
  });

  final String promoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promoAsync = ref.watch(promoProvider(promoId));
    final isTablet = Breakpoints.isTabletOrLarger(context);

    return promoAsync.when(
      data: (promo) {
        if (promo == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Promo Not Found'),
              automaticallyImplyLeading: !isTablet,
            ),
            body: const Center(
              child: Text('The requested promo could not be found.'),
            ),
          );
        }

        return _PromoDetailContent(
          promo: promo,
          promoId: promoId,
          isTablet: isTablet,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !isTablet),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _PromoDetailContent extends ConsumerWidget {
  const _PromoDetailContent({
    required this.promo,
    required this.promoId,
    required this.isTablet,
  });

  final Promo promo;
  final String promoId;
  final bool isTablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y');

    return Scaffold(
      appBar: AppBar(
        title: Text(promo.name),
        automaticallyImplyLeading: !isTablet,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(promoProvider(promoId));
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
            onPressed: () => _showEditDialog(context, ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleMenuAction(context, ref, value, promo.id),
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
          // Promo info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Promo Information',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      _StatusChip(promo: promo),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Name', value: promo.name),
                  if (promo.description != null &&
                      promo.description!.isNotEmpty)
                    _InfoRow(
                      label: 'Description',
                      value: promo.description!,
                    ),
                  _InfoRow(
                    label: 'Start Date',
                    value: dateFormat.format(promo.startDate),
                  ),
                  _InfoRow(
                    label: 'End Date',
                    value: dateFormat.format(promo.endDate),
                  ),
                  _InfoRow(
                    label: 'Required Orders',
                    value: '${promo.requiredOrders}',
                  ),
                  _InfoRow(
                    label: 'Reward',
                    value: promo.rewardDisplay,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Enrolled customers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enrolled Customers',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  CustomerPromoList(promoId: promoId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) async {
    final currentPromo = ref.read(promoProvider(promoId)).value;
    if (currentPromo == null) return;

    final result = await showPromoFormDialog(
      context,
      promo: currentPromo,
    );

    if (result == true) {
      ref.invalidate(promoProvider(promoId));
      ref.read(promosControllerProvider.notifier).refresh();
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
          title: const Text('Delete Promo'),
          content: const Text('Are you sure you want to delete this promo?'),
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
            .read(promosControllerProvider.notifier)
            .deletePromo(id);
        if (success && context.mounted) {
          showSuccessSnackBar(context, message: 'Promo deleted');
          context.pop();
        } else if (context.mounted) {
          showErrorSnackBar(context, message: 'Failed to delete promo');
        }
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.promo});

  final Promo promo;

  @override
  Widget build(BuildContext context) {
    final isActive = promo.isCurrentlyActive;
    final theme = Theme.of(context);

    return Chip(
      label: Text(
        isActive ? 'Active' : (!promo.isActive ? 'Disabled' : 'Expired'),
        style: TextStyle(
          color: isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      backgroundColor: isActive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
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
            width: 130,
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
