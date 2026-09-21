// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'billing_interval_unit.dart';

class BillingIntervalUnitMapper extends EnumMapper<BillingIntervalUnit> {
  BillingIntervalUnitMapper._();

  static BillingIntervalUnitMapper? _instance;
  static BillingIntervalUnitMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BillingIntervalUnitMapper._());
    }
    return _instance!;
  }

  static BillingIntervalUnit fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  BillingIntervalUnit decode(dynamic value) {
    switch (value) {
      case r'day':
        return BillingIntervalUnit.day;
      case r'month':
        return BillingIntervalUnit.month;
      case r'year':
        return BillingIntervalUnit.year;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(BillingIntervalUnit self) {
    switch (self) {
      case BillingIntervalUnit.day:
        return r'day';
      case BillingIntervalUnit.month:
        return r'month';
      case BillingIntervalUnit.year:
        return r'year';
    }
  }
}

extension BillingIntervalUnitMapperExtension on BillingIntervalUnit {
  String toValue() {
    BillingIntervalUnitMapper.ensureInitialized();
    return MapperContainer.globals.toValue<BillingIntervalUnit>(this) as String;
  }
}

