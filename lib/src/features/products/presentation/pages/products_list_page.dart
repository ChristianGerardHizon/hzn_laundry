import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../controllers/paginated_products_controller.dart';
import '../widgets/product_list_panel.dart';

/// Products list page for mobile view.
class ProductsListPage extends ConsumerWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(paginatedProductsControllerProvider);

    return productsAsync.when(
      data: (state) => ProductListPanel(
        products: state.items,
        totalCount: state.totalItems,
        hasMore: state.hasMore,
        isLoadingMore: state.isLoadingMore,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(
        error,
        onRetry: () =>
                  ref.invalidate(paginatedProductsControllerProvider),
      )
    );
  }
}
