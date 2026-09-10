import 'package:dart_mappable/dart_mappable.dart';

import '../../products/domain/product.dart';

part 'service_consumable_recipe.mapper.dart';

/// A consumable product attached to a service with default usage.
@MappableClass()
class ServiceConsumableRecipe with ServiceConsumableRecipeMappable {
  const ServiceConsumableRecipe({
    required this.id,
    required this.serviceId,
    required this.productId,
    this.defaultQuantity = 0,
    this.prefill = true,
    this.product,
    this.created,
    this.updated,
  });

  final String id;
  final String serviceId;
  final String productId;
  final num defaultQuantity;
  final bool prefill;
  final Product? product;
  final DateTime? created;
  final DateTime? updated;
}
