// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'subscription_package_dto.dart';

class SubscriptionPackageDtoMapper
    extends ClassMapperBase<SubscriptionPackageDto> {
  SubscriptionPackageDtoMapper._();

  static SubscriptionPackageDtoMapper? _instance;
  static SubscriptionPackageDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubscriptionPackageDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SubscriptionPackageDto';

  static String _$id(SubscriptionPackageDto v) => v.id;
  static const Field<SubscriptionPackageDto, String> _f$id = Field('id', _$id);
  static String _$name(SubscriptionPackageDto v) => v.name;
  static const Field<SubscriptionPackageDto, String> _f$name = Field(
    'name',
    _$name,
  );
  static String _$description(SubscriptionPackageDto v) => v.description;
  static const Field<SubscriptionPackageDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
    def: '',
  );
  static num _$price(SubscriptionPackageDto v) => v.price;
  static const Field<SubscriptionPackageDto, num> _f$price = Field(
    'price',
    _$price,
    opt: true,
    def: 0,
  );
  static int _$intervalCount(SubscriptionPackageDto v) => v.intervalCount;
  static const Field<SubscriptionPackageDto, int> _f$intervalCount = Field(
    'intervalCount',
    _$intervalCount,
    opt: true,
    def: 1,
  );
  static String _$intervalUnit(SubscriptionPackageDto v) => v.intervalUnit;
  static const Field<SubscriptionPackageDto, String> _f$intervalUnit = Field(
    'intervalUnit',
    _$intervalUnit,
    opt: true,
    def: 'month',
  );
  static bool _$isPremade(SubscriptionPackageDto v) => v.isPremade;
  static const Field<SubscriptionPackageDto, bool> _f$isPremade = Field(
    'isPremade',
    _$isPremade,
    opt: true,
    def: true,
  );
  static String? _$organizationId(SubscriptionPackageDto v) => v.organizationId;
  static const Field<SubscriptionPackageDto, String> _f$organizationId = Field(
    'organizationId',
    _$organizationId,
    opt: true,
  );
  static bool _$isActive(SubscriptionPackageDto v) => v.isActive;
  static const Field<SubscriptionPackageDto, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static bool _$isDeleted(SubscriptionPackageDto v) => v.isDeleted;
  static const Field<SubscriptionPackageDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<SubscriptionPackageDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #description: _f$description,
    #price: _f$price,
    #intervalCount: _f$intervalCount,
    #intervalUnit: _f$intervalUnit,
    #isPremade: _f$isPremade,
    #organizationId: _f$organizationId,
    #isActive: _f$isActive,
    #isDeleted: _f$isDeleted,
  };

  static SubscriptionPackageDto _instantiate(DecodingData data) {
    return SubscriptionPackageDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      price: data.dec(_f$price),
      intervalCount: data.dec(_f$intervalCount),
      intervalUnit: data.dec(_f$intervalUnit),
      isPremade: data.dec(_f$isPremade),
      organizationId: data.dec(_f$organizationId),
      isActive: data.dec(_f$isActive),
      isDeleted: data.dec(_f$isDeleted),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SubscriptionPackageDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SubscriptionPackageDto>(map);
  }

  static SubscriptionPackageDto fromJson(String json) {
    return ensureInitialized().decodeJson<SubscriptionPackageDto>(json);
  }
}

mixin SubscriptionPackageDtoMappable {
  String toJson() {
    return SubscriptionPackageDtoMapper.ensureInitialized()
        .encodeJson<SubscriptionPackageDto>(this as SubscriptionPackageDto);
  }

  Map<String, dynamic> toMap() {
    return SubscriptionPackageDtoMapper.ensureInitialized()
        .encodeMap<SubscriptionPackageDto>(this as SubscriptionPackageDto);
  }

  SubscriptionPackageDtoCopyWith<
    SubscriptionPackageDto,
    SubscriptionPackageDto,
    SubscriptionPackageDto
  >
  get copyWith =>
      _SubscriptionPackageDtoCopyWithImpl<
        SubscriptionPackageDto,
        SubscriptionPackageDto
      >(this as SubscriptionPackageDto, $identity, $identity);
  @override
  String toString() {
    return SubscriptionPackageDtoMapper.ensureInitialized().stringifyValue(
      this as SubscriptionPackageDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return SubscriptionPackageDtoMapper.ensureInitialized().equalsValue(
      this as SubscriptionPackageDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SubscriptionPackageDtoMapper.ensureInitialized().hashValue(
      this as SubscriptionPackageDto,
    );
  }
}

extension SubscriptionPackageDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SubscriptionPackageDto, $Out> {
  SubscriptionPackageDtoCopyWith<$R, SubscriptionPackageDto, $Out>
  get $asSubscriptionPackageDto => $base.as(
    (v, t, t2) => _SubscriptionPackageDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SubscriptionPackageDtoCopyWith<
  $R,
  $In extends SubscriptionPackageDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? description,
    num? price,
    int? intervalCount,
    String? intervalUnit,
    bool? isPremade,
    String? organizationId,
    bool? isActive,
    bool? isDeleted,
  });
  SubscriptionPackageDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SubscriptionPackageDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SubscriptionPackageDto, $Out>
    implements
        SubscriptionPackageDtoCopyWith<$R, SubscriptionPackageDto, $Out> {
  _SubscriptionPackageDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SubscriptionPackageDto> $mapper =
      SubscriptionPackageDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? description,
    num? price,
    int? intervalCount,
    String? intervalUnit,
    bool? isPremade,
    Object? organizationId = $none,
    bool? isActive,
    bool? isDeleted,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (description != null) #description: description,
      if (price != null) #price: price,
      if (intervalCount != null) #intervalCount: intervalCount,
      if (intervalUnit != null) #intervalUnit: intervalUnit,
      if (isPremade != null) #isPremade: isPremade,
      if (organizationId != $none) #organizationId: organizationId,
      if (isActive != null) #isActive: isActive,
      if (isDeleted != null) #isDeleted: isDeleted,
    }),
  );
  @override
  SubscriptionPackageDto $make(CopyWithData data) => SubscriptionPackageDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    price: data.get(#price, or: $value.price),
    intervalCount: data.get(#intervalCount, or: $value.intervalCount),
    intervalUnit: data.get(#intervalUnit, or: $value.intervalUnit),
    isPremade: data.get(#isPremade, or: $value.isPremade),
    organizationId: data.get(#organizationId, or: $value.organizationId),
    isActive: data.get(#isActive, or: $value.isActive),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
  );

  @override
  SubscriptionPackageDtoCopyWith<$R2, SubscriptionPackageDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SubscriptionPackageDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

