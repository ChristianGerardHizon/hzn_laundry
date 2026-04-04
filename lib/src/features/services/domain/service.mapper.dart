// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service.dart';

class ServiceMapper extends ClassMapperBase<Service> {
  ServiceMapper._();

  static ServiceMapper? _instance;
  static ServiceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServiceMapper._());
      QuantityUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Service';

  static String _$id(Service v) => v.id;
  static const Field<Service, String> _f$id = Field('id', _$id);
  static String _$name(Service v) => v.name;
  static const Field<Service, String> _f$name = Field('name', _$name);
  static String? _$description(Service v) => v.description;
  static const Field<Service, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$categoryId(Service v) => v.categoryId;
  static const Field<Service, String> _f$categoryId = Field(
    'categoryId',
    _$categoryId,
    opt: true,
  );
  static String? _$categoryName(Service v) => v.categoryName;
  static const Field<Service, String> _f$categoryName = Field(
    'categoryName',
    _$categoryName,
    opt: true,
  );
  static String? _$branch(Service v) => v.branch;
  static const Field<Service, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static num _$price(Service v) => v.price;
  static const Field<Service, num> _f$price = Field(
    'price',
    _$price,
    opt: true,
    def: 0,
  );
  static bool _$isVariablePrice(Service v) => v.isVariablePrice;
  static const Field<Service, bool> _f$isVariablePrice = Field(
    'isVariablePrice',
    _$isVariablePrice,
    opt: true,
    def: false,
  );
  static num? _$estimatedDuration(Service v) => v.estimatedDuration;
  static const Field<Service, num> _f$estimatedDuration = Field(
    'estimatedDuration',
    _$estimatedDuration,
    opt: true,
  );
  static bool _$weightBased(Service v) => v.weightBased;
  static const Field<Service, bool> _f$weightBased = Field(
    'weightBased',
    _$weightBased,
    opt: true,
    def: false,
  );
  static bool _$showPrompt(Service v) => v.showPrompt;
  static const Field<Service, bool> _f$showPrompt = Field(
    'showPrompt',
    _$showPrompt,
    opt: true,
    def: false,
  );
  static int? _$maxQuantity(Service v) => v.maxQuantity;
  static const Field<Service, int> _f$maxQuantity = Field(
    'maxQuantity',
    _$maxQuantity,
    opt: true,
  );
  static bool _$allowExcess(Service v) => v.allowExcess;
  static const Field<Service, bool> _f$allowExcess = Field(
    'allowExcess',
    _$allowExcess,
    opt: true,
    def: false,
  );
  static String? _$quantityUnitId(Service v) => v.quantityUnitId;
  static const Field<Service, String> _f$quantityUnitId = Field(
    'quantityUnitId',
    _$quantityUnitId,
    opt: true,
  );
  static QuantityUnit? _$quantityUnit(Service v) => v.quantityUnit;
  static const Field<Service, QuantityUnit> _f$quantityUnit = Field(
    'quantityUnit',
    _$quantityUnit,
    opt: true,
  );
  static bool _$isDefault(Service v) => v.isDefault;
  static const Field<Service, bool> _f$isDefault = Field(
    'isDefault',
    _$isDefault,
    opt: true,
    def: false,
  );
  static bool _$isDeleted(Service v) => v.isDeleted;
  static const Field<Service, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Service v) => v.created;
  static const Field<Service, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Service v) => v.updated;
  static const Field<Service, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Service> fields = const {
    #id: _f$id,
    #name: _f$name,
    #description: _f$description,
    #categoryId: _f$categoryId,
    #categoryName: _f$categoryName,
    #branch: _f$branch,
    #price: _f$price,
    #isVariablePrice: _f$isVariablePrice,
    #estimatedDuration: _f$estimatedDuration,
    #weightBased: _f$weightBased,
    #showPrompt: _f$showPrompt,
    #maxQuantity: _f$maxQuantity,
    #allowExcess: _f$allowExcess,
    #quantityUnitId: _f$quantityUnitId,
    #quantityUnit: _f$quantityUnit,
    #isDefault: _f$isDefault,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Service _instantiate(DecodingData data) {
    return Service(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      categoryId: data.dec(_f$categoryId),
      categoryName: data.dec(_f$categoryName),
      branch: data.dec(_f$branch),
      price: data.dec(_f$price),
      isVariablePrice: data.dec(_f$isVariablePrice),
      estimatedDuration: data.dec(_f$estimatedDuration),
      weightBased: data.dec(_f$weightBased),
      showPrompt: data.dec(_f$showPrompt),
      maxQuantity: data.dec(_f$maxQuantity),
      allowExcess: data.dec(_f$allowExcess),
      quantityUnitId: data.dec(_f$quantityUnitId),
      quantityUnit: data.dec(_f$quantityUnit),
      isDefault: data.dec(_f$isDefault),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Service fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Service>(map);
  }

  static Service fromJson(String json) {
    return ensureInitialized().decodeJson<Service>(json);
  }
}

