import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/customer_promo.dart';
import '../controllers/redeemable_promos_provider.dart';

/// Section widget for the create order dialog showing redeemable loyalty rewards.
///
/// Displays available rewards for the selected customer and allows
/// staff to select one to apply as a discount.
class LoyaltyRewardsSection extends ConsumerWidget {
  const LoyaltyRewardsSection({
    super.key,
    required this.customerId,
    required this.selectedPromo,
    required this.onPromoSelected,
    required this.enabled,
  });

  final String customerId;
  final CustomerPromo? selectedPromo;
  final ValueChanged<CustomerPromo?> onPromoSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redeemableAsync = ref.watch(redeemablePromosProvider(customerId));
    final theme = Theme.of(context);

    return redeemableAsync.when(
      data: (promos) {
        if (promos.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Loyalty Rewards Available',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...promos.map((cp) => _RewardTile(
                  customerPromo: cp,
                  isSelected: selectedPromo?.id == cp.id,
                  enabled: enabled,
                  onTap: () {
                    if (selectedPromo?.id == cp.id) {
                      onPromoSelected(null);
                    } else {
                      onPromoSelected(cp);
                    }
                  },
                )),
            const SizedBox(height: 8),
          ],
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Checking loyalty rewards...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.customerPromo,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final CustomerPromo customerPromo;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final promo = customerPromo.promo;
    if (promo == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      promo.rewardDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Applied',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
