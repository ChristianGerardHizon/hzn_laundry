import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/product.dart';
import '../product_image.dart';
import '../dialogs/edit_product_dialog.dart';
import '../dialogs/stock_adjustment_dialog.dart';

/// Details tab content showing comprehensive product information.
class ProductDetailsTab extends HookConsumerWidget {
  const ProductDetailsTab({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main product card with image and key info
          _buildProductCard(context, theme),
          const SizedBox(height: 16),

          // Product details section
          _buildProductDetailsSection(theme),
          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActions(context, theme),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Product Image
            _buildProductImage(context, theme, radius: 48),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceDisplay,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product.hasCategory) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.categoryName!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(
    BuildContext context,
    ThemeData theme, {
    double radius = 36,
  }) {
    return GestureDetector(
      onTap: product.hasImage ? () => _showImageViewer(context) : null,
      child: ProductImage(
        product: product,
        radius: radius,
      ),
    );
  }

  void _showImageViewer(BuildContext context) {
    if (!product.hasImage) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: product.image!,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton.filled(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsSection(ThemeData theme) {
    final items = <_DetailItem>[
      if (product.description != null && product.description!.isNotEmpty)
        _DetailItem(
          icon: Icons.description_outlined,
          label: 'Description',
          value: product.description!,
        ),
      _DetailItem(
        icon: Icons.storefront_outlined,
        label: 'For Sale',
        value: product.forSale ? 'Yes' : 'No',
      ),
      _DetailItem(
        icon: Icons.qr_code,
        label: 'Track by Lot',
        value: product.trackByLot ? 'Yes' : 'No',
      ),
      _DetailItem(
        icon: Icons.inventory_outlined,
        label: 'Require Stock',
        value: product.requireStock ? 'Yes' : 'No',
      ),
      if (product.expiration != null)
        _DetailItem(
          icon: Icons.event_outlined,
          label: 'Expiration Date',
          value: DateFormat('MMM d, yyyy').format(product.expiration!),
        ),
      if (product.created != null)
        _DetailItem(
          icon: Icons.access_time,
          label: 'Created',
          value: DateFormat('MMM d, yyyy').format(product.created!),
        ),
      if (product.updated != null)
        _DetailItem(
          icon: Icons.update,
          label: 'Last Updated',
          value: DateFormat('MMM d, yyyy').format(product.updated!),
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Product Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _buildDetailRow(item, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(_DetailItem item, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _showEditProductDialog(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Details'),
            ),
            if (product.trackStock && !product.trackByLot)
              FilledButton.tonalIcon(
                onPressed: () =>
                    showProductStockAdjustmentDialog(context, product),
                icon: const Icon(Icons.inventory),
                label: const Text('Adjust Stock'),
              ),
          ],
        ),
      ],
    );
  }

  void _showEditProductDialog(BuildContext context) {
    showEditProductDialog(context, product.id);
  }
}

class _DetailItem {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
