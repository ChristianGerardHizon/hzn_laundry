import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/activity_log.dart';
import '../dto/activity_log_dto.dart';

part 'activity_log_repository.g.dart';

/// Repository interface for activity log operations.
abstract class ActivityLogRepository {
  /// Fetches activity logs with pagination and optional filters.
  FutureEitherPaginated<ActivityLog> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? collection,
    String? action,
    String? search,
  });

  /// Fetches activity logs for a specific record.
  FutureEither<List<ActivityLog>> fetchByRecord(String recordId);
}

/// Provides the ActivityLogRepository instance.
@Riverpod(keepAlive: true)
ActivityLogRepository activityLogRepository(Ref ref) {
  return ActivityLogRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [ActivityLogRepository] using PocketBase.
class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final PocketBase _pb;

  ActivityLogRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.activityLogs);

  ActivityLog _toEntity(RecordModel record) {
    return ActivityLogDto.fromRecord(record).toEntity();
  }

  @override
  FutureEitherPaginated<ActivityLog> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? collection,
    String? action,
    String? search,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filters = <String>[];

        if (collection != null && collection.isNotEmpty) {
          filters.add('collection = "$collection"');
        }
        if (action != null && action.isNotEmpty) {
          filters.add('action = "$action"');
        }
        if (search != null && search.isNotEmpty) {
          filters.add('description ~ "$search"');
        }

        final filter = filters.isNotEmpty ? filters.join(' && ') : null;

        final result = await _collection.getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: '-created',
          expand: 'user',
        );

        return PaginatedResult<ActivityLog>(
          items: result.items.map(_toEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<ActivityLog>> fetchByRecord(String recordId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(
          filter: 'recordId = "$recordId"',
          sort: '-created',
          expand: 'user',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }
}
