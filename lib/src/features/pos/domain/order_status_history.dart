import 'package:dart_mappable/dart_mappable.dart';

part 'order_status_history.mapper.dart';

/// Type of status that was changed.
@MappableEnum()
enum StatusType {
  saleStatus,
  orderStatus;

  String get displayName => switch (this) {
        StatusType.saleStatus => 'Sale Status',
        StatusType.orderStatus => 'Order Status',
      };
}

/// Records a single status change on a sale.
@MappableClass()
class OrderStatusHistory with OrderStatusHistoryMappable {
  const OrderStatusHistory({
    required this.id,
    required this.saleId,
    required this.statusType,
    required this.fromStatus,
    required this.toStatus,
    this.description,
    this.created,
    this.updated,
  });

  final String id;
  final String saleId;
  final StatusType statusType;
  final String fromStatus;
  final String toStatus;
  final String? description;
  final DateTime? created;
  final DateTime? updated;
}
