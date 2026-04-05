// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'activity_action.dart';

class ActivityActionMapper extends EnumMapper<ActivityAction> {
  ActivityActionMapper._();

  static ActivityActionMapper? _instance;
  static ActivityActionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ActivityActionMapper._());
    }
    return _instance!;
  }

  static ActivityAction fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ActivityAction decode(dynamic value) {
    switch (value) {
      case r'create':
        return ActivityAction.create;
      case r'update':
        return ActivityAction.update;
      case r'delete':
        return ActivityAction.delete;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ActivityAction self) {
    switch (self) {
      case ActivityAction.create:
        return r'create';
      case ActivityAction.update:
        return r'update';
      case ActivityAction.delete:
        return r'delete';
    }
  }
}

extension ActivityActionMapperExtension on ActivityAction {
  String toValue() {
    ActivityActionMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ActivityAction>(this) as String;
  }
}

