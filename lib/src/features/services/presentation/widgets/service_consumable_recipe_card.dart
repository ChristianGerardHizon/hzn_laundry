import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/domain/product.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/service_consumable_recipe_repository.dart';
import '../../domain/service_consumable_recipe.dart';
import '../controllers/service_consumable_recipes_provider.dart';

class ServiceConsumableRecipeCard extends ConsumerWidget {
  const ServiceConsumableRecipeCard({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(serviceConsumableRecipesProvider(serviceId));
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: recipesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading recipes: $e'),
          data: (recipes) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Consumable recipe',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add consumable',
                      onPressed: () => _showAddDialog(context, ref, recipes),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Defaults used when creating an order for this service.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (recipes.isEmpty)
                  Text(
                    'No consumables on this service yet.',
                    style: theme.textTheme.bodySmall,
                  )
                else
                  ...recipes.map(
                    (recipe) => _RecipeRow(
                      recipe: recipe,
                      onChanged: () => ref.invalidate(
                        serviceConsumableRecipesProvider(serviceId),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    List<ServiceConsumableRecipe> existing,
  ) async {
    final existingIds = existing.map((r) => r.productId).toSet();
    final branchFilter = ref.read(currentBranchFilterProvider);
    final result = await ref.read(productRepositoryProvider).fetchAll(
          filter: PBFilters.combine(
            branchFilter,
            'isDeleted = false && isConsumable = true',
          ),
          sort: 'name',
        );

    if (!context.mounted) return;
    final products = result.fold(
      (f) {
        showErrorSnackBar(context, message: f.messageString);
        return <Product>[];
      },
      (list) => list.where((p) => !existingIds.contains(p.id)).toList(),
    );
    if (products.isEmpty) {
      showInfoSnackBar(
        context,
        message: 'No unused consumable products for this branch.',
      );
      return;
    }

    Product? selected = products.first;
    final qtyController = TextEditingController(
      text: '${selected.effectiveDefaultUsage}',
    );
    var prefill = true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add consumable'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Product>(
                initialValue: selected,
                items: products
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name),
                      ),
                    )
                    .toList(),
                onChanged: (p) {
                  if (p == null) return;
                  setState(() {
                    selected = p;
                    qtyController.text = '${p.effectiveDefaultUsage}';
                  });
                },
                decoration: const InputDecoration(labelText: 'Product'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Default quantity'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Prefill on create order'),
                subtitle: const Text('Off = staff must enter a value'),
                value: prefill,
                onChanged: (v) => setState(() => prefill = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || selected == null || !context.mounted) return;
    final qty = num.tryParse(qtyController.text) ?? 0;
    final createResult =
        await ref.read(serviceConsumableRecipeRepositoryProvider).create(
              ServiceConsumableRecipe(
                id: '',
                serviceId: serviceId,
                productId: selected!.id,
                defaultQuantity: qty < 0 ? 0 : qty,
                prefill: prefill,
              ),
            );
    createResult.fold(
      (f) => showErrorSnackBar(context, message: f.messageString),
      (_) => ref.invalidate(serviceConsumableRecipesProvider(serviceId)),
    );
  }
}

class _RecipeRow extends ConsumerWidget {
  const _RecipeRow({required this.recipe, required this.onChanged});

  final ServiceConsumableRecipe recipe;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = recipe.product?.name ?? recipe.productId;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Text(
        'Default ${recipe.defaultQuantity}'
        '${recipe.prefill ? ' · prefill' : ' · staff must enter'}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final result = await ref
              .read(serviceConsumableRecipeRepositoryProvider)
              .delete(recipe.id);
          result.fold(
            (f) => showErrorSnackBar(context, message: f.messageString),
            (_) => onChanged(),
          );
        },
      ),
    );
  }
}
