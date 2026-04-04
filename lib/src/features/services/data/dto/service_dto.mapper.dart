// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service_dto.dart';

class ServiceDtoMapper extends ClassMapperBase<ServiceDto> {
  ServiceDtoMapper._();

  static ServiceDtoMapper? _instance;
  static ServiceDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServiceDtoMapper._());
      QuantityUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServiceDto';

  static String _$id(ServiceDto v) => v.id;
  static const Field<ServiceDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(ServiceDto v) => v.collectionId;
  static const Field<ServiceDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(ServiceDto v) => v.collectionName;
  static const Field<ServiceDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(ServiceDto v) => v.name;
  static const Field<ServiceDto, String> _f$name = Field('name', _$name);
  static String? _$description(ServiceDto v) => v.description;
  static const Field<ServiceDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$category(ServiceDto v) => v.category;
  static const Field<ServiceDto, String> _f$category = Field(
    'category',
    _$category,
    opt: true,
  );
  static String? _$categoryName(ServiceDto v) => v.categoryName;
  static const Field<ServiceDto, String> _f$categoryName = Field(
    'categoryName',
    _$categoryName,
    opt: true,
  );
  static String? _$branch(ServiceDto v) => v.branch;
  static const Field<ServiceDto, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static num _$price(ServiceDto v) => v.price;
  static const Field<ServiceDto, num> _f$price = Field(
    'price',
    _$price,
    opt: true,
    def: 0,
  );
  static bool _$isVariablePrice(ServiceDto v) => v.isVariablePrice;
  static const Field<ServiceDto, bool> _f$isVariablePrice = Field(
    'isVariablePrice',
    _$isVariablePrice,
    opt: true,
    def: false,
  );
  static num? _$estimatedDuration(ServiceDto v) => v.estimatedDuration;
  static const Field<ServiceDto, num> _f$estimatedDuration = Field(
    'estimatedDuration',
    _$estimatedDuration,
    opt: true,
  );
  static bool _$weightBased(ServiceDto v) => v.weightBased;
  static const Field<ServiceDto, bool> _f$weightBased = Field(
    'weightBased',
    _$weightBased,
    opt: true,
    def: false,
  );
  static bool _$showPrompt(ServiceDto v) => v.showPrompt;
  static const Field<ServiceDto, bool> _f$showPrompt = Field(
    'showPrompt',
    _$showPrompt,
    opt: true,
    def: false,
  );
  static int? _$maxQuantity(ServiceDto v) => v.maxQuantity;
  static const Field<ServiceDto, int> _f$maxQuantity = Field(
    'maxQuantity',
    _$maxQuantity,
    opt: true,
  );
  static bool _$allowExcess(ServiceDto v) => v.allowExcess;
  static const Field<ServiceDto, bool> _f$allowExcess = Field(
    'allowExcess',
    _$allowExcess,
    opt: true,
    def: false,
  );
  static String? _$quantityUnit(ServiceDto v) => v.quantityUnit;
  static const Field<ServiceDto, String> _f$quantityUnit = Field(
    'quantityUnit',
    _$quantityUnit,
    opt: true,
  );
  static QuantityUnit? _$quantityUnitExpanded(ServiceDto v) =>
      v.quantityUnitExpanded;
  static const Field<ServiceDto, QuantityUnit> _f$quantityUnitExpanded = Field(
    'quantityUnitExpanded',
    _$quantityUnitExpanded,
    opt: true,
  );
  static bool _$isDefault(ServiceDto v) => v.isDefault;
  static const Field<ServiceDto, bool> _f$isDefault = Field(
    'isDefault',
    _$isDefault,
    opt: true,
    def: false,
  );
  static bool _$isDeleted(ServiceDto v) => v.isDeleted;
  static const Field<ServiceDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(ServiceDto v) => v.created;
  static const Field<ServiceDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ServiceDto v) => v.updated;
  static const Field<ServiceDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ServiceDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #description: _f$description,
    #category: _f$category,
    #categoryName: _f$categoryName,
    #branch: _f$branch,
    #price: _f$price,
    #isVariablePrice: _f$isVariablePrice,
    #estimatedDuration: _f$estimatedDuration,
    #weightBased: _f$weightBased,
    #showPrompt: _f$showPrompt,
    #maxQuantity: _f$maxQuantity,
    #allowExcess: _f$allowExcess,
    #quantityUnit: _f$quantityUnit,
    #quantityUnitExpanded: _f$quantityUnitExpanded,
    #isDefault: _f$isDefault,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ServiceDto _instantiate(DecodingData data) {
    return ServiceDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      category: data.dec(_f$category),
      categoryName: data.dec(_f$categoryName),
      branch: data.dec(_f$branch),
      price: data.dec(_f$price),
      isVariablePrice: data.dec(_f$isVariablePrice),
      estimatedDuration: data.dec(_f$estimatedDuration),
      weightBased: data.dec(_f$weightBased),
      showPrompt: data.dec(_f$showPrompt),
      maxQuantity: data.dec(_f$maxQuantity),
      allowExcess: data.dec(_f$allowExcess),
      quantityUnit: data.dec(_f$quantityUnit),
      quantityUnitExpanded: data.dec(_f$quantityUnitExpanded),
      isDefault: data.dec(_f$isDefault),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServiceDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServiceDto>(map);
  }

  static ServiceDto fromJson(String json) {
    return ensureInitialized().decodeJson<ServiceDto>(json);
  }
}

