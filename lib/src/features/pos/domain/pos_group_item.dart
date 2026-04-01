import 'package:dart_mappable/dart_mappable.dart';

import '../../products/domain/product.dart';
import '../../services/domain/service.dart';

part 'pos_group_item.mapper.dart';

/// POS Group Item domain model.
///
/// Represents a product or service assigned to a [PosGroup].
/// Acts as a many-to-many junction between groups and products/services.
@MappableClass()
class PosGroupItem with PosGroupItemMappable {
  const PosGroupItem({
    this.id = '',
    required this.groupId,
    this.productId,
    this.serviceId,
    this.sortOrder = 0,
    this.product,
    this.service,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent group FK ID.
  final String groupId;

  /// Product FK ID (optional, one of product/service must be set).
  final String? productId;

  /// Service FK ID (optional, one of product/service must be set).
  final String? serviceId;

  /// Display order within the group.
  final int sortOrder;

  /// Expanded product (populated from PocketBase expand).
  final Product? product;

  /// Expanded service (populated from PocketBase expand).
  final Service? service;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this item is a product.
  bool get isProduct => productId != null && productId!.isNotEmpty;

  /// Whether this item is a service.
  bool get isService => serviceId != null && serviceId!.isNotEmpty;

  /// Display name from the expanded product or service.
  String get displayName => product?.name ?? service?.name ?? '';

  /// Display price from the expanded product or service.
  num get displayPrice => product?.price ?? service?.price ?? 0;

  /// Whether this item has a variable price.
  bool get hasVariablePrice =>
      product?.isVariablePrice == true || service?.hasVariablePrice == true;
}
