// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'subscription_package.dart';

class SubscriptionPackageMapper extends ClassMapperBase<SubscriptionPackage> {
  SubscriptionPackageMapper._();

  static SubscriptionPackageMapper? _instance;
  static SubscriptionPackageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubscriptionPackageMapper._());
      BillingIntervalUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SubscriptionPackage';

  static String _$id(SubscriptionPackage v) => v.id;
  static const Field<SubscriptionPackage, String> _f$id = Field('id', _$id);
  static String _$name(SubscriptionPackage v) => v.name;
  static const Field<SubscriptionPackage, String> _f$name = Field(
    'name',
    _$name,
  );
  static String _$description(SubscriptionPackage v) => v.description;
  static const Field<SubscriptionPackage, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
    def: '',
  );
  static num _$price(SubscriptionPackage v) => v.price;
  static const Field<SubscriptionPackage, num> _f$price = Field(
    'price',
    _$price,
  );
  static int _$intervalCount(SubscriptionPackage v) => v.intervalCount;
  static const Field<SubscriptionPackage, int> _f$intervalCount = Field(
    'intervalCount',
    _$intervalCount,
  );
  static BillingIntervalUnit _$intervalUnit(SubscriptionPackage v) =>
      v.intervalUnit;
  static const Field<SubscriptionPackage, BillingIntervalUnit> _f$intervalUnit =
      Field('intervalUnit', _$intervalUnit);
  static bool _$isPremade(SubscriptionPackage v) => v.isPremade;
  static const Field<SubscriptionPackage, bool> _f$isPremade = Field(
    'isPremade',
    _$isPremade,
    opt: true,
    def: true,
  );
  static String? _$organizationId(SubscriptionPackage v) => v.organizationId;
  static const Field<SubscriptionPackage, String> _f$organizationId = Field(
    'organizationId',
    _$organizationId,
    opt: true,
  );
  static bool _$isActive(SubscriptionPackage v) => v.isActive;
  static const Field<SubscriptionPackage, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static bool _$isDeleted(SubscriptionPackage v) => v.isDeleted;
  static const Field<SubscriptionPackage, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<SubscriptionPackage> fields = const {
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

  static SubscriptionPackage _instantiate(DecodingData data) {
    return SubscriptionPackage(
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

  static SubscriptionPackage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SubscriptionPackage>(map);
  }

  static SubscriptionPackage fromJson(String json) {
    return ensureInitialized().decodeJson<SubscriptionPackage>(json);
  }
}

mixin SubscriptionPackageMappable {
  String toJson() {
    return SubscriptionPackageMapper.ensureInitialized()
        .encodeJson<SubscriptionPackage>(this as SubscriptionPackage);
  }

  Map<String, dynamic> toMap() {
    return SubscriptionPackageMapper.ensureInitialized()
        .encodeMap<SubscriptionPackage>(this as SubscriptionPackage);
  }

  SubscriptionPackageCopyWith<
    SubscriptionPackage,
    SubscriptionPackage,
    SubscriptionPackage
  >
  get copyWith =>
      _SubscriptionPackageCopyWithImpl<
        SubscriptionPackage,
        SubscriptionPackage
      >(this as SubscriptionPackage, $identity, $identity);
  @override
  String toString() {
    return SubscriptionPackageMapper.ensureInitialized().stringifyValue(
      this as SubscriptionPackage,
    );
  }

  @override
  bool operator ==(Object other) {
    return SubscriptionPackageMapper.ensureInitialized().equalsValue(
      this as SubscriptionPackage,
      other,
    );
  }

  @override
  int get hashCode {
    return SubscriptionPackageMapper.ensureInitialized().hashValue(
      this as SubscriptionPackage,
    );
  }
}

extension SubscriptionPackageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SubscriptionPackage, $Out> {
  SubscriptionPackageCopyWith<$R, SubscriptionPackage, $Out>
  get $asSubscriptionPackage => $base.as(
    (v, t, t2) => _SubscriptionPackageCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SubscriptionPackageCopyWith<
  $R,
  $In extends SubscriptionPackage,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? description,
    num? price,
    int? intervalCount,
    BillingIntervalUnit? intervalUnit,
    bool? isPremade,
    String? organizationId,
    bool? isActive,
    bool? isDeleted,
  });
  SubscriptionPackageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SubscriptionPackageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SubscriptionPackage, $Out>
    implements SubscriptionPackageCopyWith<$R, SubscriptionPackage, $Out> {
  _SubscriptionPackageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SubscriptionPackage> $mapper =
      SubscriptionPackageMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? description,
    num? price,
    int? intervalCount,
    BillingIntervalUnit? intervalUnit,
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
  SubscriptionPackage $make(CopyWithData data) => SubscriptionPackage(
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
  SubscriptionPackageCopyWith<$R2, SubscriptionPackage, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SubscriptionPackageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

