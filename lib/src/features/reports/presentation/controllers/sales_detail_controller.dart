import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'sales_detail_date_range_controller.dart';

part 'sales_detail_controller.g.dart';

/// Paginated orders for the Orders report tab.
@riverpod
class SalesDetailController extends _$SalesDetailController {
  SalesRepository get _repository => ref.read(salesRepositoryProvider);

  String? _searchQuery;
  List<String>? _searchFields;

  String? get _baseFilter {
    final dateRange = ref.read(salesDetailDateRangeControllerProvider);
    final branchScope = PBFilters.forBranchOrOrganization(
      branchId: ref.read(currentBranchIdProvider),
      organizationId: ref.read(currentOrganizationIdProvider),
    );
    final dateFilter = PBFilter()
        .notEquals('status', 'voided')
        .between('postedDate', dateRange.start, dateRange.end)
        .build();
    return PBFilters.combine(dateFilter, branchScope);
  }

  static String? _mapSearchField(String key) => switch (key) {
        'customer' => 'customerName',
        'receipt' => 'receiptNumber',
        'amount' => 'totalAmount',
        'status' => 'status',
        'orderStatus' => 'orderStatus',
        _ => null,
      };

  @override
  Future<PaginatedState<Sale>> build() async {
    _searchQuery = null;
    _searchFields = null;

    ref.watch(salesDetailDateRangeControllerProvider);
    ref.watch(currentBranchIdProvider);
    ref.watch(currentOrganizationIdProvider);

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.defaultPageSize,
      filter: _baseFilter,
      sort: '-postedDate',
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

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedEnd) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    final nextPage = currentState.currentPage + 1;

    final result = _searchQuery != null
        ? await _repository.searchPaginated(
            _searchQuery!,
            fields: _searchFields,
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            sort: '-postedDate',
            filter: _baseFilter,
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            filter: _baseFilter,
            sort: '-postedDate',
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

  Future<void> search(String query, {required List<String> fields}) async {
    if (query.trim().isEmpty) {
      return clearSearch();
    }

    _searchQuery = query.trim();
    _searchFields = fields
        .map(_mapSearchField)
        .whereType<String>()
        .toList();
    state = const AsyncValue.loading();

    final result = await _repository.searchPaginated(
      _searchQuery!,
      fields: _searchFields,
      page: 1,
      perPage: Pagination.defaultPageSize,
      sort: '-postedDate',
      filter: _baseFilter,
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

  Future<void> clearSearch() async {
    if (_searchQuery == null) return;
    _searchQuery = null;
    _searchFields = null;
    ref.invalidateSelf();
  }
}
