// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'machine_type.dart';

class MachineTypeMapper extends EnumMapper<MachineType> {
  MachineTypeMapper._();

  static MachineTypeMapper? _instance;
  static MachineTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MachineTypeMapper._());
    }
    return _instance!;
  }

  static MachineType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MachineType decode(dynamic value) {
    switch (value) {
      case r'washer':
        return MachineType.washer;
      case r'dryer':
        return MachineType.dryer;
      case r'other':
        return MachineType.other;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MachineType self) {
    switch (self) {
      case MachineType.washer:
        return r'washer';
      case MachineType.dryer:
        return r'dryer';
      case MachineType.other:
        return r'other';
    }
  }
}

extension MachineTypeMapperExtension on MachineType {
  String toValue() {
    MachineTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MachineType>(this) as String;
  }
}

