import 'package:dart_mappable/dart_mappable.dart';

import '../../products/domain/product.dart';

part 'sale_consumable_usage.mapper.dart';

/// Consumable quantity recorded on a finalized sale.
@MappableClass()
class SaleConsumableUsage with SaleConsumableUsageMappable {
  const SaleConsumableUsage({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    this.unitLabel,
    this.unitCost = 0,
    this.cost = 0,
    this.product,
    this.created,
    this.updated,
  });

  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final num quantity;
  final String? unitLabel;
  final num unitCost;
  final num cost;
  final Product? product;
  final DateTime? created;
  final DateTime? updated;
}
