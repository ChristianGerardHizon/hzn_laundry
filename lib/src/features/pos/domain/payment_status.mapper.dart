// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'payment_status.dart';

class PaymentStatusMapper extends EnumMapper<PaymentStatus> {
  PaymentStatusMapper._();

  static PaymentStatusMapper? _instance;
  static PaymentStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentStatusMapper._());
    }
    return _instance!;
  }

  static PaymentStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PaymentStatus decode(dynamic value) {
    switch (value) {
      case r'unpaid':
        return PaymentStatus.unpaid;
      case r'partial':
        return PaymentStatus.partial;
      case r'paid':
        return PaymentStatus.paid;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PaymentStatus self) {
    switch (self) {
      case PaymentStatus.unpaid:
        return r'unpaid';
      case PaymentStatus.partial:
        return r'partial';
      case PaymentStatus.paid:
        return r'paid';
    }
  }
}

extension PaymentStatusMapperExtension on PaymentStatus {
  String toValue() {
    PaymentStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PaymentStatus>(this) as String;
  }
}

