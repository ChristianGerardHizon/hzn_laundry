import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/pos_group.dart';
import '../../domain/pos_group_item.dart';

part 'pos_group_dto.mapper.dart';

/// Data Transfer Object for PosGroup from PocketBase.
@MappableClass()
class PosGroupDto with PosGroupDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String branch;
  final int sortOrder;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const PosGroupDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.branch,
    this.sortOrder = 0,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory PosGroupDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return PosGroupDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain PosGroup entity.
  PosGroup toEntity({List<PosGroupItem> items = const []}) {
    return PosGroup(
      id: id,
      name: name,
      branchId: branch,
      sortOrder: sortOrder,
      isDeleted: isDeleted,
      items: items,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
