import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/foundation/sort_config.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/sort/sort_dialog.dart';
import '../../../pos/domain/sale.dart';
import '../controllers/paginated_sales_controller.dart';
import '../controllers/sale_search_controller.dart';
import '../controllers/sale_sort_controller.dart';
import 'sale_status_chip.dart';
import 'dialogs/sale_search_fields_dialog.dart';

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
    final activeFieldCount = searchFields.length;
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Text(t.navigation.salesHistory,
                    style: theme.textTheme.titleLarge),
                const Spacer(),
                Text(
                  '${paginatedState.totalItems} total',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isSearchActive
                ? _ActiveSearchChip(
                    query: paginatedController.currentSearchQuery ?? '',
                    fieldCount: activeFieldCount,
                    sortConfig: sortConfig,
                    onClear: clearSearch,
                    onSortPressed: () => _showSortDialog(context, ref),
                  )
                : _SearchInput(
                    controller: searchController,
                    fieldCount: activeFieldCount,
                    sortConfig: sortConfig,
                    onSearch: performSearch,
                    onTextChanged: (text) => searchText.value = text,
                    searchText: searchText.value,
                    onSortPressed: () => _showSortDialog(context, ref),
                  ),
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

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.receipt,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      sale.receiptNumber,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${sale.created != null ? dateFormat.format(sale.created!) : "Unknown"} • ${sale.isPaid ? 'Paid' : 'Unpaid'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currencyFormat.format(sale.totalAmount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SaleStatusChip(status: sale.status),
                      ],
                    ),
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer,
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

class _ActiveSearchChip extends StatelessWidget {
  const _ActiveSearchChip({
    required this.query,
    required this.fieldCount,
    required this.sortConfig,
    required this.onClear,
    required this.onSortPressed,
  });

  final String query;
  final int fieldCount;
  final SortConfig sortConfig;
  final VoidCallback onClear;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"$query"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (fieldCount > 1) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$fieldCount fields',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: Icon(
            sortConfig.descending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          onPressed: onSortPressed,
          tooltip: t.common.sort,
        ),
      ],
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.fieldCount,
    required this.sortConfig,
    required this.onSearch,
    required this.onTextChanged,
    required this.searchText,
    required this.onSortPressed,
  });

  final TextEditingController controller;
  final int fieldCount;
  final SortConfig sortConfig;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final String searchText;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '${t.common.search}...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onTextChanged('');
                      },
                      tooltip: t.common.cancel,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: Icon(
            sortConfig.descending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          onPressed: onSortPressed,
          tooltip: t.common.sort,
        ),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: fieldCount > 1,
          label: Text('$fieldCount'),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => showSaleSearchFieldsDialog(context),
            tooltip: t.common.filter,
          ),
        ),
      ],
    );
  }
}
