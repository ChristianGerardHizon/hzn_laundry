import 'package:dart_mappable/dart_mappable.dart';

part 'storage_location.mapper.dart';

/// Storage location domain model.
///
/// Represents a storage location (shelf, rack, etc.) for laundry items.
@MappableClass()
class StorageLocation with StorageLocationMappable {
  const StorageLocation({
    required this.id,
    required this.name,
    this.branchId,
    this.isAvailable = true,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  static const String collectionName = 'storages';

  /// PocketBase record ID.
  final String id;

  /// Storage location name (e.g., "Shelf A-1").
  final String name;

  /// Branch this storage belongs to.
  final String? branchId;

  /// Whether the storage location is currently available.
  final bool isAvailable;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
