// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service_item_status.dart';

class ServiceItemStatusMapper extends EnumMapper<ServiceItemStatus> {
  ServiceItemStatusMapper._();

  static ServiceItemStatusMapper? _instance;
  static ServiceItemStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServiceItemStatusMapper._());
    }
    return _instance!;
  }

  static ServiceItemStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ServiceItemStatus decode(dynamic value) {
    switch (value) {
      case r'pending':
        return ServiceItemStatus.pending;
      case r'inProgress':
        return ServiceItemStatus.inProgress;
      case r'completed':
        return ServiceItemStatus.completed;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ServiceItemStatus self) {
    switch (self) {
      case ServiceItemStatus.pending:
        return r'pending';
      case ServiceItemStatus.inProgress:
        return r'inProgress';
      case ServiceItemStatus.completed:
        return r'completed';
    }
  }
}

extension ServiceItemStatusMapperExtension on ServiceItemStatus {
  String toValue() {
    ServiceItemStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ServiceItemStatus>(this) as String;
  }
}

