// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service_consumable_recipe_dto.dart';

class ServiceConsumableRecipeDtoMapper
    extends ClassMapperBase<ServiceConsumableRecipeDto> {
  ServiceConsumableRecipeDtoMapper._();

  static ServiceConsumableRecipeDtoMapper? _instance;
  static ServiceConsumableRecipeDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = ServiceConsumableRecipeDtoMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'ServiceConsumableRecipeDto';

  static String _$id(ServiceConsumableRecipeDto v) => v.id;
  static const Field<ServiceConsumableRecipeDto, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$service(ServiceConsumableRecipeDto v) => v.service;
  static const Field<ServiceConsumableRecipeDto, String> _f$service = Field(
    'service',
    _$service,
  );
  static String _$product(ServiceConsumableRecipeDto v) => v.product;
  static const Field<ServiceConsumableRecipeDto, String> _f$product = Field(
    'product',
    _$product,
  );
  static num _$defaultQuantity(ServiceConsumableRecipeDto v) =>
      v.defaultQuantity;
  static const Field<ServiceConsumableRecipeDto, num> _f$defaultQuantity =
      Field('defaultQuantity', _$defaultQuantity, opt: true, def: 0);
  static bool _$prefill(ServiceConsumableRecipeDto v) => v.prefill;
  static const Field<ServiceConsumableRecipeDto, bool> _f$prefill = Field(
    'prefill',
    _$prefill,
    opt: true,
    def: true,
  );
  static String? _$created(ServiceConsumableRecipeDto v) => v.created;
  static const Field<ServiceConsumableRecipeDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ServiceConsumableRecipeDto v) => v.updated;
  static const Field<ServiceConsumableRecipeDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ServiceConsumableRecipeDto> fields = const {
    #id: _f$id,
    #service: _f$service,
    #product: _f$product,
    #defaultQuantity: _f$defaultQuantity,
    #prefill: _f$prefill,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ServiceConsumableRecipeDto _instantiate(DecodingData data) {
    return ServiceConsumableRecipeDto(
      id: data.dec(_f$id),
      service: data.dec(_f$service),
      product: data.dec(_f$product),
      defaultQuantity: data.dec(_f$defaultQuantity),
      prefill: data.dec(_f$prefill),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServiceConsumableRecipeDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServiceConsumableRecipeDto>(map);
  }

  static ServiceConsumableRecipeDto fromJson(String json) {
    return ensureInitialized().decodeJson<ServiceConsumableRecipeDto>(json);
  }
}

mixin ServiceConsumableRecipeDtoMappable {
  String toJson() {
    return ServiceConsumableRecipeDtoMapper.ensureInitialized()
        .encodeJson<ServiceConsumableRecipeDto>(
          this as ServiceConsumableRecipeDto,
        );
  }

  Map<String, dynamic> toMap() {
    return ServiceConsumableRecipeDtoMapper.ensureInitialized()
        .encodeMap<ServiceConsumableRecipeDto>(
          this as ServiceConsumableRecipeDto,
        );
  }

  ServiceConsumableRecipeDtoCopyWith<
    ServiceConsumableRecipeDto,
    ServiceConsumableRecipeDto,
    ServiceConsumableRecipeDto
  >
  get copyWith =>
      _ServiceConsumableRecipeDtoCopyWithImpl<
        ServiceConsumableRecipeDto,
        ServiceConsumableRecipeDto
      >(this as ServiceConsumableRecipeDto, $identity, $identity);
  @override
  String toString() {
    return ServiceConsumableRecipeDtoMapper.ensureInitialized().stringifyValue(
      this as ServiceConsumableRecipeDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServiceConsumableRecipeDtoMapper.ensureInitialized().equalsValue(
      this as ServiceConsumableRecipeDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ServiceConsumableRecipeDtoMapper.ensureInitialized().hashValue(
      this as ServiceConsumableRecipeDto,
    );
  }
}

extension ServiceConsumableRecipeDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServiceConsumableRecipeDto, $Out> {
  ServiceConsumableRecipeDtoCopyWith<$R, ServiceConsumableRecipeDto, $Out>
  get $asServiceConsumableRecipeDto => $base.as(
    (v, t, t2) => _ServiceConsumableRecipeDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ServiceConsumableRecipeDtoCopyWith<
  $R,
  $In extends ServiceConsumableRecipeDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? service,
    String? product,
    num? defaultQuantity,
    bool? prefill,
    String? created,
    String? updated,
  });
  ServiceConsumableRecipeDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServiceConsumableRecipeDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServiceConsumableRecipeDto, $Out>
    implements
        ServiceConsumableRecipeDtoCopyWith<
          $R,
          ServiceConsumableRecipeDto,
          $Out
        > {
  _ServiceConsumableRecipeDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServiceConsumableRecipeDto> $mapper =
      ServiceConsumableRecipeDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? service,
    String? product,
    num? defaultQuantity,
    bool? prefill,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (service != null) #service: service,
      if (product != null) #product: product,
      if (defaultQuantity != null) #defaultQuantity: defaultQuantity,
      if (prefill != null) #prefill: prefill,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ServiceConsumableRecipeDto $make(CopyWithData data) =>
      ServiceConsumableRecipeDto(
        id: data.get(#id, or: $value.id),
        service: data.get(#service, or: $value.service),
        product: data.get(#product, or: $value.product),
        defaultQuantity: data.get(#defaultQuantity, or: $value.defaultQuantity),
        prefill: data.get(#prefill, or: $value.prefill),
        created: data.get(#created, or: $value.created),
        updated: data.get(#updated, or: $value.updated),
      );

  @override
  ServiceConsumableRecipeDtoCopyWith<$R2, ServiceConsumableRecipeDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ServiceConsumableRecipeDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

