// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service_price_tier.dart';

class ServicePriceTierMapper extends ClassMapperBase<ServicePriceTier> {
  ServicePriceTierMapper._();

  static ServicePriceTierMapper? _instance;
  static ServicePriceTierMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServicePriceTierMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ServicePriceTier';

  static String _$id(ServicePriceTier v) => v.id;
  static const Field<ServicePriceTier, String> _f$id = Field('id', _$id);
  static String _$serviceId(ServicePriceTier v) => v.serviceId;
  static const Field<ServicePriceTier, String> _f$serviceId = Field(
    'serviceId',
    _$serviceId,
  );
  static num _$minQuantity(ServicePriceTier v) => v.minQuantity;
  static const Field<ServicePriceTier, num> _f$minQuantity = Field(
    'minQuantity',
    _$minQuantity,
  );
  static num _$pricePerUnit(ServicePriceTier v) => v.pricePerUnit;
  static const Field<ServicePriceTier, num> _f$pricePerUnit = Field(
    'pricePerUnit',
    _$pricePerUnit,
  );
  static num? _$maxQuantity(ServicePriceTier v) => v.maxQuantity;
  static const Field<ServicePriceTier, num> _f$maxQuantity = Field(
    'maxQuantity',
    _$maxQuantity,
    opt: true,
  );
  static DateTime? _$created(ServicePriceTier v) => v.created;
  static const Field<ServicePriceTier, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(ServicePriceTier v) => v.updated;
  static const Field<ServicePriceTier, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ServicePriceTier> fields = const {
    #id: _f$id,
    #serviceId: _f$serviceId,
    #minQuantity: _f$minQuantity,
    #pricePerUnit: _f$pricePerUnit,
    #maxQuantity: _f$maxQuantity,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ServicePriceTier _instantiate(DecodingData data) {
    return ServicePriceTier(
      id: data.dec(_f$id),
      serviceId: data.dec(_f$serviceId),
      minQuantity: data.dec(_f$minQuantity),
      pricePerUnit: data.dec(_f$pricePerUnit),
      maxQuantity: data.dec(_f$maxQuantity),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServicePriceTier fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServicePriceTier>(map);
  }

  static ServicePriceTier fromJson(String json) {
    return ensureInitialized().decodeJson<ServicePriceTier>(json);
  }
}

mixin ServicePriceTierMappable {
  String toJson() {
    return ServicePriceTierMapper.ensureInitialized()
        .encodeJson<ServicePriceTier>(this as ServicePriceTier);
  }

  Map<String, dynamic> toMap() {
    return ServicePriceTierMapper.ensureInitialized()
        .encodeMap<ServicePriceTier>(this as ServicePriceTier);
  }

  ServicePriceTierCopyWith<ServicePriceTier, ServicePriceTier, ServicePriceTier>
  get copyWith =>
      _ServicePriceTierCopyWithImpl<ServicePriceTier, ServicePriceTier>(
        this as ServicePriceTier,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServicePriceTierMapper.ensureInitialized().stringifyValue(
      this as ServicePriceTier,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServicePriceTierMapper.ensureInitialized().equalsValue(
      this as ServicePriceTier,
      other,
    );
  }

  @override
  int get hashCode {
    return ServicePriceTierMapper.ensureInitialized().hashValue(
      this as ServicePriceTier,
    );
  }
}

extension ServicePriceTierValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServicePriceTier, $Out> {
  ServicePriceTierCopyWith<$R, ServicePriceTier, $Out>
  get $asServicePriceTier =>
      $base.as((v, t, t2) => _ServicePriceTierCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServicePriceTierCopyWith<$R, $In extends ServicePriceTier, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? serviceId,
    num? minQuantity,
    num? pricePerUnit,
    num? maxQuantity,
    DateTime? created,
    DateTime? updated,
  });
  ServicePriceTierCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServicePriceTierCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServicePriceTier, $Out>
    implements ServicePriceTierCopyWith<$R, ServicePriceTier, $Out> {
  _ServicePriceTierCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServicePriceTier> $mapper =
      ServicePriceTierMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? serviceId,
    num? minQuantity,
    num? pricePerUnit,
    Object? maxQuantity = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (serviceId != null) #serviceId: serviceId,
      if (minQuantity != null) #minQuantity: minQuantity,
      if (pricePerUnit != null) #pricePerUnit: pricePerUnit,
      if (maxQuantity != $none) #maxQuantity: maxQuantity,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ServicePriceTier $make(CopyWithData data) => ServicePriceTier(
    id: data.get(#id, or: $value.id),
    serviceId: data.get(#serviceId, or: $value.serviceId),
    minQuantity: data.get(#minQuantity, or: $value.minQuantity),
    pricePerUnit: data.get(#pricePerUnit, or: $value.pricePerUnit),
    maxQuantity: data.get(#maxQuantity, or: $value.maxQuantity),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ServicePriceTierCopyWith<$R2, ServicePriceTier, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServicePriceTierCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

