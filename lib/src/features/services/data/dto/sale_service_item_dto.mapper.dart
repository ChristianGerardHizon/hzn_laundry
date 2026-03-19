// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale_service_item_dto.dart';

class SaleServiceItemDtoMapper extends ClassMapperBase<SaleServiceItemDto> {
  SaleServiceItemDtoMapper._();

  static SaleServiceItemDtoMapper? _instance;
  static SaleServiceItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleServiceItemDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SaleServiceItemDto';

  static String _$id(SaleServiceItemDto v) => v.id;
  static const Field<SaleServiceItemDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(SaleServiceItemDto v) => v.collectionId;
  static const Field<SaleServiceItemDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(SaleServiceItemDto v) => v.collectionName;
  static const Field<SaleServiceItemDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$sale(SaleServiceItemDto v) => v.sale;
  static const Field<SaleServiceItemDto, String> _f$sale = Field(
    'sale',
    _$sale,
  );
  static String _$service(SaleServiceItemDto v) => v.service;
  static const Field<SaleServiceItemDto, String> _f$service = Field(
    'service',
    _$service,
  );
  static String _$serviceName(SaleServiceItemDto v) => v.serviceName;
  static const Field<SaleServiceItemDto, String> _f$serviceName = Field(
    'serviceName',
    _$serviceName,
  );
  static num _$quantity(SaleServiceItemDto v) => v.quantity;
  static const Field<SaleServiceItemDto, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static num _$unitPrice(SaleServiceItemDto v) => v.unitPrice;
  static const Field<SaleServiceItemDto, num> _f$unitPrice = Field(
    'unitPrice',
    _$unitPrice,
  );
  static num _$subtotal(SaleServiceItemDto v) => v.subtotal;
  static const Field<SaleServiceItemDto, num> _f$subtotal = Field(
    'subtotal',
    _$subtotal,
  );
  static String? _$machine(SaleServiceItemDto v) => v.machine;
  static const Field<SaleServiceItemDto, String> _f$machine = Field(
    'machine',
    _$machine,
    opt: true,
  );
  static String? _$machineName(SaleServiceItemDto v) => v.machineName;
  static const Field<SaleServiceItemDto, String> _f$machineName = Field(
    'machineName',
    _$machineName,
    opt: true,
  );
  static String? _$storage(SaleServiceItemDto v) => v.storage;
  static const Field<SaleServiceItemDto, String> _f$storage = Field(
    'storage',
    _$storage,
    opt: true,
  );
  static String? _$storageName(SaleServiceItemDto v) => v.storageName;
  static const Field<SaleServiceItemDto, String> _f$storageName = Field(
    'storageName',
    _$storageName,
    opt: true,
  );
  static String? _$status(SaleServiceItemDto v) => v.status;
  static const Field<SaleServiceItemDto, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );
  static String? _$created(SaleServiceItemDto v) => v.created;
  static const Field<SaleServiceItemDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(SaleServiceItemDto v) => v.updated;
  static const Field<SaleServiceItemDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<SaleServiceItemDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #sale: _f$sale,
    #service: _f$service,
    #serviceName: _f$serviceName,
    #quantity: _f$quantity,
    #unitPrice: _f$unitPrice,
    #subtotal: _f$subtotal,
    #machine: _f$machine,
    #machineName: _f$machineName,
    #storage: _f$storage,
    #storageName: _f$storageName,
    #status: _f$status,
    #created: _f$created,
    #updated: _f$updated,
  };

  static SaleServiceItemDto _instantiate(DecodingData data) {
    return SaleServiceItemDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      sale: data.dec(_f$sale),
      service: data.dec(_f$service),
      serviceName: data.dec(_f$serviceName),
      quantity: data.dec(_f$quantity),
      unitPrice: data.dec(_f$unitPrice),
      subtotal: data.dec(_f$subtotal),
      machine: data.dec(_f$machine),
      machineName: data.dec(_f$machineName),
      storage: data.dec(_f$storage),
      storageName: data.dec(_f$storageName),
      status: data.dec(_f$status),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SaleServiceItemDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SaleServiceItemDto>(map);
  }

  static SaleServiceItemDto fromJson(String json) {
    return ensureInitialized().decodeJson<SaleServiceItemDto>(json);
  }
}

mixin SaleServiceItemDtoMappable {
  String toJson() {
    return SaleServiceItemDtoMapper.ensureInitialized()
        .encodeJson<SaleServiceItemDto>(this as SaleServiceItemDto);
  }

  Map<String, dynamic> toMap() {
    return SaleServiceItemDtoMapper.ensureInitialized()
        .encodeMap<SaleServiceItemDto>(this as SaleServiceItemDto);
  }

  SaleServiceItemDtoCopyWith<
    SaleServiceItemDto,
    SaleServiceItemDto,
    SaleServiceItemDto
  >
  get copyWith =>
      _SaleServiceItemDtoCopyWithImpl<SaleServiceItemDto, SaleServiceItemDto>(
        this as SaleServiceItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SaleServiceItemDtoMapper.ensureInitialized().stringifyValue(
      this as SaleServiceItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return SaleServiceItemDtoMapper.ensureInitialized().equalsValue(
      this as SaleServiceItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SaleServiceItemDtoMapper.ensureInitialized().hashValue(
      this as SaleServiceItemDto,
    );
  }
}

extension SaleServiceItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SaleServiceItemDto, $Out> {
  SaleServiceItemDtoCopyWith<$R, SaleServiceItemDto, $Out>
  get $asSaleServiceItemDto => $base.as(
    (v, t, t2) => _SaleServiceItemDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SaleServiceItemDtoCopyWith<
  $R,
  $In extends SaleServiceItemDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? sale,
    String? service,
    String? serviceName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    String? machine,
    String? machineName,
    String? storage,
    String? storageName,
    String? status,
    String? created,
    String? updated,
  });
  SaleServiceItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SaleServiceItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SaleServiceItemDto, $Out>
    implements SaleServiceItemDtoCopyWith<$R, SaleServiceItemDto, $Out> {
  _SaleServiceItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SaleServiceItemDto> $mapper =
      SaleServiceItemDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? sale,
    String? service,
    String? serviceName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    Object? machine = $none,
    Object? machineName = $none,
    Object? storage = $none,
    Object? storageName = $none,
    Object? status = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (sale != null) #sale: sale,
      if (service != null) #service: service,
      if (serviceName != null) #serviceName: serviceName,
      if (quantity != null) #quantity: quantity,
      if (unitPrice != null) #unitPrice: unitPrice,
      if (subtotal != null) #subtotal: subtotal,
      if (machine != $none) #machine: machine,
      if (machineName != $none) #machineName: machineName,
      if (storage != $none) #storage: storage,
      if (storageName != $none) #storageName: storageName,
      if (status != $none) #status: status,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  SaleServiceItemDto $make(CopyWithData data) => SaleServiceItemDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    sale: data.get(#sale, or: $value.sale),
    service: data.get(#service, or: $value.service),
    serviceName: data.get(#serviceName, or: $value.serviceName),
    quantity: data.get(#quantity, or: $value.quantity),
    unitPrice: data.get(#unitPrice, or: $value.unitPrice),
    subtotal: data.get(#subtotal, or: $value.subtotal),
    machine: data.get(#machine, or: $value.machine),
    machineName: data.get(#machineName, or: $value.machineName),
    storage: data.get(#storage, or: $value.storage),
    storageName: data.get(#storageName, or: $value.storageName),
    status: data.get(#status, or: $value.status),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  SaleServiceItemDtoCopyWith<$R2, SaleServiceItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SaleServiceItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

