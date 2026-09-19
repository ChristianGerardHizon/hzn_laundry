import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';
import 'package:hzn_laundry/src/core/widgets/state/error_state.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../controllers/paginated_sales_controller.dart';
import '../widgets/sale_list_panel.dart';

/// Sales list page for mobile view.
///
/// Shows the sales list panel and navigates to detail on tap.
class SalesListPage extends ConsumerWidget {
  const SalesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedAsync = ref.watch(paginatedSalesControllerProvider);

    return paginatedAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: ErrorState.fromError(
          error,
          onRetry: () => ref
                    .read(paginatedSalesControllerProvider.notifier)
                    .refresh(),
        ),
      ),
      data: (paginatedState) => SaleListPanel(
        paginatedState: paginatedState,
        selectedId: null,
        onSaleTap: (sale) {
          SaleDetailRoute(id: sale.id).pushScoped(context);
        },
        onRefresh: () =>
            ref.read(paginatedSalesControllerProvider.notifier).refresh(),
        onLoadMore: () =>
            ref.read(paginatedSalesControllerProvider.notifier).loadMore(),
      ),
    );
  }
}
