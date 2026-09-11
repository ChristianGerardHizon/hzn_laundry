import 'package:flutter/material.dart';

import '../../../products/domain/product.dart';
import '../../../services/domain/service_consumable_recipe.dart';

/// In-progress usage line on Create Order / order detail.
class OrderUsageDraft {
  OrderUsageDraft({
    required this.product,
    required this.prefill,
    this.quantity,
  });

  final Product product;
  final bool prefill;
  num? quantity;

  bool get isMissing => !prefill && quantity == null;

  num get displayQuantity => quantity ?? 0;
}

List<OrderUsageDraft> draftsFromRecipes(
  List<ServiceConsumableRecipe> recipes,
) {
  return [
    for (final recipe in recipes)
      if (recipe.product != null)
        OrderUsageDraft(
          product: recipe.product!,
          prefill: recipe.prefill,
          quantity: recipe.prefill
              ? (recipe.defaultQuantity < 0 ? 0 : recipe.defaultQuantity)
              : null,
        ),
  ];
}

class OrderUsageSection extends StatelessWidget {
  const OrderUsageSection({
    super.key,
    required this.drafts,
    required this.enabled,
    required this.canEdit,
    required this.showCost,
    required this.onChanged,
    this.onCopyLast,
    this.copyLastEnabled = false,
    this.showHeader = true,
  });

  final List<OrderUsageDraft> drafts;
  final bool enabled;
  final bool canEdit;
  final bool showCost;
  final VoidCallback onChanged;
  final VoidCallback? onCopyLast;
  final bool copyLastEnabled;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (drafts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Consumables used',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onCopyLast != null)
                TextButton(
                  onPressed: enabled && copyLastEnabled ? onCopyLast : null,
                  child: const Text('Copy last recipe'),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ...drafts.map(
          (draft) => _UsageStepperRow(
            draft: draft,
            enabled: enabled && canEdit,
            showCost: showCost,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _UsageStepperRow extends StatelessWidget {
  const _UsageStepperRow({
    required this.draft,
    required this.enabled,
    required this.showCost,
    required this.onChanged,
  });

  final OrderUsageDraft draft;
  final bool enabled;
  final bool showCost;
  final VoidCallback onChanged;

  void _setQuantity(num? value) {
    if (value == null) {
      draft.quantity = draft.prefill ? draft.product.effectiveUsageMin : null;
      onChanged();
      return;
    }
    var next = value;
    if (next < draft.product.effectiveUsageMin) {
      next = draft.product.effectiveUsageMin;
    }
    final max = draft.product.usageMax;
    if (max != null && max > 0 && next > max) next = max;
    draft.quantity = next;
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = draft.product;
    final unit = product.quantityUnit?.shortPlural ?? '';
    final missing = draft.isMissing;
    final qtyLabel = draft.quantity == null
        ? (missing ? 'Required' : '0')
        : '${draft.quantity}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  missing
                      ? 'Enter amount ($unit)'
                      : (unit.isEmpty ? 'Usage' : unit),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: missing
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (showCost && draft.quantity != null)
                  Text(
                    '₱${(draft.quantity! * product.unitCost).toStringAsFixed(2)}',
                    style: theme.textTheme.labelSmall,
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: missing
                    ? theme.colorScheme.error
                    : theme.colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: enabled
                      ? () => _setQuantity(
                            (draft.quantity ?? 0) - product.effectiveUsageStep,
                          )
                      : null,
                  icon: const Icon(Icons.remove, size: 18),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 40),
                  child: Text(
                    qtyLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: enabled
                      ? () => _setQuantity(
                            (draft.quantity ?? product.effectiveUsageMin) +
                                product.effectiveUsageStep,
                          )
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
