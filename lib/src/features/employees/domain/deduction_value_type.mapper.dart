// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'deduction_value_type.dart';

class DeductionValueTypeMapper extends EnumMapper<DeductionValueType> {
  DeductionValueTypeMapper._();

  static DeductionValueTypeMapper? _instance;
  static DeductionValueTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeductionValueTypeMapper._());
    }
    return _instance!;
  }

  static DeductionValueType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  DeductionValueType decode(dynamic value) {
    switch (value) {
      case r'fixed':
        return DeductionValueType.fixed;
      case r'percentage':
        return DeductionValueType.percentage;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(DeductionValueType self) {
    switch (self) {
      case DeductionValueType.fixed:
        return r'fixed';
      case DeductionValueType.percentage:
        return r'percentage';
    }
  }
}

extension DeductionValueTypeMapperExtension on DeductionValueType {
  String toValue() {
    DeductionValueTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<DeductionValueType>(this) as String;
  }
}

