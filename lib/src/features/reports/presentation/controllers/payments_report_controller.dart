import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../pos/data/repositories/payment_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/payment_report_entry.dart';
import 'payments_date_range_controller.dart';

part 'payments_report_controller.g.dart';

/// Paginated payments within the selected report date range.
@riverpod
class PaymentsReportController extends _$PaymentsReportController {
  PaymentRepository get _repository => ref.read(paymentRepositoryProvider);

  String? _searchQuery;
  List<String>? _searchFields;

  String? get _branchScope => PBFilters.forBranchOrOrganization(
        branchId: ref.read(currentBranchIdProvider),
        organizationId: ref.read(currentOrganizationIdProvider),
        branchField: 'sale.branch',
      );

  @override
  Future<PaginatedState<PaymentReportEntry>> build() async {
    _searchQuery = null;
    _searchFields = null;

    final dateRange = ref.watch(paymentsDateRangeControllerProvider);
    ref.watch(currentBranchIdProvider);
    ref.watch(currentOrganizationIdProvider);

    final result = await _repository.getForDateRangePaginated(
      startDate: dateRange.start,
      endDate: dateRange.end,
      branchScope: _branchScope,
      page: 1,
      perPage: Pagination.defaultPageSize,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) => PaginatedState<PaymentReportEntry>(
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

    final dateRange = ref.read(paymentsDateRangeControllerProvider);
    final nextPage = currentState.currentPage + 1;

    final result = await _repository.getForDateRangePaginated(
      startDate: dateRange.start,
      endDate: dateRange.end,
      branchScope: _branchScope,
      searchQuery: _searchQuery,
      searchFields: _searchFields,
      page: nextPage,
      perPage: Pagination.defaultPageSize,
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
    _searchFields = fields;
    state = const AsyncValue.loading();

    final dateRange = ref.read(paymentsDateRangeControllerProvider);
    final result = await _repository.getForDateRangePaginated(
      startDate: dateRange.start,
      endDate: dateRange.end,
      branchScope: _branchScope,
      searchQuery: _searchQuery,
      searchFields: _searchFields,
      page: 1,
      perPage: Pagination.defaultPageSize,
    );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(PaginatedState<PaymentReportEntry>(
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
