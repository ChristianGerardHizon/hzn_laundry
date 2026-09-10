// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service_consumable_recipe.dart';

class ServiceConsumableRecipeMapper
    extends ClassMapperBase<ServiceConsumableRecipe> {
  ServiceConsumableRecipeMapper._();

  static ServiceConsumableRecipeMapper? _instance;
  static ServiceConsumableRecipeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = ServiceConsumableRecipeMapper._(),
      );
      ProductMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServiceConsumableRecipe';

  static String _$id(ServiceConsumableRecipe v) => v.id;
  static const Field<ServiceConsumableRecipe, String> _f$id = Field('id', _$id);
  static String _$serviceId(ServiceConsumableRecipe v) => v.serviceId;
  static const Field<ServiceConsumableRecipe, String> _f$serviceId = Field(
    'serviceId',
    _$serviceId,
  );
  static String _$productId(ServiceConsumableRecipe v) => v.productId;
  static const Field<ServiceConsumableRecipe, String> _f$productId = Field(
    'productId',
    _$productId,
  );
  static num _$defaultQuantity(ServiceConsumableRecipe v) => v.defaultQuantity;
  static const Field<ServiceConsumableRecipe, num> _f$defaultQuantity = Field(
    'defaultQuantity',
    _$defaultQuantity,
    opt: true,
    def: 0,
  );
  static bool _$prefill(ServiceConsumableRecipe v) => v.prefill;
  static const Field<ServiceConsumableRecipe, bool> _f$prefill = Field(
    'prefill',
    _$prefill,
    opt: true,
    def: true,
  );
  static Product? _$product(ServiceConsumableRecipe v) => v.product;
  static const Field<ServiceConsumableRecipe, Product> _f$product = Field(
    'product',
    _$product,
    opt: true,
  );
  static DateTime? _$created(ServiceConsumableRecipe v) => v.created;
  static const Field<ServiceConsumableRecipe, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(ServiceConsumableRecipe v) => v.updated;
  static const Field<ServiceConsumableRecipe, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ServiceConsumableRecipe> fields = const {
    #id: _f$id,
    #serviceId: _f$serviceId,
    #productId: _f$productId,
    #defaultQuantity: _f$defaultQuantity,
    #prefill: _f$prefill,
    #product: _f$product,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ServiceConsumableRecipe _instantiate(DecodingData data) {
    return ServiceConsumableRecipe(
      id: data.dec(_f$id),
      serviceId: data.dec(_f$serviceId),
      productId: data.dec(_f$productId),
      defaultQuantity: data.dec(_f$defaultQuantity),
      prefill: data.dec(_f$prefill),
      product: data.dec(_f$product),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServiceConsumableRecipe fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServiceConsumableRecipe>(map);
  }

  static ServiceConsumableRecipe fromJson(String json) {
    return ensureInitialized().decodeJson<ServiceConsumableRecipe>(json);
  }
}

mixin ServiceConsumableRecipeMappable {
  String toJson() {
    return ServiceConsumableRecipeMapper.ensureInitialized()
        .encodeJson<ServiceConsumableRecipe>(this as ServiceConsumableRecipe);
  }

  Map<String, dynamic> toMap() {
    return ServiceConsumableRecipeMapper.ensureInitialized()
        .encodeMap<ServiceConsumableRecipe>(this as ServiceConsumableRecipe);
  }

  ServiceConsumableRecipeCopyWith<
    ServiceConsumableRecipe,
    ServiceConsumableRecipe,
    ServiceConsumableRecipe
  >
  get copyWith =>
      _ServiceConsumableRecipeCopyWithImpl<
        ServiceConsumableRecipe,
        ServiceConsumableRecipe
      >(this as ServiceConsumableRecipe, $identity, $identity);
  @override
  String toString() {
    return ServiceConsumableRecipeMapper.ensureInitialized().stringifyValue(
      this as ServiceConsumableRecipe,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServiceConsumableRecipeMapper.ensureInitialized().equalsValue(
      this as ServiceConsumableRecipe,
      other,
    );
  }

  @override
  int get hashCode {
    return ServiceConsumableRecipeMapper.ensureInitialized().hashValue(
      this as ServiceConsumableRecipe,
    );
  }
}

extension ServiceConsumableRecipeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServiceConsumableRecipe, $Out> {
  ServiceConsumableRecipeCopyWith<$R, ServiceConsumableRecipe, $Out>
  get $asServiceConsumableRecipe => $base.as(
    (v, t, t2) => _ServiceConsumableRecipeCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ServiceConsumableRecipeCopyWith<
  $R,
  $In extends ServiceConsumableRecipe,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ProductCopyWith<$R, Product, Product>? get product;
  $R call({
    String? id,
    String? serviceId,
    String? productId,
    num? defaultQuantity,
    bool? prefill,
    Product? product,
    DateTime? created,
    DateTime? updated,
  });
  ServiceConsumableRecipeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServiceConsumableRecipeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServiceConsumableRecipe, $Out>
    implements
        ServiceConsumableRecipeCopyWith<$R, ServiceConsumableRecipe, $Out> {
  _ServiceConsumableRecipeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServiceConsumableRecipe> $mapper =
      ServiceConsumableRecipeMapper.ensureInitialized();
  @override
  ProductCopyWith<$R, Product, Product>? get product =>
      $value.product?.copyWith.$chain((v) => call(product: v));
  @override
  $R call({
    String? id,
    String? serviceId,
    String? productId,
    num? defaultQuantity,
    bool? prefill,
    Object? product = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (serviceId != null) #serviceId: serviceId,
      if (productId != null) #productId: productId,
      if (defaultQuantity != null) #defaultQuantity: defaultQuantity,
      if (prefill != null) #prefill: prefill,
      if (product != $none) #product: product,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ServiceConsumableRecipe $make(CopyWithData data) => ServiceConsumableRecipe(
    id: data.get(#id, or: $value.id),
    serviceId: data.get(#serviceId, or: $value.serviceId),
    productId: data.get(#productId, or: $value.productId),
    defaultQuantity: data.get(#defaultQuantity, or: $value.defaultQuantity),
    prefill: data.get(#prefill, or: $value.prefill),
    product: data.get(#product, or: $value.product),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ServiceConsumableRecipeCopyWith<$R2, ServiceConsumableRecipe, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ServiceConsumableRecipeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

