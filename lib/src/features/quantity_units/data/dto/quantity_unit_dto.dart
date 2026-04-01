import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../domain/quantity_unit.dart';

part 'quantity_unit_dto.mapper.dart';

/// Data Transfer Object for QuantityUnit from PocketBase.
///
/// Handles conversion between PocketBase RecordModel and domain QuantityUnit.
@MappableClass()
class QuantityUnitDto with QuantityUnitDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String shortSingular;
  final String shortPlural;
  final String longSingular;
  final String longPlural;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const QuantityUnitDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.shortSingular,
    required this.shortPlural,
    required this.longSingular,
    required this.longPlural,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory QuantityUnitDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return QuantityUnitDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      shortSingular: json['shortSingular'] as String? ?? '',
      shortPlural: json['shortPlural'] as String? ?? '',
      longSingular: json['longSingular'] as String? ?? '',
      longPlural: json['longPlural'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain QuantityUnit entity.
  QuantityUnit toEntity() {
    return QuantityUnit(
      id: id,
      name: name,
      shortSingular: shortSingular,
      shortPlural: shortPlural,
      longSingular: longSingular,
      longPlural: longPlural,
      isDeleted: isDeleted,
      created: created != null ? DateTime.tryParse(created!) : null,
      updated: updated != null ? DateTime.tryParse(updated!) : null,
    );
  }
}
