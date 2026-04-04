// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_service_item.dart';

class CartServiceItemMapper extends ClassMapperBase<CartServiceItem> {
  CartServiceItemMapper._();

  static CartServiceItemMapper? _instance;
  static CartServiceItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartServiceItemMapper._());
      ServiceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartServiceItem';

  static String _$id(CartServiceItem v) => v.id;
  static const Field<CartServiceItem, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: '',
  );
  static String _$cartId(CartServiceItem v) => v.cartId;
  static const Field<CartServiceItem, String> _f$cartId = Field(
    'cartId',
    _$cartId,
    opt: true,
    def: '',
  );
  static String _$serviceId(CartServiceItem v) => v.serviceId;
  static const Field<CartServiceItem, String> _f$serviceId = Field(
    'serviceId',
    _$serviceId,
    opt: true,
    def: '',
  );
  static Service? _$service(CartServiceItem v) => v.service;
  static const Field<CartServiceItem, Service> _f$service = Field(
    'service',
    _$service,
    opt: true,
  );
  static num _$quantity(CartServiceItem v) => v.quantity;
  static const Field<CartServiceItem, num> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
    def: 1,
  );
  static num? _$customPrice(CartServiceItem v) => v.customPrice;
  static const Field<CartServiceItem, num> _f$customPrice = Field(
    'customPrice',
    _$customPrice,
    opt: true,
  );
  static DateTime? _$created(CartServiceItem v) => v.created;
  static const Field<CartServiceItem, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(CartServiceItem v) => v.updated;
  static const Field<CartServiceItem, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CartServiceItem> fields = const {
    #id: _f$id,
    #cartId: _f$cartId,
    #serviceId: _f$serviceId,
    #service: _f$service,
    #quantity: _f$quantity,
    #customPrice: _f$customPrice,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CartServiceItem _instantiate(DecodingData data) {
    return CartServiceItem(
      id: data.dec(_f$id),
      cartId: data.dec(_f$cartId),
      serviceId: data.dec(_f$serviceId),
      service: data.dec(_f$service),
      quantity: data.dec(_f$quantity),
      customPrice: data.dec(_f$customPrice),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CartServiceItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartServiceItem>(map);
  }

  static CartServiceItem fromJson(String json) {
    return ensureInitialized().decodeJson<CartServiceItem>(json);
  }
}

mixin CartServiceItemMappable {
  String toJson() {
    return CartServiceItemMapper.ensureInitialized()
        .encodeJson<CartServiceItem>(this as CartServiceItem);
  }

  Map<String, dynamic> toMap() {
    return CartServiceItemMapper.ensureInitialized().encodeMap<CartServiceItem>(
      this as CartServiceItem,
    );
  }

  CartServiceItemCopyWith<CartServiceItem, CartServiceItem, CartServiceItem>
  get copyWith =>
      _CartServiceItemCopyWithImpl<CartServiceItem, CartServiceItem>(
        this as CartServiceItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CartServiceItemMapper.ensureInitialized().stringifyValue(
      this as CartServiceItem,
    );
  }

  @override
  bool operator ==(Object other) {
    return CartServiceItemMapper.ensureInitialized().equalsValue(
      this as CartServiceItem,
      other,
    );
  }

  @override
  int get hashCode {
    return CartServiceItemMapper.ensureInitialized().hashValue(
      this as CartServiceItem,
    );
  }
}

extension CartServiceItemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CartServiceItem, $Out> {
  CartServiceItemCopyWith<$R, CartServiceItem, $Out> get $asCartServiceItem =>
      $base.as((v, t, t2) => _CartServiceItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartServiceItemCopyWith<$R, $In extends CartServiceItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ServiceCopyWith<$R, Service, Service>? get service;
  $R call({
    String? id,
    String? cartId,
    String? serviceId,
    Service? service,
    num? quantity,
    num? customPrice,
    DateTime? created,
    DateTime? updated,
  });
  CartServiceItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CartServiceItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartServiceItem, $Out>
    implements CartServiceItemCopyWith<$R, CartServiceItem, $Out> {
  _CartServiceItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartServiceItem> $mapper =
      CartServiceItemMapper.ensureInitialized();
  @override
  ServiceCopyWith<$R, Service, Service>? get service =>
      $value.service?.copyWith.$chain((v) => call(service: v));
  @override
  $R call({
    String? id,
    String? cartId,
    String? serviceId,
    Object? service = $none,
    num? quantity,
    Object? customPrice = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (cartId != null) #cartId: cartId,
      if (serviceId != null) #serviceId: serviceId,
      if (service != $none) #service: service,
      if (quantity != null) #quantity: quantity,
      if (customPrice != $none) #customPrice: customPrice,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CartServiceItem $make(CopyWithData data) => CartServiceItem(
    id: data.get(#id, or: $value.id),
    cartId: data.get(#cartId, or: $value.cartId),
    serviceId: data.get(#serviceId, or: $value.serviceId),
    service: data.get(#service, or: $value.service),
    quantity: data.get(#quantity, or: $value.quantity),
    customPrice: data.get(#customPrice, or: $value.customPrice),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CartServiceItemCopyWith<$R2, CartServiceItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CartServiceItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

