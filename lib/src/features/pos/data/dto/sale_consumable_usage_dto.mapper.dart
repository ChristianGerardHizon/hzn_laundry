// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale_consumable_usage_dto.dart';

class SaleConsumableUsageDtoMapper
    extends ClassMapperBase<SaleConsumableUsageDto> {
  SaleConsumableUsageDtoMapper._();

  static SaleConsumableUsageDtoMapper? _instance;
  static SaleConsumableUsageDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleConsumableUsageDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SaleConsumableUsageDto';

  static String _$id(SaleConsumableUsageDto v) => v.id;
  static const Field<SaleConsumableUsageDto, String> _f$id = Field('id', _$id);
  static String _$sale(SaleConsumableUsageDto v) => v.sale;
  static const Field<SaleConsumableUsageDto, String> _f$sale = Field(
    'sale',
    _$sale,
  );
  static String _$product(SaleConsumableUsageDto v) => v.product;
  static const Field<SaleConsumableUsageDto, String> _f$product = Field(
    'product',
    _$product,
  );
  static String _$productName(SaleConsumableUsageDto v) => v.productName;
  static const Field<SaleConsumableUsageDto, String> _f$productName = Field(
    'productName',
    _$productName,
  );
  static num _$quantity(SaleConsumableUsageDto v) => v.quantity;
  static const Field<SaleConsumableUsageDto, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static String? _$unitLabel(SaleConsumableUsageDto v) => v.unitLabel;
  static const Field<SaleConsumableUsageDto, String> _f$unitLabel = Field(
    'unitLabel',
    _$unitLabel,
    opt: true,
  );
  static num _$unitCost(SaleConsumableUsageDto v) => v.unitCost;
  static const Field<SaleConsumableUsageDto, num> _f$unitCost = Field(
    'unitCost',
    _$unitCost,
    opt: true,
    def: 0,
  );
  static num _$cost(SaleConsumableUsageDto v) => v.cost;
  static const Field<SaleConsumableUsageDto, num> _f$cost = Field(
    'cost',
    _$cost,
    opt: true,
    def: 0,
  );
  static String? _$created(SaleConsumableUsageDto v) => v.created;
  static const Field<SaleConsumableUsageDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(SaleConsumableUsageDto v) => v.updated;
  static const Field<SaleConsumableUsageDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<SaleConsumableUsageDto> fields = const {
    #id: _f$id,
    #sale: _f$sale,
    #product: _f$product,
    #productName: _f$productName,
    #quantity: _f$quantity,
    #unitLabel: _f$unitLabel,
    #unitCost: _f$unitCost,
    #cost: _f$cost,
    #created: _f$created,
    #updated: _f$updated,
  };

  static SaleConsumableUsageDto _instantiate(DecodingData data) {
    return SaleConsumableUsageDto(
      id: data.dec(_f$id),
      sale: data.dec(_f$sale),
      product: data.dec(_f$product),
      productName: data.dec(_f$productName),
      quantity: data.dec(_f$quantity),
      unitLabel: data.dec(_f$unitLabel),
      unitCost: data.dec(_f$unitCost),
      cost: data.dec(_f$cost),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SaleConsumableUsageDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SaleConsumableUsageDto>(map);
  }

  static SaleConsumableUsageDto fromJson(String json) {
    return ensureInitialized().decodeJson<SaleConsumableUsageDto>(json);
  }
}

mixin SaleConsumableUsageDtoMappable {
  String toJson() {
    return SaleConsumableUsageDtoMapper.ensureInitialized()
        .encodeJson<SaleConsumableUsageDto>(this as SaleConsumableUsageDto);
  }

  Map<String, dynamic> toMap() {
    return SaleConsumableUsageDtoMapper.ensureInitialized()
        .encodeMap<SaleConsumableUsageDto>(this as SaleConsumableUsageDto);
  }

  SaleConsumableUsageDtoCopyWith<
    SaleConsumableUsageDto,
    SaleConsumableUsageDto,
    SaleConsumableUsageDto
  >
  get copyWith =>
      _SaleConsumableUsageDtoCopyWithImpl<
        SaleConsumableUsageDto,
        SaleConsumableUsageDto
      >(this as SaleConsumableUsageDto, $identity, $identity);
  @override
  String toString() {
    return SaleConsumableUsageDtoMapper.ensureInitialized().stringifyValue(
      this as SaleConsumableUsageDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return SaleConsumableUsageDtoMapper.ensureInitialized().equalsValue(
      this as SaleConsumableUsageDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SaleConsumableUsageDtoMapper.ensureInitialized().hashValue(
      this as SaleConsumableUsageDto,
    );
  }
}

extension SaleConsumableUsageDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SaleConsumableUsageDto, $Out> {
  SaleConsumableUsageDtoCopyWith<$R, SaleConsumableUsageDto, $Out>
  get $asSaleConsumableUsageDto => $base.as(
    (v, t, t2) => _SaleConsumableUsageDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SaleConsumableUsageDtoCopyWith<
  $R,
  $In extends SaleConsumableUsageDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? sale,
    String? product,
    String? productName,
    num? quantity,
    String? unitLabel,
    num? unitCost,
    num? cost,
    String? created,
    String? updated,
  });
  SaleConsumableUsageDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SaleConsumableUsageDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SaleConsumableUsageDto, $Out>
    implements
        SaleConsumableUsageDtoCopyWith<$R, SaleConsumableUsageDto, $Out> {
  _SaleConsumableUsageDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SaleConsumableUsageDto> $mapper =
      SaleConsumableUsageDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? sale,
    String? product,
    String? productName,
    num? quantity,
    Object? unitLabel = $none,
    num? unitCost,
    num? cost,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (sale != null) #sale: sale,
      if (product != null) #product: product,
      if (productName != null) #productName: productName,
      if (quantity != null) #quantity: quantity,
      if (unitLabel != $none) #unitLabel: unitLabel,
      if (unitCost != null) #unitCost: unitCost,
      if (cost != null) #cost: cost,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  SaleConsumableUsageDto $make(CopyWithData data) => SaleConsumableUsageDto(
    id: data.get(#id, or: $value.id),
    sale: data.get(#sale, or: $value.sale),
    product: data.get(#product, or: $value.product),
    productName: data.get(#productName, or: $value.productName),
    quantity: data.get(#quantity, or: $value.quantity),
    unitLabel: data.get(#unitLabel, or: $value.unitLabel),
    unitCost: data.get(#unitCost, or: $value.unitCost),
    cost: data.get(#cost, or: $value.cost),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  SaleConsumableUsageDtoCopyWith<$R2, SaleConsumableUsageDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SaleConsumableUsageDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

