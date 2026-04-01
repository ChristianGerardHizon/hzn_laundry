// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service_price_tier_dto.dart';

class ServicePriceTierDtoMapper extends ClassMapperBase<ServicePriceTierDto> {
  ServicePriceTierDtoMapper._();

  static ServicePriceTierDtoMapper? _instance;
  static ServicePriceTierDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServicePriceTierDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ServicePriceTierDto';

  static String _$id(ServicePriceTierDto v) => v.id;
  static const Field<ServicePriceTierDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(ServicePriceTierDto v) => v.collectionId;
  static const Field<ServicePriceTierDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(ServicePriceTierDto v) => v.collectionName;
  static const Field<ServicePriceTierDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$service(ServicePriceTierDto v) => v.service;
  static const Field<ServicePriceTierDto, String> _f$service = Field(
    'service',
    _$service,
  );
  static num _$minQuantity(ServicePriceTierDto v) => v.minQuantity;
  static const Field<ServicePriceTierDto, num> _f$minQuantity = Field(
    'minQuantity',
    _$minQuantity,
  );
  static num? _$maxQuantity(ServicePriceTierDto v) => v.maxQuantity;
  static const Field<ServicePriceTierDto, num> _f$maxQuantity = Field(
    'maxQuantity',
    _$maxQuantity,
    opt: true,
  );
  static num _$pricePerUnit(ServicePriceTierDto v) => v.pricePerUnit;
  static const Field<ServicePriceTierDto, num> _f$pricePerUnit = Field(
    'pricePerUnit',
    _$pricePerUnit,
  );
  static String? _$created(ServicePriceTierDto v) => v.created;
  static const Field<ServicePriceTierDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ServicePriceTierDto v) => v.updated;
  static const Field<ServicePriceTierDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ServicePriceTierDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #service: _f$service,
    #minQuantity: _f$minQuantity,
    #maxQuantity: _f$maxQuantity,
    #pricePerUnit: _f$pricePerUnit,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ServicePriceTierDto _instantiate(DecodingData data) {
    return ServicePriceTierDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      service: data.dec(_f$service),
      minQuantity: data.dec(_f$minQuantity),
      maxQuantity: data.dec(_f$maxQuantity),
      pricePerUnit: data.dec(_f$pricePerUnit),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServicePriceTierDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServicePriceTierDto>(map);
  }

  static ServicePriceTierDto fromJson(String json) {
    return ensureInitialized().decodeJson<ServicePriceTierDto>(json);
  }
}

mixin ServicePriceTierDtoMappable {
  String toJson() {
    return ServicePriceTierDtoMapper.ensureInitialized()
        .encodeJson<ServicePriceTierDto>(this as ServicePriceTierDto);
  }

  Map<String, dynamic> toMap() {
    return ServicePriceTierDtoMapper.ensureInitialized()
        .encodeMap<ServicePriceTierDto>(this as ServicePriceTierDto);
  }

  ServicePriceTierDtoCopyWith<
    ServicePriceTierDto,
    ServicePriceTierDto,
    ServicePriceTierDto
  >
  get copyWith =>
      _ServicePriceTierDtoCopyWithImpl<
        ServicePriceTierDto,
        ServicePriceTierDto
      >(this as ServicePriceTierDto, $identity, $identity);
  @override
  String toString() {
    return ServicePriceTierDtoMapper.ensureInitialized().stringifyValue(
      this as ServicePriceTierDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServicePriceTierDtoMapper.ensureInitialized().equalsValue(
      this as ServicePriceTierDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ServicePriceTierDtoMapper.ensureInitialized().hashValue(
      this as ServicePriceTierDto,
    );
  }
}

extension ServicePriceTierDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServicePriceTierDto, $Out> {
  ServicePriceTierDtoCopyWith<$R, ServicePriceTierDto, $Out>
  get $asServicePriceTierDto => $base.as(
    (v, t, t2) => _ServicePriceTierDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ServicePriceTierDtoCopyWith<
  $R,
  $In extends ServicePriceTierDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? service,
    num? minQuantity,
    num? maxQuantity,
    num? pricePerUnit,
    String? created,
    String? updated,
  });
  ServicePriceTierDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServicePriceTierDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServicePriceTierDto, $Out>
    implements ServicePriceTierDtoCopyWith<$R, ServicePriceTierDto, $Out> {
  _ServicePriceTierDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServicePriceTierDto> $mapper =
      ServicePriceTierDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? service,
    num? minQuantity,
    Object? maxQuantity = $none,
    num? pricePerUnit,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (service != null) #service: service,
      if (minQuantity != null) #minQuantity: minQuantity,
      if (maxQuantity != $none) #maxQuantity: maxQuantity,
      if (pricePerUnit != null) #pricePerUnit: pricePerUnit,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ServicePriceTierDto $make(CopyWithData data) => ServicePriceTierDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    service: data.get(#service, or: $value.service),
    minQuantity: data.get(#minQuantity, or: $value.minQuantity),
    maxQuantity: data.get(#maxQuantity, or: $value.maxQuantity),
    pricePerUnit: data.get(#pricePerUnit, or: $value.pricePerUnit),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ServicePriceTierDtoCopyWith<$R2, ServicePriceTierDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ServicePriceTierDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

