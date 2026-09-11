import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../products/data/dto/product_dto.dart';
import '../../domain/sale_consumable_usage.dart';

part 'sale_consumable_usage_dto.mapper.dart';

@MappableClass()
class SaleConsumableUsageDto with SaleConsumableUsageDtoMappable {
  const SaleConsumableUsageDto({
    required this.id,
    required this.sale,
    required this.product,
    required this.productName,
    required this.quantity,
    this.unitLabel,
    this.unitCost = 0,
    this.cost = 0,
    this.created,
    this.updated,
  });

  final String id;
  final String sale;
  final String product;
  final String productName;
  final num quantity;
  final String? unitLabel;
  final num unitCost;
  final num cost;
  final String? created;
  final String? updated;

  factory SaleConsumableUsageDto.fromRecord(RecordModel record) {
    return SaleConsumableUsageDto(
      id: record.id,
      sale: record.getStringValue('sale'),
      product: record.getStringValue('product'),
      productName: record.getStringValue('productName'),
      quantity: record.getDoubleValue('quantity'),
      unitLabel: record.getStringValue('unitLabel'),
      unitCost: record.getDoubleValue('unitCost'),
      cost: record.getDoubleValue('cost'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  SaleConsumableUsage toEntity({RecordModel? productExpanded}) {
    return SaleConsumableUsage(
      id: id,
      saleId: sale,
      productId: product,
      productName: productName,
      quantity: quantity,
      unitLabel: unitLabel?.isEmpty == true ? null : unitLabel,
      unitCost: unitCost,
      cost: cost,
      product: productExpanded != null
          ? ProductDto.fromRecord(productExpanded).toEntity()
          : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
