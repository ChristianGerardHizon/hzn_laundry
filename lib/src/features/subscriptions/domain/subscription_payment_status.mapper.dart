// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'subscription_payment_status.dart';

class SubscriptionPaymentStatusMapper
    extends EnumMapper<SubscriptionPaymentStatus> {
  SubscriptionPaymentStatusMapper._();

  static SubscriptionPaymentStatusMapper? _instance;
  static SubscriptionPaymentStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = SubscriptionPaymentStatusMapper._(),
      );
    }
    return _instance!;
  }

  static SubscriptionPaymentStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  SubscriptionPaymentStatus decode(dynamic value) {
    switch (value) {
      case r'pending':
        return SubscriptionPaymentStatus.pending;
      case r'approved':
        return SubscriptionPaymentStatus.approved;
      case r'rejected':
        return SubscriptionPaymentStatus.rejected;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(SubscriptionPaymentStatus self) {
    switch (self) {
      case SubscriptionPaymentStatus.pending:
        return r'pending';
      case SubscriptionPaymentStatus.approved:
        return r'approved';
      case SubscriptionPaymentStatus.rejected:
        return r'rejected';
    }
  }
}

extension SubscriptionPaymentStatusMapperExtension
    on SubscriptionPaymentStatus {
  String toValue() {
    SubscriptionPaymentStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<SubscriptionPaymentStatus>(this)
        as String;
  }
}

