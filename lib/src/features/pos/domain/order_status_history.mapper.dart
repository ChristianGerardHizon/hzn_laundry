// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_status_history.dart';

class StatusTypeMapper extends EnumMapper<StatusType> {
  StatusTypeMapper._();

  static StatusTypeMapper? _instance;
  static StatusTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StatusTypeMapper._());
    }
    return _instance!;
  }

  static StatusType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  StatusType decode(dynamic value) {
    switch (value) {
      case r'saleStatus':
        return StatusType.saleStatus;
      case r'orderStatus':
        return StatusType.orderStatus;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(StatusType self) {
    switch (self) {
      case StatusType.saleStatus:
        return r'saleStatus';
      case StatusType.orderStatus:
        return r'orderStatus';
    }
  }
}

extension StatusTypeMapperExtension on StatusType {
  String toValue() {
    StatusTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<StatusType>(this) as String;
  }
}

class OrderStatusHistoryMapper extends ClassMapperBase<OrderStatusHistory> {
  OrderStatusHistoryMapper._();

  static OrderStatusHistoryMapper? _instance;
  static OrderStatusHistoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderStatusHistoryMapper._());
      StatusTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrderStatusHistory';

  static String _$id(OrderStatusHistory v) => v.id;
  static const Field<OrderStatusHistory, String> _f$id = Field('id', _$id);
  static String _$saleId(OrderStatusHistory v) => v.saleId;
  static const Field<OrderStatusHistory, String> _f$saleId = Field(
    'saleId',
    _$saleId,
  );
  static StatusType _$statusType(OrderStatusHistory v) => v.statusType;
  static const Field<OrderStatusHistory, StatusType> _f$statusType = Field(
    'statusType',
    _$statusType,
  );
  static String _$fromStatus(OrderStatusHistory v) => v.fromStatus;
  static const Field<OrderStatusHistory, String> _f$fromStatus = Field(
    'fromStatus',
    _$fromStatus,
  );
  static String _$toStatus(OrderStatusHistory v) => v.toStatus;
  static const Field<OrderStatusHistory, String> _f$toStatus = Field(
    'toStatus',
    _$toStatus,
  );
  static String? _$description(OrderStatusHistory v) => v.description;
  static const Field<OrderStatusHistory, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static DateTime? _$created(OrderStatusHistory v) => v.created;
  static const Field<OrderStatusHistory, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(OrderStatusHistory v) => v.updated;
  static const Field<OrderStatusHistory, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<OrderStatusHistory> fields = const {
    #id: _f$id,
    #saleId: _f$saleId,
    #statusType: _f$statusType,
    #fromStatus: _f$fromStatus,
    #toStatus: _f$toStatus,
    #description: _f$description,
    #created: _f$created,
    #updated: _f$updated,
  };

  static OrderStatusHistory _instantiate(DecodingData data) {
    return OrderStatusHistory(
      id: data.dec(_f$id),
      saleId: data.dec(_f$saleId),
      statusType: data.dec(_f$statusType),
      fromStatus: data.dec(_f$fromStatus),
      toStatus: data.dec(_f$toStatus),
      description: data.dec(_f$description),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrderStatusHistory fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderStatusHistory>(map);
  }

  static OrderStatusHistory fromJson(String json) {
    return ensureInitialized().decodeJson<OrderStatusHistory>(json);
  }
}

mixin OrderStatusHistoryMappable {
  String toJson() {
    return OrderStatusHistoryMapper.ensureInitialized()
        .encodeJson<OrderStatusHistory>(this as OrderStatusHistory);
  }

  Map<String, dynamic> toMap() {
    return OrderStatusHistoryMapper.ensureInitialized()
        .encodeMap<OrderStatusHistory>(this as OrderStatusHistory);
  }

  OrderStatusHistoryCopyWith<
    OrderStatusHistory,
    OrderStatusHistory,
    OrderStatusHistory
  >
  get copyWith =>
      _OrderStatusHistoryCopyWithImpl<OrderStatusHistory, OrderStatusHistory>(
        this as OrderStatusHistory,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrderStatusHistoryMapper.ensureInitialized().stringifyValue(
      this as OrderStatusHistory,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrderStatusHistoryMapper.ensureInitialized().equalsValue(
      this as OrderStatusHistory,
      other,
    );
  }

  @override
  int get hashCode {
    return OrderStatusHistoryMapper.ensureInitialized().hashValue(
      this as OrderStatusHistory,
    );
  }
}

extension OrderStatusHistoryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrderStatusHistory, $Out> {
  OrderStatusHistoryCopyWith<$R, OrderStatusHistory, $Out>
  get $asOrderStatusHistory => $base.as(
    (v, t, t2) => _OrderStatusHistoryCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrderStatusHistoryCopyWith<
  $R,
  $In extends OrderStatusHistory,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? saleId,
    StatusType? statusType,
    String? fromStatus,
    String? toStatus,
    String? description,
    DateTime? created,
    DateTime? updated,
  });
  OrderStatusHistoryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrderStatusHistoryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderStatusHistory, $Out>
    implements OrderStatusHistoryCopyWith<$R, OrderStatusHistory, $Out> {
  _OrderStatusHistoryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderStatusHistory> $mapper =
      OrderStatusHistoryMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? saleId,
    StatusType? statusType,
    String? fromStatus,
    String? toStatus,
    Object? description = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (saleId != null) #saleId: saleId,
      if (statusType != null) #statusType: statusType,
      if (fromStatus != null) #fromStatus: fromStatus,
      if (toStatus != null) #toStatus: toStatus,
      if (description != $none) #description: description,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  OrderStatusHistory $make(CopyWithData data) => OrderStatusHistory(
    id: data.get(#id, or: $value.id),
    saleId: data.get(#saleId, or: $value.saleId),
    statusType: data.get(#statusType, or: $value.statusType),
    fromStatus: data.get(#fromStatus, or: $value.fromStatus),
    toStatus: data.get(#toStatus, or: $value.toStatus),
    description: data.get(#description, or: $value.description),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  OrderStatusHistoryCopyWith<$R2, OrderStatusHistory, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrderStatusHistoryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

