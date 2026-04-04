// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_status.dart';

class OrderStatusMapper extends EnumMapper<OrderStatus> {
  OrderStatusMapper._();

  static OrderStatusMapper? _instance;
  static OrderStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderStatusMapper._());
    }
    return _instance!;
  }

  static OrderStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  OrderStatus decode(dynamic value) {
    switch (value) {
      case r'pending':
        return OrderStatus.pending;
      case r'processing':
        return OrderStatus.processing;
      case r'ready':
        return OrderStatus.ready;
      case r'pickedUp':
        return OrderStatus.pickedUp;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(OrderStatus self) {
    switch (self) {
      case OrderStatus.pending:
        return r'pending';
      case OrderStatus.processing:
        return r'processing';
      case OrderStatus.ready:
        return r'ready';
      case OrderStatus.pickedUp:
        return r'pickedUp';
    }
  }
}

extension OrderStatusMapperExtension on OrderStatus {
  String toValue() {
    OrderStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<OrderStatus>(this) as String;
  }
}

