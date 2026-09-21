// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'subscription_status.dart';

class SubscriptionStatusMapper extends EnumMapper<SubscriptionStatus> {
  SubscriptionStatusMapper._();

  static SubscriptionStatusMapper? _instance;
  static SubscriptionStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubscriptionStatusMapper._());
    }
    return _instance!;
  }

  static SubscriptionStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  SubscriptionStatus decode(dynamic value) {
    switch (value) {
      case r'active':
        return SubscriptionStatus.active;
      case r'grace':
        return SubscriptionStatus.grace;
      case r'locked':
        return SubscriptionStatus.locked;
      case r'cancelled':
        return SubscriptionStatus.cancelled;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(SubscriptionStatus self) {
    switch (self) {
      case SubscriptionStatus.active:
        return r'active';
      case SubscriptionStatus.grace:
        return r'grace';
      case SubscriptionStatus.locked:
        return r'locked';
      case SubscriptionStatus.cancelled:
        return r'cancelled';
    }
  }
}

extension SubscriptionStatusMapperExtension on SubscriptionStatus {
  String toValue() {
    SubscriptionStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<SubscriptionStatus>(this) as String;
  }
}

