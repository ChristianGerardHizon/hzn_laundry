import 'package:dart_mappable/dart_mappable.dart';

import 'pos_group_item.dart';

part 'pos_group.mapper.dart';

/// POS Group domain model.
///
/// Represents a named group of products/services displayed as a section
/// on the cashier page. Groups are per-branch and ordered by [sortOrder].
@MappableClass()
class PosGroup with PosGroupMappable {
  const PosGroup({
    this.id = '',
    required this.name,
    required this.branchId,
    this.sortOrder = 0,
    this.isDeleted = false,
    this.items = const [],
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Group display name.
  final String name;

  /// Branch FK ID.
  final String branchId;

  /// Display order (lower = first).
  final int sortOrder;

  /// Soft delete flag.
  final bool isDeleted;

  /// Items in this group (populated client-side).
  final List<PosGroupItem> items;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