mixin ServiceDtoMappable {
  String toJson() {
    return ServiceDtoMapper.ensureInitialized().encodeJson<ServiceDto>(
      this as ServiceDto,
    );
  }

  Map<String, dynamic> toMap() {
    return ServiceDtoMapper.ensureInitialized().encodeMap<ServiceDto>(
      this as ServiceDto,
    );
  }

  ServiceDtoCopyWith<ServiceDto, ServiceDto, ServiceDto> get copyWith =>
      _ServiceDtoCopyWithImpl<ServiceDto, ServiceDto>(
        this as ServiceDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServiceDtoMapper.ensureInitialized().stringifyValue(
      this as ServiceDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServiceDtoMapper.ensureInitialized().equalsValue(
      this as ServiceDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ServiceDtoMapper.ensureInitialized().hashValue(this as ServiceDto);
  }
}

extension ServiceDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServiceDto, $Out> {
  ServiceDtoCopyWith<$R, ServiceDto, $Out> get $asServiceDto =>
      $base.as((v, t, t2) => _ServiceDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServiceDtoCopyWith<$R, $In extends ServiceDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  QuantityUnitCopyWith<$R, QuantityUnit, QuantityUnit>?
  get quantityUnitExpanded;
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? description,
    String? category,
    String? categoryName,
    String? branch,
    num? price,
    bool? isVariablePrice,
    num? estimatedDuration,
    bool? weightBased,
    bool? showPrompt,
    int? maxQuantity,
    bool? allowExcess,
    String? quantityUnit,
    QuantityUnit? quantityUnitExpanded,
    bool? isDefault,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  ServiceDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServiceDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServiceDto, $Out>
    implements ServiceDtoCopyWith<$R, ServiceDto, $Out> {
  _ServiceDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServiceDto> $mapper =
      ServiceDtoMapper.ensureInitialized();
  @override
  QuantityUnitCopyWith<$R, QuantityUnit, QuantityUnit>?
  get quantityUnitExpanded => $value.quantityUnitExpanded?.copyWith.$chain(
    (v) => call(quantityUnitExpanded: v),
  );
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    Object? description = $none,
    Object? category = $none,
    Object? categoryName = $none,
    Object? branch = $none,
    num? price,
    bool? isVariablePrice,
    Object? estimatedDuration = $none,
    bool? weightBased,
    bool? showPrompt,
    Object? maxQuantity = $none,
    bool? allowExcess,
    Object? quantityUnit = $none,
    Object? quantityUnitExpanded = $none,
    bool? isDefault,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (category != $none) #category: category,
      if (categoryName != $none) #categoryName: categoryName,
      if (branch != $none) #branch: branch,
      if (price != null) #price: price,
      if (isVariablePrice != null) #isVariablePrice: isVariablePrice,
      if (estimatedDuration != $none) #estimatedDuration: estimatedDuration,
      if (weightBased != null) #weightBased: weightBased,
      if (showPrompt != null) #showPrompt: showPrompt,
      if (maxQuantity != $none) #maxQuantity: maxQuantity,
      if (allowExcess != null) #allowExcess: allowExcess,
      if (quantityUnit != $none) #quantityUnit: quantityUnit,
      if (quantityUnitExpanded != $none)
        #quantityUnitExpanded: quantityUnitExpanded,
      if (isDefault != null) #isDefault: isDefault,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ServiceDto $make(CopyWithData data) => ServiceDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    category: data.get(#category, or: $value.category),
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
    quantityUnit: data.get(#quantityUnit, or: $value.quantityUnit),
    quantityUnitExpanded: data.get(
      #quantityUnitExpanded,
      or: $value.quantityUnitExpanded,
    ),
    isDefault: data.get(#isDefault, or: $value.isDefault),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ServiceDtoCopyWith<$R2, ServiceDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServiceDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

