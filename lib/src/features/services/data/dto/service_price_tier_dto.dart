import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/service_price_tier.dart';

part 'service_price_tier_dto.mapper.dart';

/// Data Transfer Object for ServicePriceTier from PocketBase.
@MappableClass()
class ServicePriceTierDto with ServicePriceTierDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String service;
  final num minQuantity;
  final num? maxQuantity;
  final num pricePerUnit;
  final num? flatPrice;
  final String? created;
  final String? updated;

  const ServicePriceTierDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.service,
    required this.minQuantity,
    this.maxQuantity,
    required this.pricePerUnit,
    this.flatPrice,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory ServicePriceTierDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return ServicePriceTierDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      service: json['service'] as String? ?? '',
      minQuantity: json['minQuantity'] as num? ?? 0,
      maxQuantity: json['maxQuantity'] as num?,
      pricePerUnit: json['pricePerUnit'] as num? ?? 0,
      flatPrice: json['flatPrice'] as num?,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain entity.
  ServicePriceTier toEntity() {
    return ServicePriceTier(
      id: id,
      serviceId: service,
      minQuantity: minQuantity,
      maxQuantity: maxQuantity,
      pricePerUnit: pricePerUnit,
      flatPrice: flatPrice,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
