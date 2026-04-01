import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/promo.dart';

part 'promo_dto.mapper.dart';

/// Data Transfer Object for Promo from PocketBase.
@MappableClass()
class PromoDto with PromoDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String? description;
  final String? startDate;
  final String? endDate;
  final int requiredOrders;
  final num rewardFreeWeight;
  final bool isActive;
  final String? branch;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const PromoDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.requiredOrders = 0,
    this.rewardFreeWeight = 0,
    this.isActive = true,
    this.branch,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory PromoDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return PromoDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      requiredOrders: json['requiredOrders'] as int? ?? 0,
      rewardFreeWeight: json['rewardFreeWeight'] as num? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      branch: json['branch'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain Promo entity.
  Promo toEntity() {
    return Promo(
      id: id,
      name: name,
      description: description,
      startDate: parseToLocal(startDate) ?? DateTime.now(),
      endDate: parseToLocal(endDate) ?? DateTime.now(),
      requiredOrders: requiredOrders,
      rewardFreeWeight: rewardFreeWeight,
      isActive: isActive,
      branch: branch,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
