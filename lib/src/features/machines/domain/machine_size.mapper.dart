// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'machine_size.dart';

class MachineSizeMapper extends EnumMapper<MachineSize> {
  MachineSizeMapper._();

  static MachineSizeMapper? _instance;
  static MachineSizeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MachineSizeMapper._());
    }
    return _instance!;
  }

  static MachineSize fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MachineSize decode(dynamic value) {
    switch (value) {
      case r'small':
        return MachineSize.small;
      case r'large':
        return MachineSize.large;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MachineSize self) {
    switch (self) {
      case MachineSize.small:
        return r'small';
      case MachineSize.large:
        return r'large';
    }
  }
}

extension MachineSizeMapperExtension on MachineSize {
  String toValue() {
    MachineSizeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MachineSize>(this) as String;
  }
}

