import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/activity_action.dart';
import '../../domain/activity_log.dart';

part 'activity_log_dto.mapper.dart';

/// Data Transfer Object for ActivityLog from PocketBase.
@MappableClass()
class ActivityLogDto with ActivityLogDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String collection;
  final String recordId;
  final String action;
  final String? description;
  final dynamic changes;
  final String user;
  final String? userName;
  final String? created;
  final String? updated;

  const ActivityLogDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.collection,
    required this.recordId,
    required this.action,
    this.description,
    this.changes,
    required this.user,
    this.userName,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory ActivityLogDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    // Extract user name from expanded relation
    String? expandedUserName;
    try {
      final userExpand = record.get<RecordModel?>('expand.user');
      if (userExpand != null) {
        expandedUserName = userExpand.getStringValue('name');
      }
    } catch (_) {}

    return ActivityLogDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      collection: json['collection'] as String? ?? '',
      recordId: json['recordId'] as String? ?? '',
      action: json['action'] as String? ?? 'create',
      description: json['description'] as String?,
      changes: json['changes'],
      user: json['user'] as String? ?? '',
      userName: expandedUserName,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain ActivityLog entity.
  ActivityLog toEntity() {
    return ActivityLog(
      id: id,
      collection: collection,
      recordId: recordId,
      action: _parseAction(action),
      description: description,
      changes: changes is Map ? Map<String, dynamic>.from(changes as Map) : null,
      userId: user.isNotEmpty ? user : null,
      userName: userName,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  ActivityAction _parseAction(String value) {
    switch (value) {
      case 'create':
        return ActivityAction.create;
      case 'update':
        return ActivityAction.update;
      case 'delete':
        return ActivityAction.delete;
      default:
        return ActivityAction.create;
    }
  }
}
