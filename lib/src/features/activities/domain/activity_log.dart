import 'package:dart_mappable/dart_mappable.dart';

import 'activity_action.dart';

part 'activity_log.mapper.dart';

/// A single activity log entry recording a CRUD operation.
@MappableClass()
class ActivityLog with ActivityLogMappable {
  const ActivityLog({
    required this.id,
    required this.collection,
    required this.recordId,
    required this.action,
    this.description,
    this.changes,
    this.userId,
    this.userName,
    this.created,
    this.updated,
  });

  final String id;
  final String collection;
  final String recordId;
  final ActivityAction action;
  final String? description;
  final Map<String, dynamic>? changes;
  final String? userId;
  final String? userName;
  final DateTime? created;
  final DateTime? updated;

  /// Human-readable collection name for display.
  String get collectionDisplayName {
    // Convert camelCase to Title Case
    final words = collection.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => ' ${m.group(1)}',
    );
    return words[0].toUpperCase() + words.substring(1);
  }
}
