import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'sale_search_controller.dart';
import 'sale_sort_controller.dart';

part 'paginated_sales_controller.g.dart';

/// Controller for managing paginated sales list.
@Riverpod(keepAlive: true)
class PaginatedSalesController extends _$PaginatedSalesController {
  SalesRepository get _repository => ref.read(salesRepositoryProvider);

  // Track current search state
  String? _currentSearchQuery;
  List<String>? _currentSearchFields;

  /// Gets the current sort string from the sort controller.
  String get _currentSort =>
      ref.read(saleSortControllerProvider).toSortString();

  /// Gets the current branch filter.
  String? get _branchFilter => ref.read(currentBranchFilterProvider);

  /// Combines branch + payment filters for list queries.
  String? get _listFilter => PBFilters.combine(
        _branchFilter,
        ref.read(salePaymentFiltersControllerProvider).toPbFilter(),
      );

  @override
  Future<PaginatedState<Sale>> build() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;

    // Listen to sort changes and refresh
    ref.listen(saleSortControllerProvider, (_, __) {
      refresh();
    });

    // Listen to payment filters and refresh (don't watch — avoids clearing search)
    ref.listen(salePaymentFiltersControllerProvider, (_, __) {
      refresh();
    });

    final branchFilter = ref.watch(currentBranchFilterProvider);
    final paymentFilter =
        ref.read(salePaymentFiltersControllerProvider).toPbFilter();
    final filter = PBFilters.combine(branchFilter, paymentFilter);

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.defaultPageSize,
      sort: _currentSort,
      filter: filter,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) => PaginatedState<Sale>(
        items: paginated.items,
        currentPage: paginated.page,
        totalItems: paginated.totalItems,
        totalPages: paginated.totalPages,
        hasReachedEnd: !paginated.hasMore,
      ),
    );
  }

  /// Whether search is currently active.
  bool get isSearchActive => _currentSearchQuery != null;

  /// The current search query, if any.
  String? get currentSearchQuery => _currentSearchQuery;

  /// Loads the next page.
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedEnd) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    // Use search or regular fetch based on current state
    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
            filter: _listFilter,
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
            filter: _listFilter,
          );

    result.fold(
      (failure) {
        state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      },
      (paginated) {
        state = AsyncValue.data(
          currentState.appendItems(
            paginated.items,
            page: paginated.page,
            totalItems: paginated.totalItems,
            totalPages: paginated.totalPages,
          ),
        );
      },
    );
  }

  /// Refreshes the list (respects current search, sort, and filters).
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: 1,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
            filter: _listFilter,
          )
        : await _repository.fetchPaginated(
            page: 1,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
            filter: _listFilter,
          );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(PaginatedState<Sale>(
        items: paginated.items,
        currentPage: paginated.page,
        totalItems: paginated.totalItems,
        totalPages: paginated.totalPages,
        hasReachedEnd: !paginated.hasMore,
      )),
    );
  }

  /// Searches sales (resets to page 1).
  Future<void> search(String query, {List<String>? fields}) async {
    if (query.isEmpty) {
      return clearSearch();
    }

    _currentSearchQuery = query;
    _currentSearchFields = fields;

    state = const AsyncValue.loading();

    final result = await _repository.searchPaginated(
      query,
      fields: fields,
      page: 1,
      perPage: Pagination.defaultPageSize,
      sort: _currentSort,
      filter: _listFilter,
    );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(PaginatedState<Sale>(
        items: paginated.items,
        currentPage: paginated.page,
        totalItems: paginated.totalItems,
        totalPages: paginated.totalPages,
        hasReachedEnd: !paginated.hasMore,
      )),
    );
  }

  /// Clears search and reloads all sales.
  Future<void> clearSearch() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;
    return refresh();
  }
}
