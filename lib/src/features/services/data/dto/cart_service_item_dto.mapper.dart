// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_service_item_dto.dart';

class CartServiceItemDtoMapper extends ClassMapperBase<CartServiceItemDto> {
  CartServiceItemDtoMapper._();

  static CartServiceItemDtoMapper? _instance;
  static CartServiceItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartServiceItemDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CartServiceItemDto';

  static String _$id(CartServiceItemDto v) => v.id;
  static const Field<CartServiceItemDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(CartServiceItemDto v) => v.collectionId;
  static const Field<CartServiceItemDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(CartServiceItemDto v) => v.collectionName;
  static const Field<CartServiceItemDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$cart(CartServiceItemDto v) => v.cart;
  static const Field<CartServiceItemDto, String> _f$cart = Field(
    'cart',
    _$cart,
  );
  static String _$service(CartServiceItemDto v) => v.service;
  static const Field<CartServiceItemDto, String> _f$service = Field(
    'service',
    _$service,
  );
  static num _$quantity(CartServiceItemDto v) => v.quantity;
  static const Field<CartServiceItemDto, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static num? _$customPrice(CartServiceItemDto v) => v.customPrice;
  static const Field<CartServiceItemDto, num> _f$customPrice = Field(
    'customPrice',
    _$customPrice,
    opt: true,
  );
  static String? _$created(CartServiceItemDto v) => v.created;
  static const Field<CartServiceItemDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(CartServiceItemDto v) => v.updated;
  static const Field<CartServiceItemDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CartServiceItemDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #cart: _f$cart,
    #service: _f$service,
    #quantity: _f$quantity,
    #customPrice: _f$customPrice,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CartServiceItemDto _instantiate(DecodingData data) {
    return CartServiceItemDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      cart: data.dec(_f$cart),
      service: data.dec(_f$service),
      quantity: data.dec(_f$quantity),
      customPrice: data.dec(_f$customPrice),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CartServiceItemDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartServiceItemDto>(map);
  }

  static CartServiceItemDto fromJson(String json) {
    return ensureInitialized().decodeJson<CartServiceItemDto>(json);
  }
}

mixin CartServiceItemDtoMappable {
  String toJson() {
    return CartServiceItemDtoMapper.ensureInitialized()
        .encodeJson<CartServiceItemDto>(this as CartServiceItemDto);
  }

  Map<String, dynamic> toMap() {
    return CartServiceItemDtoMapper.ensureInitialized()
        .encodeMap<CartServiceItemDto>(this as CartServiceItemDto);
  }

  CartServiceItemDtoCopyWith<
    CartServiceItemDto,
    CartServiceItemDto,
    CartServiceItemDto
  >
  get copyWith =>
      _CartServiceItemDtoCopyWithImpl<CartServiceItemDto, CartServiceItemDto>(
        this as CartServiceItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CartServiceItemDtoMapper.ensureInitialized().stringifyValue(
      this as CartServiceItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CartServiceItemDtoMapper.ensureInitialized().equalsValue(
      this as CartServiceItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CartServiceItemDtoMapper.ensureInitialized().hashValue(
      this as CartServiceItemDto,
    );
  }
}

extension CartServiceItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CartServiceItemDto, $Out> {
  CartServiceItemDtoCopyWith<$R, CartServiceItemDto, $Out>
  get $asCartServiceItemDto => $base.as(
    (v, t, t2) => _CartServiceItemDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CartServiceItemDtoCopyWith<
  $R,
  $In extends CartServiceItemDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? cart,
    String? service,
    num? quantity,
    num? customPrice,
    String? created,
    String? updated,
  });
  CartServiceItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CartServiceItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartServiceItemDto, $Out>
    implements CartServiceItemDtoCopyWith<$R, CartServiceItemDto, $Out> {
  _CartServiceItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartServiceItemDto> $mapper =
      CartServiceItemDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? cart,
    String? service,
    num? quantity,
    Object? customPrice = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (cart != null) #cart: cart,
      if (service != null) #service: service,
      if (quantity != null) #quantity: quantity,
      if (customPrice != $none) #customPrice: customPrice,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CartServiceItemDto $make(CopyWithData data) => CartServiceItemDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    cart: data.get(#cart, or: $value.cart),
    service: data.get(#service, or: $value.service),
    quantity: data.get(#quantity, or: $value.quantity),
    customPrice: data.get(#customPrice, or: $value.customPrice),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CartServiceItemDtoCopyWith<$R2, CartServiceItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CartServiceItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

