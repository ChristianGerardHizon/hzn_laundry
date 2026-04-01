import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/storage_location.dart';

part 'storage_location_dto.mapper.dart';

/// Data Transfer Object for StorageLocation from PocketBase.
@MappableClass()
class StorageLocationDto with StorageLocationDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String? branch;
  final bool isAvailable;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const StorageLocationDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.branch,
    this.isAvailable = true,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory StorageLocationDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return StorageLocationDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      branch: json['branch'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain StorageLocation entity.
  StorageLocation toEntity() {
    return StorageLocation(
      id: id,
      name: name,
      branchId: branch,
      isAvailable: isAvailable,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
