// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_status_history_dto.dart';

class OrderStatusHistoryDtoMapper
    extends ClassMapperBase<OrderStatusHistoryDto> {
  OrderStatusHistoryDtoMapper._();

  static OrderStatusHistoryDtoMapper? _instance;
  static OrderStatusHistoryDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderStatusHistoryDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OrderStatusHistoryDto';

  static String _$id(OrderStatusHistoryDto v) => v.id;
  static const Field<OrderStatusHistoryDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(OrderStatusHistoryDto v) => v.collectionId;
  static const Field<OrderStatusHistoryDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(OrderStatusHistoryDto v) => v.collectionName;
  static const Field<OrderStatusHistoryDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$sale(OrderStatusHistoryDto v) => v.sale;
  static const Field<OrderStatusHistoryDto, String> _f$sale = Field(
    'sale',
    _$sale,
  );
  static String _$statusType(OrderStatusHistoryDto v) => v.statusType;
  static const Field<OrderStatusHistoryDto, String> _f$statusType = Field(
    'statusType',
    _$statusType,
  );
  static String _$fromStatus(OrderStatusHistoryDto v) => v.fromStatus;
  static const Field<OrderStatusHistoryDto, String> _f$fromStatus = Field(
    'fromStatus',
    _$fromStatus,
  );
  static String _$toStatus(OrderStatusHistoryDto v) => v.toStatus;
  static const Field<OrderStatusHistoryDto, String> _f$toStatus = Field(
    'toStatus',
    _$toStatus,
  );
  static String? _$description(OrderStatusHistoryDto v) => v.description;
  static const Field<OrderStatusHistoryDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$created(OrderStatusHistoryDto v) => v.created;
  static const Field<OrderStatusHistoryDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(OrderStatusHistoryDto v) => v.updated;
  static const Field<OrderStatusHistoryDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<OrderStatusHistoryDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #sale: _f$sale,
    #statusType: _f$statusType,
    #fromStatus: _f$fromStatus,
    #toStatus: _f$toStatus,
    #description: _f$description,
    #created: _f$created,
    #updated: _f$updated,
  };

  static OrderStatusHistoryDto _instantiate(DecodingData data) {
    return OrderStatusHistoryDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      sale: data.dec(_f$sale),
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

  static OrderStatusHistoryDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderStatusHistoryDto>(map);
  }

  static OrderStatusHistoryDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrderStatusHistoryDto>(json);
  }
}

mixin OrderStatusHistoryDtoMappable {
  String toJson() {
    return OrderStatusHistoryDtoMapper.ensureInitialized()
        .encodeJson<OrderStatusHistoryDto>(this as OrderStatusHistoryDto);
  }

  Map<String, dynamic> toMap() {
    return OrderStatusHistoryDtoMapper.ensureInitialized()
        .encodeMap<OrderStatusHistoryDto>(this as OrderStatusHistoryDto);
  }

  OrderStatusHistoryDtoCopyWith<
    OrderStatusHistoryDto,
    OrderStatusHistoryDto,
    OrderStatusHistoryDto
  >
  get copyWith =>
      _OrderStatusHistoryDtoCopyWithImpl<
        OrderStatusHistoryDto,
        OrderStatusHistoryDto
      >(this as OrderStatusHistoryDto, $identity, $identity);
  @override
  String toString() {
    return OrderStatusHistoryDtoMapper.ensureInitialized().stringifyValue(
      this as OrderStatusHistoryDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrderStatusHistoryDtoMapper.ensureInitialized().equalsValue(
      this as OrderStatusHistoryDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrderStatusHistoryDtoMapper.ensureInitialized().hashValue(
      this as OrderStatusHistoryDto,
    );
  }
}

extension OrderStatusHistoryDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrderStatusHistoryDto, $Out> {
  OrderStatusHistoryDtoCopyWith<$R, OrderStatusHistoryDto, $Out>
  get $asOrderStatusHistoryDto => $base.as(
    (v, t, t2) => _OrderStatusHistoryDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrderStatusHistoryDtoCopyWith<
  $R,
  $In extends OrderStatusHistoryDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? sale,
    String? statusType,
    String? fromStatus,
    String? toStatus,
    String? description,
    String? created,
    String? updated,
  });
  OrderStatusHistoryDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrderStatusHistoryDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderStatusHistoryDto, $Out>
    implements OrderStatusHistoryDtoCopyWith<$R, OrderStatusHistoryDto, $Out> {
  _OrderStatusHistoryDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderStatusHistoryDto> $mapper =
      OrderStatusHistoryDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? sale,
    String? statusType,
    String? fromStatus,
    String? toStatus,
    Object? description = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (sale != null) #sale: sale,
      if (statusType != null) #statusType: statusType,
      if (fromStatus != null) #fromStatus: fromStatus,
      if (toStatus != null) #toStatus: toStatus,
      if (description != $none) #description: description,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  OrderStatusHistoryDto $make(CopyWithData data) => OrderStatusHistoryDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    sale: data.get(#sale, or: $value.sale),
    statusType: data.get(#statusType, or: $value.statusType),
    fromStatus: data.get(#fromStatus, or: $value.fromStatus),
    toStatus: data.get(#toStatus, or: $value.toStatus),
    description: data.get(#description, or: $value.description),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  OrderStatusHistoryDtoCopyWith<$R2, OrderStatusHistoryDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrderStatusHistoryDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

