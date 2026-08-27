import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/product.dart';
import '../../../domain/product_adjustment.dart';
import '../../controllers/product_adjustments_controller.dart';
import '../product_adjustment_tile.dart';

/// Adjustments tab for product detail page.
///
/// Shows the history of stock adjustments for the product.
class ProductAdjustmentsTab extends ConsumerWidget {
  const ProductAdjustmentsTab({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adjustmentsAsync =
        ref.watch(productAdjustmentsControllerProvider(product.id));

    return adjustmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref
                  .read(productAdjustmentsControllerProvider(product.id)
                      .notifier)
                  .refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (adjustments) {
        if (adjustments.isEmpty) {
          return const _EmptyAdjustmentsState();
        }

        return _AdjustmentsListContent(
          productId: product.id,
          adjustments: adjustments,
        );
      },
    );
  }
}

class _EmptyAdjustmentsState extends StatelessWidget {
  const _EmptyAdjustmentsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Adjustments',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Stock adjustment history will appear here when you adjust the product\'s inventory.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentsListContent extends ConsumerWidget {
  const _AdjustmentsListContent({
    required this.productId,
    required this.adjustments,
  });

  final String productId;
  final List<ProductAdjustment> adjustments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate totals
    final totalIncrease = adjustments
        .where((a) => a.isIncrease)
        .fold<num>(0, (sum, a) => sum + a.delta);
    final totalDecrease = adjustments
        .where((a) => a.isDecrease)
        .fold<num>(0, (sum, a) => sum + a.delta.abs());

    return Column(
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.history,
                  label: 'Total',
                  value: adjustments.length.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.add,
                  label: 'Added',
                  value: '+${totalIncrease.toStringAsFixed(0)}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.remove,
                  label: 'Removed',
                  value: '-${totalDecrease.toStringAsFixed(0)}',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Adjustments list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(productAdjustmentsControllerProvider(productId).notifier)
                .refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: adjustments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final adjustment = adjustments[index];
                return ProductAdjustmentTile(adjustment: adjustment);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: displayColor, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: displayColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
