import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/widgets/list/list.dart';
import '../../../../core/widgets/state/empty_state.dart';
import '../../../products/domain/product_category.dart';
import '../controllers/product_categories_controller.dart';

/// List panel for product categories in tablet two-pane layout.
class ProductCategoryListPanel extends HookConsumerWidget {
  const ProductCategoryListPanel({
    super.key,
    this.selectedId,
  });

  /// Currently selected category ID for highlighting.
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);
    final controller = ref.read(productCategoriesControllerProvider.notifier);

    // Search state
    final searchController = useTextEditingController();
    final appliedQuery = useState('');

    final isSearchActive = appliedQuery.value.isNotEmpty;

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) return;
      appliedQuery.value = query;
    }

    void clearSearch() {
      searchController.clear();
      appliedQuery.value = '';
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_category_fab',
        tooltip: 'Add category',
        onPressed: () =>
            const ProductCategoryDetailRoute(id: 'new').goScoped(context),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState.fromError(
          error,
          onRetry: () => controller.refresh(),
        ),
        data: (categories) {
          final filteredCategories = isSearchActive
              ? _filterCategories(categories, appliedQuery.value)
              : categories;

          // Build hierarchical display
          final rootCategories =
              filteredCategories.where((c) => !c.hasParent).toList();
          final childCategories =
              filteredCategories.where((c) => c.hasParent).toList();

          return Column(
            children: [
              ListPanelHeader(
                title: 'Categories',
                count: filteredCategories.length,
              ),
              ListToolbar(
                controller: searchController,
                onSearch: performSearch,
                onTextChanged: (_) {},
                activeQuery: isSearchActive ? appliedQuery.value : null,
                onClear: clearSearch,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: filteredCategories.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.4,
                              child: EmptyState(
                                icon: Icons.inventory_2_outlined,
                                iconSize: 56,
                                title: isSearchActive
                                    ? 'No categories match "${appliedQuery.value}"'
                                    : 'No categories yet',
                                subtitle: isSearchActive
                                    ? 'Try a different search term'
                                    : 'Tap + to add a category',
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 88),
                          itemCount: rootCategories.length,
                          itemBuilder: (context, index) {
                            final category = rootCategories[index];
                            final children = childCategories
                                .where((c) => c.parentId == category.id)
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CategoryListTile(
                                  category: category,
                                  isSelected: category.id == selectedId,
                                  isChild: false,
                                  onTap: () =>
                                      ProductCategoryDetailRoute(id: category.id)
                                          .goScoped(context),
                                ),
                                // Show children with indentation
                                ...children.map((child) => Padding(
                                      padding: const EdgeInsets.only(left: 24),
                                      child: _CategoryListTile(
                                        category: child,
                                        isSelected: child.id == selectedId,
                                        isChild: true,
                                        onTap: () => ProductCategoryDetailRoute(
                                                id: child.id)
                                            .goScoped(context),
                                      ),
                                    )),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    required this.category,
    required this.isSelected,
    required this.isChild,
    required this.onTap,
  });

  final ProductCategory category;
  final bool isSelected;
  final bool isChild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppListRow(
      isSelected: isSelected,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor:
            isChild ? scheme.secondaryContainer : scheme.primaryContainer,
        child: Icon(
          isChild ? Icons.subdirectory_arrow_right : Icons.inventory_2_outlined,
          color: isChild
              ? scheme.onSecondaryContainer
              : scheme.onPrimaryContainer,
        ),
      ),
      title: Text(category.name),
      subtitle: category.hasParent && category.parentName != null
          ? Text('Parent: ${category.parentName}')
          : null,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

List<ProductCategory> _filterCategories(
    List<ProductCategory> categories, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return categories;
  }

  return categories.where((c) {
    final nameMatch = c.name.toLowerCase().contains(normalizedQuery);
    final parentMatch =
        c.parentName?.toLowerCase().contains(normalizedQuery) ?? false;
    return nameMatch || parentMatch;
  }).toList();
}
