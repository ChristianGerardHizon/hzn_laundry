import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/cart_service_item.dart';
import 'service_dto.dart';

part 'cart_service_item_dto.mapper.dart';

@MappableClass()
class CartServiceItemDto with CartServiceItemDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String cart;
  final String service;
  final num quantity;
  final num? customPrice;
  final String? created;
  final String? updated;

  const CartServiceItemDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.cart,
    required this.service,
    required this.quantity,
    this.customPrice,
    this.created,
    this.updated,
  });

  factory CartServiceItemDto.fromRecord(RecordModel record) {
    // Handle customPrice - treat 0 as null (PocketBase default for unset)
    final rawCustomPrice = record.data['customPrice'];
    num? customPrice;
    if (rawCustomPrice != null && rawCustomPrice is num && rawCustomPrice != 0) {
      customPrice = rawCustomPrice;
    }

    return CartServiceItemDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      cart: record.getStringValue('cart'),
      service: record.getStringValue('service'),
      quantity: record.getDoubleValue('quantity'),
      customPrice: customPrice,
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  CartServiceItem toEntity({RecordModel? serviceExpanded}) {
    return CartServiceItem(
      id: id,
      cartId: cart,
      serviceId: service,
      quantity: quantity,
      customPrice: customPrice,
      service: serviceExpanded != null
          ? ServiceDto.fromRecord(serviceExpanded).toEntity()
          : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
