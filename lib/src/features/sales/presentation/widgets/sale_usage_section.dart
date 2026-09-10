import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/nav_permissions.dart';
import '../../../pos/data/repositories/sale_consumable_usage_repository.dart';
import '../../../pos/domain/sale_consumable_usage.dart';
import '../../../products/domain/product.dart';
import '../../../settings/data/repositories/feature_flag_repository.dart';
import '../../../users/domain/user_role.dart';
import '../controllers/sale_consumable_usages_provider.dart';
import 'order_usage_section.dart';

/// Order-detail consumable usage. Shown when the org flag is on and the
/// user can view usage. Editing is allowed at any order status with
/// `usage.edit`.
class SaleUsageSection extends HookConsumerWidget {
  const SaleUsageSection({
    super.key,
    required this.saleId,
    this.compact = false,
  });

  final String saleId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageEnabled =
        ref.watch(consumableUsageEnabledProvider).value ?? false;
    final role = ref.watch(currentUserRoleProvider).value;
    final canView = role != null &&
        (role.isAdmin || role.hasPermission(Permissions.usageView));
    final canEdit = role != null &&
        (role.isAdmin || role.hasPermission(Permissions.usageEdit));
    final showCost = role != null &&
        (role.isAdmin || role.hasPermission(Permissions.usageCostView));

    if (!usageEnabled || !canView) {
      return const SizedBox.shrink();
    }

    final usagesAsync = ref.watch(saleConsumableUsagesProvider(saleId));
    final drafts = useState<List<OrderUsageDraft>>([]);
    final records = useState<List<SaleConsumableUsage>>([]);
    final hydratedSaleId = useRef<String?>(null);
    final isSaving = useState(false);

    useEffect(() {
      final usages = usagesAsync.asData?.value;
      if (usages == null) return null;
      if (hydratedSaleId.value == saleId && drafts.value.isNotEmpty) {
        return null;
      }
      records.value = usages;
      drafts.value = [
        for (final usage in usages)
          OrderUsageDraft(
            product: usage.product ??
                Product(
                  id: usage.productId,
                  name: usage.productName,
                  unitCost: usage.unitCost,
                ),
            prefill: true,
            quantity: usage.quantity,
          ),
      ];
      hydratedSaleId.value = saleId;
      return null;
    }, [saleId, usagesAsync]);

    Future<void> persist(int index) async {
      if (index < 0 || index >= records.value.length) return;
      final draft = drafts.value[index];
      final existing = records.value[index];
      final qty = draft.quantity ?? 0;
      isSaving.value = true;
      final result = await ref
          .read(saleConsumableUsageRepositoryProvider)
          .update(existing.copyWith(
            quantity: qty,
            cost: existing.unitCost * qty,
          ));
      isSaving.value = false;
      if (!context.mounted) return;
      result.fold(
        (failure) => showErrorSnackBar(
          context,
          message: failure.messageString,
        ),
        (updated) {
          final next = [...records.value];
          next[index] = updated;
          records.value = next;
          ref.invalidate(saleConsumableUsagesProvider(saleId));
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 12 : 16),
      child: usagesAsync.when(
        loading: () => const Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (error, _) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading usage: $error'),
          ),
        ),
        data: (usages) {
          if (usages.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consumables used',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No consumables recorded'),
                  ),
                ),
              ],
            );
          }

          return Card(
            child: Padding(
              padding: EdgeInsets.all(compact ? 12 : 16),
              child: OrderUsageSection(
                drafts: drafts.value,
                enabled: !isSaving.value,
                canEdit: canEdit,
                showCost: showCost,
                onChanged: () {
                  drafts.value = [...drafts.value];
                  // Persist the row whose quantity most recently changed.
                  for (var i = 0; i < drafts.value.length; i++) {
                    if (i >= records.value.length) continue;
                    if (drafts.value[i].quantity != records.value[i].quantity) {
                      persist(i);
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
