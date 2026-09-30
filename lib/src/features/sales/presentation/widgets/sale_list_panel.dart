import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/list/list.dart';
import '../../../../core/widgets/sort/sort_dialog.dart';
import '../../../pos/domain/payment_status.dart';
import '../../../pos/domain/sale.dart';
import '../controllers/paginated_sales_controller.dart';
import '../controllers/sale_search_controller.dart';
import '../controllers/sale_sort_controller.dart';
import 'sale_status_chip.dart';
import 'dialogs/sale_search_fields_dialog.dart';

/// Extracts a short display order number from the full receipt number.
/// e.g. "S-260401-X7KP" → "#X7KP"
String _shortOrderNumber(String receiptNumber) {
  final parts = receiptNumber.split('-');
  if (parts.length >= 3) return '#${parts.last}';
  if (receiptNumber.length > 4) {
    return '#${receiptNumber.substring(receiptNumber.length - 4)}';
  }
  return receiptNumber;
}

/// Sale list panel with search header and infinite scroll.
///
/// Used in both mobile list page and tablet two-pane layout.
class SaleListPanel extends HookConsumerWidget {
  const SaleListPanel({
    super.key,
    required this.paginatedState,
    required this.selectedId,
    required this.onSaleTap,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final PaginatedState<Sale> paginatedState;
  final String? selectedId;
  final ValueChanged<Sale> onSaleTap;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Local state using hooks
    final searchController = useTextEditingController();
    final searchText = useState('');

    // Watch providers
    final searchFields = ref.watch(saleSearchFieldsProvider);
    final paymentFilters = ref.watch(salePaymentFiltersControllerProvider);
    final activeFieldCount = searchFields.length + paymentFilters.activeCount;
    final paginatedController =
        ref.read(paginatedSalesControllerProvider.notifier);
    final sortConfig = ref.watch(saleSortControllerProvider);

    // Search is active from the controller
    final isSearchActive = paginatedController.isSearchActive;

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) return;

      final fields = ref.read(saleSearchFieldsProvider).toList();
      paginatedController.search(query, fields: fields);
    }

    void clearSearch() {
      searchController.clear();
      searchText.value = '';
      ref.read(saleSearchFieldsProvider.notifier).reset();
      ref.read(salePaymentFiltersControllerProvider.notifier).reset();
      paginatedController.clearSearch();
    }

    // Infinite scroll hook
    final scrollController = useInfiniteScroll(
      onLoadMore: onLoadMore,
      hasMore: !paginatedState.hasReachedEnd,
      isLoading: paginatedState.isLoadingMore,
    );

    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      body: Column(
        children: [
          ListPanelHeader(
            title: t.navigation.salesHistory,
            count: paginatedState.totalItems,
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
            onFilterPressed: () => showSaleSearchFieldsDialog(context),
            sortDescending: sortConfig.descending,
            onSortPressed: () => _showSortDialog(context, ref),
          ),

          // Sales list
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // +1 for the end indicator
                itemCount: paginatedState.items.length + 1,
                itemBuilder: (context, index) {
                  // Last item is the end indicator
                  if (index == paginatedState.items.length) {
                    return EndOfListIndicator(
                      isLoadingMore: paginatedState.isLoadingMore,
                      hasReachedEnd: paginatedState.hasReachedEnd,
                    );
                  }

                  final sale = paginatedState.items[index];
                  final isSelected = sale.id == selectedId;

                  final paymentColor = sale.paymentStatus == PaymentStatus.paid
                      ? Colors.green
                      : Colors.amber;

                  // Amount + payment chip on the right; order status moves into
                  // the subtitle so the trailing column stays narrow on phones.
                  return AppListRow(
                    isSelected: isSelected,
                    title: Text(
                      sale.customerDisplay ?? _shortOrderNumber(sale.receiptNumber),
                    ),
                    subtitle: Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${_shortOrderNumber(sale.receiptNumber)} • ${sale.postedDate != null ? dateFormat.format(sale.postedDate!) : "Unknown"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SaleStatusChip(status: sale.status),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(sale.totalAmount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RowChip(
                          label: sale.paymentStatus.displayName,
                          color: paymentColor,
                        ),
                      ],
                    ),
                    onTap: () => onSaleTap(sale),
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
  final currentSort = ref.read(saleSortControllerProvider);

  // Build localized field labels
  final localizedFields = saleSortableFields.map((field) {
    final label = switch (field.key) {
      'created' => t.sort.date,
      'totalAmount' => t.sort.amount,
      'receiptNumber' => t.fields.receiptNumber,
      'customerName' => t.fields.customerName,
      _ => field.label,
    };
    return (key: field.key, label: label);
  }).toList();

  showSortDialog(
    context: context,
    title: t.sort.sortBy,
    fields: localizedFields,
    currentSort: currentSort,
    defaultSort: saleDefaultSort,
    onSortChanged: (config) {
      ref.read(saleSortControllerProvider.notifier).setSort(config);
    },
  );
}
