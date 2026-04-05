// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'deduction_type.dart';

class DeductionTypeMapper extends EnumMapper<DeductionType> {
  DeductionTypeMapper._();

  static DeductionTypeMapper? _instance;
  static DeductionTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeductionTypeMapper._());
    }
    return _instance!;
  }

  static DeductionType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  DeductionType decode(dynamic value) {
    switch (value) {
      case r'cashAdvance':
        return DeductionType.cashAdvance;
      case r'sss':
        return DeductionType.sss;
      case r'philHealth':
        return DeductionType.philHealth;
      case r'pagIbig':
        return DeductionType.pagIbig;
      case r'other':
        return DeductionType.other;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(DeductionType self) {
    switch (self) {
      case DeductionType.cashAdvance:
        return r'cashAdvance';
      case DeductionType.sss:
        return r'sss';
      case DeductionType.philHealth:
        return r'philHealth';
      case DeductionType.pagIbig:
        return r'pagIbig';
      case DeductionType.other:
        return r'other';
    }
  }
}

extension DeductionTypeMapperExtension on DeductionType {
  String toValue() {
    DeductionTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<DeductionType>(this) as String;
  }
}

