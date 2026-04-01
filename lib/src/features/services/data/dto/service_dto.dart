import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../quantity_units/data/dto/quantity_unit_dto.dart';
import '../../../quantity_units/domain/quantity_unit.dart';
import '../../domain/service.dart';

part 'service_dto.mapper.dart';

/// Data Transfer Object for Service from PocketBase.
///
/// Handles conversion between PocketBase RecordModel and domain Service.
@MappableClass()
class ServiceDto with ServiceDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String? description;
  final String? category;
  final String? categoryName;
  final String? branch;
  final num price;
  final bool isVariablePrice;
  final num? estimatedDuration;
  final bool weightBased;
  final bool showPrompt;
  final int? maxQuantity;
  final bool allowExcess;
  final String? quantityUnit;
  final QuantityUnit? quantityUnitExpanded;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const ServiceDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.description,
    this.category,
    this.categoryName,
    this.branch,
    this.price = 0,
    this.isVariablePrice = false,
    this.estimatedDuration,
    this.weightBased = false,
    this.showPrompt = false,
    this.maxQuantity,
    this.allowExcess = false,
    this.quantityUnit,
    this.quantityUnitExpanded,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory ServiceDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    // Get expanded category name
    final categoryExpanded = record.get<String>('expand.category.name');
    final categoryName = categoryExpanded.isNotEmpty ? categoryExpanded : null;

    // Get expanded quantity unit
    QuantityUnit? quantityUnitExpanded;
    final expandData = json['expand'] as Map<String, dynamic>?;
    if (expandData != null && expandData['quantityUnit'] != null) {
      final unitData = expandData['quantityUnit'] as Map<String, dynamic>;
      final unitRecord = RecordModel.fromJson(unitData);
      quantityUnitExpanded = QuantityUnitDto.fromRecord(unitRecord).toEntity();
    }

    return ServiceDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      categoryName: categoryName,
      branch: json['branch'] as String?,
      price: json['price'] as num? ?? 0,
      isVariablePrice: json['isVariablePrice'] as bool? ?? false,
      estimatedDuration: json['estimatedDuration'] as num?,
      weightBased: json['weightBased'] as bool? ?? false,
      showPrompt: json['showPrompt'] as bool? ?? false,
      maxQuantity: json['maxQuantity'] as int?,
      allowExcess: json['allowExcess'] as bool? ?? false,
      quantityUnit: json['quantityUnit'] as String?,
      quantityUnitExpanded: quantityUnitExpanded,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain Service entity.
  Service toEntity() {
    return Service(
      id: id,
      name: name,
      description: description,
      categoryId: category,
      categoryName: categoryName,
      branch: branch,
      price: price,
      isVariablePrice: isVariablePrice,
      estimatedDuration: estimatedDuration,
      weightBased: weightBased,
      showPrompt: showPrompt,
      maxQuantity: maxQuantity,
      allowExcess: allowExcess,
      quantityUnitId: quantityUnit,
      quantityUnit: quantityUnitExpanded,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
