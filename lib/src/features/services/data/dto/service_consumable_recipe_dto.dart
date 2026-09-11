import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../products/data/dto/product_dto.dart';
import '../../domain/service_consumable_recipe.dart';

part 'service_consumable_recipe_dto.mapper.dart';

@MappableClass()
class ServiceConsumableRecipeDto with ServiceConsumableRecipeDtoMappable {
  const ServiceConsumableRecipeDto({
    required this.id,
    required this.service,
    required this.product,
    this.defaultQuantity = 0,
    this.prefill = true,
    this.created,
    this.updated,
  });

  final String id;
  final String service;
  final String product;
  final num defaultQuantity;
  final bool prefill;
  final String? created;
  final String? updated;

  factory ServiceConsumableRecipeDto.fromRecord(RecordModel record) {
    final json = record.toJson();
    return ServiceConsumableRecipeDto(
      id: json['id'] as String? ?? '',
      service: json['service'] as String? ?? '',
      product: json['product'] as String? ?? '',
      defaultQuantity: json['defaultQuantity'] as num? ?? 0,
      prefill: json['prefill'] as bool? ?? true,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  ServiceConsumableRecipe toEntity({RecordModel? productExpanded}) {
    return ServiceConsumableRecipe(
      id: id,
      serviceId: service,
      productId: product,
      defaultQuantity: defaultQuantity,
      prefill: prefill,
      product: productExpanded != null
          ? ProductDto.fromRecord(productExpanded).toEntity()
          : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