mixin ServiceMappable {
  String toJson() {
    return ServiceMapper.ensureInitialized().encodeJson<Service>(
      this as Service,
    );
  }

  Map<String, dynamic> toMap() {
    return ServiceMapper.ensureInitialized().encodeMap<Service>(
      this as Service,
    );
  }

  ServiceCopyWith<Service, Service, Service> get copyWith =>
      _ServiceCopyWithImpl<Service, Service>(
        this as Service,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServiceMapper.ensureInitialized().stringifyValue(this as Service);
  }

  @override
  bool operator ==(Object other) {
    return ServiceMapper.ensureInitialized().equalsValue(
      this as Service,
      other,
    );
  }

  @override
  int get hashCode {
    return ServiceMapper.ensureInitialized().hashValue(this as Service);
  }
}

extension ServiceValueCopy<$R, $Out> on ObjectCopyWith<$R, Service, $Out> {
  ServiceCopyWith<$R, Service, $Out> get $asService =>
      $base.as((v, t, t2) => _ServiceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServiceCopyWith<$R, $In extends Service, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  QuantityUnitCopyWith<$R, QuantityUnit, QuantityUnit>? get quantityUnit;
  $R call({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    String? branch,
    num? price,
    bool? isVariablePrice,
    num? estimatedDuration,
    bool? weightBased,
    bool? showPrompt,
    int? maxQuantity,
    bool? allowExcess,
    String? quantityUnitId,
    QuantityUnit? quantityUnit,
    bool? isDefault,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  ServiceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServiceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Service, $Out>
    implements ServiceCopyWith<$R, Service, $Out> {
  _ServiceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Service> $mapper =
      ServiceMapper.ensureInitialized();
  @override
  QuantityUnitCopyWith<$R, QuantityUnit, QuantityUnit>? get quantityUnit =>
      $value.quantityUnit?.copyWith.$chain((v) => call(quantityUnit: v));
  @override
  $R call({
    String? id,
    String? name,
    Object? description = $none,
    Object? categoryId = $none,
    Object? categoryName = $none,
    Object? branch = $none,
    num? price,
    bool? isVariablePrice,
    Object? estimatedDuration = $none,
    bool? weightBased,
    bool? showPrompt,
    Object? maxQuantity = $none,
    bool? allowExcess,
    Object? quantityUnitId = $none,
    Object? quantityUnit = $none,
    bool? isDefault,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (categoryId != $none) #categoryId: categoryId,
      if (categoryName != $none) #categoryName: categoryName,
      if (branch != $none) #branch: branch,
      if (price != null) #price: price,
      if (isVariablePrice != null) #isVariablePrice: isVariablePrice,
      if (estimatedDuration != $none) #estimatedDuration: estimatedDuration,
      if (weightBased != null) #weightBased: weightBased,
      if (showPrompt != null) #showPrompt: showPrompt,
      if (maxQuantity != $none) #maxQuantity: maxQuantity,
      if (allowExcess != null) #allowExcess: allowExcess,
      if (quantityUnitId != $none) #quantityUnitId: quantityUnitId,
      if (quantityUnit != $none) #quantityUnit: quantityUnit,
      if (isDefault != null) #isDefault: isDefault,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Service $make(CopyWithData data) => Service(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    categoryId: data.get(#categoryId, or: $value.categoryId),
    categoryName: data.get(#categoryName, or: $value.categoryName),
    branch: data.get(#branch, or: $value.branch),
    price: data.get(#price, or: $value.price),
    isVariablePrice: data.get(#isVariablePrice, or: $value.isVariablePrice),
    estimatedDuration: data.get(
      #estimatedDuration,
      or: $value.estimatedDuration,
    ),
    weightBased: data.get(#weightBased, or: $value.weightBased),
    showPrompt: data.get(#showPrompt, or: $value.showPrompt),
    maxQuantity: data.get(#maxQuantity, or: $value.maxQuantity),
    allowExcess: data.get(#allowExcess, or: $value.allowExcess),
    quantityUnitId: data.get(#quantityUnitId, or: $value.quantityUnitId),
    quantityUnit: data.get(#quantityUnit, or: $value.quantityUnit),
    isDefault: data.get(#isDefault, or: $value.isDefault),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ServiceCopyWith<$R2, Service, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ServiceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

