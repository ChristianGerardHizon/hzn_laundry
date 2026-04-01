import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../domain/service_category.dart';

part 'service_category_dto.mapper.dart';

/// Data Transfer Object for ServiceCategory from PocketBase.
///
/// Handles conversion between PocketBase RecordModel and domain ServiceCategory.
@MappableClass()
class ServiceCategoryDto with ServiceCategoryDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const ServiceCategoryDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory ServiceCategoryDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return ServiceCategoryDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain ServiceCategory entity.
  ServiceCategory toEntity() {
    return ServiceCategory(
      id: id,
      name: name,
      isDeleted: isDeleted,
      created: created != null ? DateTime.tryParse(created!) : null,
      updated: updated != null ? DateTime.tryParse(updated!) : null,
    );
  }
}
