import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../organizations/data/repositories/organization_membership_repository.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/user.dart';

part 'paginated_users_controller.g.dart';

/// Builds a PocketBase filter for the given user ids (same-row safe).
///
/// Empty [userIds] returns a filter that matches no records.
String _usersIdFilter(List<String> userIds) {
  final ids = userIds.where((id) => id.isNotEmpty).toSet().toList();
  if (ids.isEmpty) return 'id = ""';
  return ids.map((id) => 'id = "$id"').join(' || ');
}

/// Controller for managing paginated users list (scoped to current org members).
@Riverpod(keepAlive: true)
class PaginatedUsersController extends _$PaginatedUsersController {
  UserRepository get _repository => ref.read(userRepositoryProvider);

  String? _currentSearchQuery;
  List<String>? _currentSearchFields;
  String _memberFilter = 'id = ""';

  @override
  Future<PaginatedState<User>> build() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;

    // Rebuild when org changes
    ref.watch(currentOrganizationIdProvider);

    _memberFilter = await _resolveMemberFilter();

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.defaultPageSize,
      filter: _memberFilter,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) => PaginatedState<User>(
        items: paginated.items,
        currentPage: paginated.page,
        totalItems: paginated.totalItems,
        totalPages: paginated.totalPages,
        hasReachedEnd: !paginated.hasMore,
      ),
    );
  }

  Future<String> _resolveMemberFilter() async {
    final orgId = ref.read(currentOrganizationIdProvider);
    if (orgId == null || orgId.isEmpty) return 'id = ""';

    final result = await ref
        .read(organizationMembershipRepositoryProvider)
        .listForOrganization(orgId);

    return result.fold(
      (_) => 'id = ""',
      (memberships) => _usersIdFilter(
        memberships.map((m) => m.userId).toList(),
      ),
    );
  }

  bool get isSearchActive => _currentSearchQuery != null;

  String? get currentSearchQuery => _currentSearchQuery;

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedEnd) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            filter: _memberFilter,
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            filter: _memberFilter,
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

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _memberFilter = await _resolveMemberFilter();

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: 1,
            perPage: Pagination.defaultPageSize,
            filter: _memberFilter,
          )
        : await _repository.fetchPaginated(
            page: 1,
            perPage: Pagination.defaultPageSize,
            filter: _memberFilter,
          );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(PaginatedState<User>(
        items: paginated.items,
        currentPage: paginated.page,
        totalItems: paginated.totalItems,
        totalPages: paginated.totalPages,
        hasReachedEnd: !paginated.hasMore,
      )),
    );
  }

  Future<void> search(String query, {List<String>? fields}) async {
    if (query.isEmpty) {
      return clearSearch();
    }

    _currentSearchQuery = query;
    _currentSearchFields = fields;

    state = const AsyncValue.loading();
    _memberFilter = await _resolveMemberFilter();

    final result = await _repository.searchPaginated(
      query,
      fields: fields,
      page: 1,
      perPage: Pagination.defaultPageSize,
      filter: _memberFilter,
    );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(PaginatedState<User>(
        items: paginated.items,
        currentPage: paginated.page,
        totalItems: paginated.totalItems,
        totalPages: paginated.totalPages,
        hasReachedEnd: !paginated.hasMore,
      )),
    );
  }

  Future<void> clearSearch() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;
    return refresh();
  }

  Future<bool> updateUser(User user) async {
    final result = await _repository.update(user);
    return result.fold(
      (failure) => false,
      (updated) {
        state.whenData((currentState) {
          state = AsyncValue.data(
            currentState.updateItem(updated, (u) => u.id == updated.id),
          );
        });
        return true;
      },
    );
  }

  Future<bool> deleteUser(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((currentState) {
          state = AsyncValue.data(
            currentState.removeItem((u) => u.id == id),
          );
        });
        return true;
      },
    );
  }
}
