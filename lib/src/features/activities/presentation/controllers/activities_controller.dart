import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/presentation/payments_controller.dart';
import '../../data/repositories/activity_log_repository.dart';
import '../../domain/activity_log.dart';

part 'activities_controller.g.dart';

/// State for the activities controller containing logs and pagination info.
class ActivitiesState {
  const ActivitiesState({
    this.logs = const [],
    this.page = 1,
    this.hasMore = true,
    this.action,
  });

  final List<ActivityLog> logs;
  final int page;
  final bool hasMore;
  final String? action;

  ActivitiesState copyWith({
    List<ActivityLog>? logs,
    int? page,
    bool? hasMore,
    String? Function()? action,
  }) {
    return ActivitiesState(
      logs: logs ?? this.logs,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      action: action != null ? action() : this.action,
    );
  }
}

/// Controller for a single activity tab with pagination and action filtering.
///
/// [collectionFilter] is the collection name to filter by, or empty string for all.
@riverpod
class ActivitiesController extends _$ActivitiesController {
  @override
  Future<ActivitiesState> build(String collectionFilter) async {
    return _fetchPage(1);
  }

  Future<ActivitiesState> _fetchPage(
    int page, {
    List<ActivityLog> existing = const [],
    String? action,
  }) async {
    final repo = ref.read(activityLogRepositoryProvider);
    final collection =
        collectionFilter.isNotEmpty ? collectionFilter : null;
    final result = await repo.fetchPaginated(
      page: page,
      collection: collection,
      action: action,
    );

    return result.fold(
      (failure) => ActivitiesState(
        logs: existing,
        page: page,
        hasMore: false,
        action: action,
      ),
      (paginated) => ActivitiesState(
        logs: [...existing, ...paginated.items],
        page: paginated.page,
        hasMore: paginated.hasMore,
        action: action,
      ),
    );
  }

  /// Load the next page of results.
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    final nextPage = currentState.page + 1;
    state = AsyncData(await _fetchPage(
      nextPage,
      existing: currentState.logs,
      action: currentState.action,
    ));
  }

  /// Apply action filter and reload from page 1.
  Future<void> filterByAction(String? action) async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(1, action: action));
  }

  /// Refresh from page 1 with current filters.
  Future<void> refresh() async {
    final currentState = state.value;
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(
      1,
      action: currentState?.action,
    ));
  }
}

/// Provider for fetching activity logs for a specific record.
@riverpod
Future<List<ActivityLog>> recordActivityLogs(
  Ref ref,
  String recordId,
) async {
  final repository = ref.watch(activityLogRepositoryProvider);
  final result = await repository.fetchByRecord(recordId);
  return result.fold((f) => [], (logs) => logs);
}

/// Provider for fetching all activity logs related to a sale,
/// including logs for its payment records.
@riverpod
Future<List<ActivityLog>> saleActivityLogs(
  Ref ref,
  String saleId,
) async {
  final repository = ref.watch(activityLogRepositoryProvider);

  // Get payment IDs for this sale
  final paymentsAsync = await ref.watch(salePaymentsProvider(saleId).future);
  final paymentIds = paymentsAsync.map((p) => p.id).toList();

  // Fetch logs for the sale + all its payment records
  final allRecordIds = [saleId, ...paymentIds];
  final result = await repository.fetchByRecordIds(allRecordIds);
  return result.fold((f) => [], (logs) => logs);
}
