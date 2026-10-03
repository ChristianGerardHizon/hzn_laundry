// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'fulfillment_type.dart';

class FulfillmentTypeMapper extends EnumMapper<FulfillmentType> {
  FulfillmentTypeMapper._();

  static FulfillmentTypeMapper? _instance;
  static FulfillmentTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FulfillmentTypeMapper._());
    }
    return _instance!;
  }

  static FulfillmentType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  FulfillmentType decode(dynamic value) {
    switch (value) {
      case r'pickup':
        return FulfillmentType.pickup;
      case r'delivery':
        return FulfillmentType.delivery;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(FulfillmentType self) {
    switch (self) {
      case FulfillmentType.pickup:
        return r'pickup';
      case FulfillmentType.delivery:
        return r'delivery';
    }
  }
}

extension FulfillmentTypeMapperExtension on FulfillmentType {
  String toValue() {
    FulfillmentTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<FulfillmentType>(this) as String;
  }
}

