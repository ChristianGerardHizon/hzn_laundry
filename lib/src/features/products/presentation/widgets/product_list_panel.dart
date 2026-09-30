import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';

import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/products.routes.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/list/list.dart';
import '../../../../core/widgets/sort/sort_dialog.dart';
import '../../domain/product.dart';
import '../controllers/paginated_products_controller.dart';
import '../controllers/product_search_controller.dart';
import '../controllers/product_sort_controller.dart';
import 'product_image.dart';
import 'product_stock_badge.dart';
import 'dialogs/create_product_dialog.dart';
import 'dialogs/product_search_fields_dialog.dart';

/// Product list panel with search header and infinite scroll.
///
/// Used in both mobile list page and tablet two-pane layout.
class ProductListPanel extends HookConsumerWidget {
  const ProductListPanel({
    super.key,
    required this.products,
    required this.totalCount,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<Product> products;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);

    // Local state using hooks
    final searchController = useTextEditingController();
    final searchText = useState('');

    // Watch providers
    final searchFields = ref.watch(productSearchFieldsProvider);
    final activeFieldCount = searchFields.length;
    final paginatedController =
        ref.read(paginatedProductsControllerProvider.notifier);
    final sortConfig = ref.watch(productSortControllerProvider);

    // Search is active from the controller
    final isSearchActive = paginatedController.isSearchActive;

    // Get selected product ID from current route
    final routerState = GoRouterState.of(context);
    final selectedProductId = routerState.pathParameters['id'];

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) return;

      final fields = ref.read(productSearchFieldsProvider).toList();
      paginatedController.search(query, fields: fields);
    }

    void clearSearch() {
      searchController.clear();
      searchText.value = '';
      ref.read(productSearchFieldsProvider.notifier).reset();
      paginatedController.clearSearch();
    }

    // Infinite scroll hook
    final scrollController = useInfiniteScroll(
      onLoadMore: () => paginatedController.loadMore(),
      hasMore: hasMore,
      isLoading: isLoadingMore,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateProductDialog(context),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          ListPanelHeader(
            title: t.navigation.products,
            count: totalCount,
          ),

          ListToolbar(
            controller: searchController,
            onSearch: performSearch,
            onTextChanged: (text) => searchText.value = text,
            activeQuery: isSearchActive
                ? paginatedController.currentSearchQuery ?? ''
                : null,
            onClear: clearSearch,
            filterCount: activeFieldCount > 1 ? activeFieldCount : 0,
            onFilterPressed: () => showProductSearchFieldsDialog(context),
            sortDescending: sortConfig.descending,
            onSortPressed: () => _showSortDialog(context, ref),
          ),

          // Product list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => paginatedController.refresh(),
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // +1 for the end indicator
                itemCount: products.length + 1,
                itemBuilder: (context, index) {
                  // Last item is the end indicator
                  if (index == products.length) {
                    return EndOfListIndicator(
                      isLoadingMore: isLoadingMore,
                      hasReachedEnd: !hasMore,
                    );
                  }

                  final product = products[index];
                  final isSelected = product.id == selectedProductId;

                  return AppListRow(
                    isSelected: isSelected,
                    leading: ProductImage(product: product),
                    title: Text(product.name),
                    subtitle: Text(
                      [
                        product.priceDisplay,
                        if (product.categoryName != null) product.categoryName!,
                      ].join(' • '),
                    ),
                    trailing: ProductStockBadge(
                      status: product.stockStatus,
                      showLabel: false,
                    ),
                    onTap: () => ProductDetailRoute(id: product.id).goScoped(context),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showSortDialog(BuildContext context, WidgetRef ref) {
  final t = Translations.of(context);
  final currentSort = ref.read(productSortControllerProvider);

  // Build localized field labels
  final localizedFields = productSortableFields.map((field) {
    final label = switch (field.key) {
      'name' => t.fields.name,
      'price' => t.sort.price,
      'quantity' => t.sort.stock,
      'created' => t.sort.dateAdded,
      'updated' => t.sort.lastUpdated,
      'expiration' => t.sort.expiration,
      _ => field.label,
    };
    return (key: field.key, label: label);
  }).toList();

  showSortDialog(
    context: context,
    title: t.sort.sortBy,
    fields: localizedFields,
    currentSort: currentSort,
    defaultSort: productDefaultSort,
    onSortChanged: (config) {
      ref.read(productSortControllerProvider.notifier).setSort(config);
    },
  );
}
