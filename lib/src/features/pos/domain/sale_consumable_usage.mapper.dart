// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale_consumable_usage.dart';

class SaleConsumableUsageMapper extends ClassMapperBase<SaleConsumableUsage> {
  SaleConsumableUsageMapper._();

  static SaleConsumableUsageMapper? _instance;
  static SaleConsumableUsageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleConsumableUsageMapper._());
      ProductMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SaleConsumableUsage';

  static String _$id(SaleConsumableUsage v) => v.id;
  static const Field<SaleConsumableUsage, String> _f$id = Field('id', _$id);
  static String _$saleId(SaleConsumableUsage v) => v.saleId;
  static const Field<SaleConsumableUsage, String> _f$saleId = Field(
    'saleId',
    _$saleId,
  );
  static String _$productId(SaleConsumableUsage v) => v.productId;
  static const Field<SaleConsumableUsage, String> _f$productId = Field(
    'productId',
    _$productId,
  );
  static String _$productName(SaleConsumableUsage v) => v.productName;
  static const Field<SaleConsumableUsage, String> _f$productName = Field(
    'productName',
    _$productName,
  );
  static num _$quantity(SaleConsumableUsage v) => v.quantity;
  static const Field<SaleConsumableUsage, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static String? _$unitLabel(SaleConsumableUsage v) => v.unitLabel;
  static const Field<SaleConsumableUsage, String> _f$unitLabel = Field(
    'unitLabel',
    _$unitLabel,
    opt: true,
  );
  static num _$unitCost(SaleConsumableUsage v) => v.unitCost;
  static const Field<SaleConsumableUsage, num> _f$unitCost = Field(
    'unitCost',
    _$unitCost,
    opt: true,
    def: 0,
  );
  static num _$cost(SaleConsumableUsage v) => v.cost;
  static const Field<SaleConsumableUsage, num> _f$cost = Field(
    'cost',
    _$cost,
    opt: true,
    def: 0,
  );
  static Product? _$product(SaleConsumableUsage v) => v.product;
  static const Field<SaleConsumableUsage, Product> _f$product = Field(
    'product',
    _$product,
    opt: true,
  );
  static DateTime? _$created(SaleConsumableUsage v) => v.created;
  static const Field<SaleConsumableUsage, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(SaleConsumableUsage v) => v.updated;
  static const Field<SaleConsumableUsage, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<SaleConsumableUsage> fields = const {
    #id: _f$id,
    #saleId: _f$saleId,
    #productId: _f$productId,
    #productName: _f$productName,
    #quantity: _f$quantity,
    #unitLabel: _f$unitLabel,
    #unitCost: _f$unitCost,
    #cost: _f$cost,
    #product: _f$product,
    #created: _f$created,
    #updated: _f$updated,
  };

  static SaleConsumableUsage _instantiate(DecodingData data) {
    return SaleConsumableUsage(
      id: data.dec(_f$id),
      saleId: data.dec(_f$saleId),
      productId: data.dec(_f$productId),
      productName: data.dec(_f$productName),
      quantity: data.dec(_f$quantity),
      unitLabel: data.dec(_f$unitLabel),
      unitCost: data.dec(_f$unitCost),
      cost: data.dec(_f$cost),
      product: data.dec(_f$product),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SaleConsumableUsage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SaleConsumableUsage>(map);
  }

  static SaleConsumableUsage fromJson(String json) {
    return ensureInitialized().decodeJson<SaleConsumableUsage>(json);
  }
}

mixin SaleConsumableUsageMappable {
  String toJson() {
    return SaleConsumableUsageMapper.ensureInitialized()
        .encodeJson<SaleConsumableUsage>(this as SaleConsumableUsage);
  }

  Map<String, dynamic> toMap() {
    return SaleConsumableUsageMapper.ensureInitialized()
        .encodeMap<SaleConsumableUsage>(this as SaleConsumableUsage);
  }

  SaleConsumableUsageCopyWith<
    SaleConsumableUsage,
    SaleConsumableUsage,
    SaleConsumableUsage
  >
  get copyWith =>
      _SaleConsumableUsageCopyWithImpl<
        SaleConsumableUsage,
        SaleConsumableUsage
      >(this as SaleConsumableUsage, $identity, $identity);
  @override
  String toString() {
    return SaleConsumableUsageMapper.ensureInitialized().stringifyValue(
      this as SaleConsumableUsage,
    );
  }

  @override
  bool operator ==(Object other) {
    return SaleConsumableUsageMapper.ensureInitialized().equalsValue(
      this as SaleConsumableUsage,
      other,
    );
  }

  @override
  int get hashCode {
    return SaleConsumableUsageMapper.ensureInitialized().hashValue(
      this as SaleConsumableUsage,
    );
  }
}

extension SaleConsumableUsageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SaleConsumableUsage, $Out> {
  SaleConsumableUsageCopyWith<$R, SaleConsumableUsage, $Out>
  get $asSaleConsumableUsage => $base.as(
    (v, t, t2) => _SaleConsumableUsageCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SaleConsumableUsageCopyWith<
  $R,
  $In extends SaleConsumableUsage,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ProductCopyWith<$R, Product, Product>? get product;
  $R call({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    num? quantity,
    String? unitLabel,
    num? unitCost,
    num? cost,
    Product? product,
    DateTime? created,
    DateTime? updated,
  });
  SaleConsumableUsageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SaleConsumableUsageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SaleConsumableUsage, $Out>
    implements SaleConsumableUsageCopyWith<$R, SaleConsumableUsage, $Out> {
  _SaleConsumableUsageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SaleConsumableUsage> $mapper =
      SaleConsumableUsageMapper.ensureInitialized();
  @override
  ProductCopyWith<$R, Product, Product>? get product =>
      $value.product?.copyWith.$chain((v) => call(product: v));
  @override
  $R call({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    num? quantity,
    Object? unitLabel = $none,
    num? unitCost,
    num? cost,
    Object? product = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (saleId != null) #saleId: saleId,
      if (productId != null) #productId: productId,
      if (productName != null) #productName: productName,
      if (quantity != null) #quantity: quantity,
      if (unitLabel != $none) #unitLabel: unitLabel,
      if (unitCost != null) #unitCost: unitCost,
      if (cost != null) #cost: cost,
      if (product != $none) #product: product,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  SaleConsumableUsage $make(CopyWithData data) => SaleConsumableUsage(
    id: data.get(#id, or: $value.id),
    saleId: data.get(#saleId, or: $value.saleId),
    productId: data.get(#productId, or: $value.productId),
    productName: data.get(#productName, or: $value.productName),
    quantity: data.get(#quantity, or: $value.quantity),
    unitLabel: data.get(#unitLabel, or: $value.unitLabel),
    unitCost: data.get(#unitCost, or: $value.unitCost),
    cost: data.get(#cost, or: $value.cost),
    product: data.get(#product, or: $value.product),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  SaleConsumableUsageCopyWith<$R2, SaleConsumableUsage, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SaleConsumableUsageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

