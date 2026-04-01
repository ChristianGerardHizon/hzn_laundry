import 'package:dart_mappable/dart_mappable.dart';

part 'order_status.mapper.dart';

/// Status of an order in the fulfillment workflow.
@MappableEnum()
enum OrderStatus {
  pending,
  processing,
  ready,
  pickedUp;

  String get displayName => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.processing => 'Processing',
        OrderStatus.ready => 'Ready',
        OrderStatus.pickedUp => 'Picked Up',
      };

  /// Returns the icon for this order status.
  String get iconName => switch (this) {
        OrderStatus.pending => 'schedule',
        OrderStatus.processing => 'autorenew',
        OrderStatus.ready => 'check_circle',
        OrderStatus.pickedUp => 'local_shipping',
      };
}
