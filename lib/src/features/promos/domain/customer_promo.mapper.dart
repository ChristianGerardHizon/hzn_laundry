// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'customer_promo.dart';

class CustomerPromoMapper extends ClassMapperBase<CustomerPromo> {
  CustomerPromoMapper._();

  static CustomerPromoMapper? _instance;
  static CustomerPromoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerPromoMapper._());
      PromoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerPromo';

  static String _$id(CustomerPromo v) => v.id;
  static const Field<CustomerPromo, String> _f$id = Field('id', _$id);
  static String _$customerId(CustomerPromo v) => v.customerId;
  static const Field<CustomerPromo, String> _f$customerId = Field(
    'customerId',
    _$customerId,
  );
  static String _$promoId(CustomerPromo v) => v.promoId;
  static const Field<CustomerPromo, String> _f$promoId = Field(
    'promoId',
    _$promoId,
  );
  static int _$completedOrders(CustomerPromo v) => v.completedOrders;
  static const Field<CustomerPromo, int> _f$completedOrders = Field(
    'completedOrders',
    _$completedOrders,
    opt: true,
    def: 0,
  );
  static bool _$isRewardEarned(CustomerPromo v) => v.isRewardEarned;
  static const Field<CustomerPromo, bool> _f$isRewardEarned = Field(
    'isRewardEarned',
    _$isRewardEarned,
    opt: true,
    def: false,
  );
  static bool _$isRewardRedeemed(CustomerPromo v) => v.isRewardRedeemed;
  static const Field<CustomerPromo, bool> _f$isRewardRedeemed = Field(
    'isRewardRedeemed',
    _$isRewardRedeemed,
    opt: true,
    def: false,
  );
  static String? _$redeemedOnSaleId(CustomerPromo v) => v.redeemedOnSaleId;
  static const Field<CustomerPromo, String> _f$redeemedOnSaleId = Field(
    'redeemedOnSaleId',
    _$redeemedOnSaleId,
    opt: true,
  );
  static Promo? _$promo(CustomerPromo v) => v.promo;
  static const Field<CustomerPromo, Promo> _f$promo = Field(
    'promo',
    _$promo,
    opt: true,
  );
  static bool _$isDeleted(CustomerPromo v) => v.isDeleted;
  static const Field<CustomerPromo, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(CustomerPromo v) => v.created;
  static const Field<CustomerPromo, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(CustomerPromo v) => v.updated;
  static const Field<CustomerPromo, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CustomerPromo> fields = const {
    #id: _f$id,
    #customerId: _f$customerId,
    #promoId: _f$promoId,
    #completedOrders: _f$completedOrders,
    #isRewardEarned: _f$isRewardEarned,
    #isRewardRedeemed: _f$isRewardRedeemed,
    #redeemedOnSaleId: _f$redeemedOnSaleId,
    #promo: _f$promo,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CustomerPromo _instantiate(DecodingData data) {
    return CustomerPromo(
      id: data.dec(_f$id),
      customerId: data.dec(_f$customerId),
      promoId: data.dec(_f$promoId),
      completedOrders: data.dec(_f$completedOrders),
      isRewardEarned: data.dec(_f$isRewardEarned),
      isRewardRedeemed: data.dec(_f$isRewardRedeemed),
      redeemedOnSaleId: data.dec(_f$redeemedOnSaleId),
      promo: data.dec(_f$promo),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerPromo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerPromo>(map);
  }

  static CustomerPromo fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerPromo>(json);
  }
}

mixin CustomerPromoMappable {
  String toJson() {
    return CustomerPromoMapper.ensureInitialized().encodeJson<CustomerPromo>(
      this as CustomerPromo,
    );
  }

  Map<String, dynamic> toMap() {
    return CustomerPromoMapper.ensureInitialized().encodeMap<CustomerPromo>(
      this as CustomerPromo,
    );
  }

  CustomerPromoCopyWith<CustomerPromo, CustomerPromo, CustomerPromo>
  get copyWith => _CustomerPromoCopyWithImpl<CustomerPromo, CustomerPromo>(
    this as CustomerPromo,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CustomerPromoMapper.ensureInitialized().stringifyValue(
      this as CustomerPromo,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerPromoMapper.ensureInitialized().equalsValue(
      this as CustomerPromo,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerPromoMapper.ensureInitialized().hashValue(
      this as CustomerPromo,
    );
  }
}

extension CustomerPromoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerPromo, $Out> {
  CustomerPromoCopyWith<$R, CustomerPromo, $Out> get $asCustomerPromo =>
      $base.as((v, t, t2) => _CustomerPromoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomerPromoCopyWith<$R, $In extends CustomerPromo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  PromoCopyWith<$R, Promo, Promo>? get promo;
  $R call({
    String? id,
    String? customerId,
    String? promoId,
    int? completedOrders,
    bool? isRewardEarned,
    bool? isRewardRedeemed,
    String? redeemedOnSaleId,
    Promo? promo,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  CustomerPromoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CustomerPromoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerPromo, $Out>
    implements CustomerPromoCopyWith<$R, CustomerPromo, $Out> {
  _CustomerPromoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerPromo> $mapper =
      CustomerPromoMapper.ensureInitialized();
  @override
  PromoCopyWith<$R, Promo, Promo>? get promo =>
      $value.promo?.copyWith.$chain((v) => call(promo: v));
  @override
  $R call({
    String? id,
    String? customerId,
    String? promoId,
    int? completedOrders,
    bool? isRewardEarned,
    bool? isRewardRedeemed,
    Object? redeemedOnSaleId = $none,
    Object? promo = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (customerId != null) #customerId: customerId,
      if (promoId != null) #promoId: promoId,
      if (completedOrders != null) #completedOrders: completedOrders,
      if (isRewardEarned != null) #isRewardEarned: isRewardEarned,
      if (isRewardRedeemed != null) #isRewardRedeemed: isRewardRedeemed,
      if (redeemedOnSaleId != $none) #redeemedOnSaleId: redeemedOnSaleId,
      if (promo != $none) #promo: promo,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CustomerPromo $make(CopyWithData data) => CustomerPromo(
    id: data.get(#id, or: $value.id),
    customerId: data.get(#customerId, or: $value.customerId),
    promoId: data.get(#promoId, or: $value.promoId),
    completedOrders: data.get(#completedOrders, or: $value.completedOrders),
    isRewardEarned: data.get(#isRewardEarned, or: $value.isRewardEarned),
    isRewardRedeemed: data.get(#isRewardRedeemed, or: $value.isRewardRedeemed),
    redeemedOnSaleId: data.get(#redeemedOnSaleId, or: $value.redeemedOnSaleId),
    promo: data.get(#promo, or: $value.promo),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CustomerPromoCopyWith<$R2, CustomerPromo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomerPromoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

