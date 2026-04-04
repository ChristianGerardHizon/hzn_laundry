// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'customer_promo_dto.dart';

class CustomerPromoDtoMapper extends ClassMapperBase<CustomerPromoDto> {
  CustomerPromoDtoMapper._();

  static CustomerPromoDtoMapper? _instance;
  static CustomerPromoDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerPromoDtoMapper._());
      PromoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerPromoDto';

  static String _$id(CustomerPromoDto v) => v.id;
  static const Field<CustomerPromoDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(CustomerPromoDto v) => v.collectionId;
  static const Field<CustomerPromoDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(CustomerPromoDto v) => v.collectionName;
  static const Field<CustomerPromoDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$customer(CustomerPromoDto v) => v.customer;
  static const Field<CustomerPromoDto, String> _f$customer = Field(
    'customer',
    _$customer,
  );
  static String _$promo(CustomerPromoDto v) => v.promo;
  static const Field<CustomerPromoDto, String> _f$promo = Field(
    'promo',
    _$promo,
  );
  static int _$completedOrders(CustomerPromoDto v) => v.completedOrders;
  static const Field<CustomerPromoDto, int> _f$completedOrders = Field(
    'completedOrders',
    _$completedOrders,
    opt: true,
    def: 0,
  );
  static bool _$isRewardEarned(CustomerPromoDto v) => v.isRewardEarned;
  static const Field<CustomerPromoDto, bool> _f$isRewardEarned = Field(
    'isRewardEarned',
    _$isRewardEarned,
    opt: true,
    def: false,
  );
  static bool _$isRewardRedeemed(CustomerPromoDto v) => v.isRewardRedeemed;
  static const Field<CustomerPromoDto, bool> _f$isRewardRedeemed = Field(
    'isRewardRedeemed',
    _$isRewardRedeemed,
    opt: true,
    def: false,
  );
  static String? _$redeemedOnSale(CustomerPromoDto v) => v.redeemedOnSale;
  static const Field<CustomerPromoDto, String> _f$redeemedOnSale = Field(
    'redeemedOnSale',
    _$redeemedOnSale,
    opt: true,
  );
  static Promo? _$promoExpanded(CustomerPromoDto v) => v.promoExpanded;
  static const Field<CustomerPromoDto, Promo> _f$promoExpanded = Field(
    'promoExpanded',
    _$promoExpanded,
    opt: true,
  );
  static bool _$isDeleted(CustomerPromoDto v) => v.isDeleted;
  static const Field<CustomerPromoDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(CustomerPromoDto v) => v.created;
  static const Field<CustomerPromoDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(CustomerPromoDto v) => v.updated;
  static const Field<CustomerPromoDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CustomerPromoDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #customer: _f$customer,
    #promo: _f$promo,
    #completedOrders: _f$completedOrders,
    #isRewardEarned: _f$isRewardEarned,
    #isRewardRedeemed: _f$isRewardRedeemed,
    #redeemedOnSale: _f$redeemedOnSale,
    #promoExpanded: _f$promoExpanded,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CustomerPromoDto _instantiate(DecodingData data) {
    return CustomerPromoDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      customer: data.dec(_f$customer),
      promo: data.dec(_f$promo),
      completedOrders: data.dec(_f$completedOrders),
      isRewardEarned: data.dec(_f$isRewardEarned),
      isRewardRedeemed: data.dec(_f$isRewardRedeemed),
      redeemedOnSale: data.dec(_f$redeemedOnSale),
      promoExpanded: data.dec(_f$promoExpanded),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerPromoDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerPromoDto>(map);
  }

  static CustomerPromoDto fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerPromoDto>(json);
  }
}

mixin CustomerPromoDtoMappable {
  String toJson() {
    return CustomerPromoDtoMapper.ensureInitialized()
        .encodeJson<CustomerPromoDto>(this as CustomerPromoDto);
  }

  Map<String, dynamic> toMap() {
    return CustomerPromoDtoMapper.ensureInitialized()
        .encodeMap<CustomerPromoDto>(this as CustomerPromoDto);
  }

  CustomerPromoDtoCopyWith<CustomerPromoDto, CustomerPromoDto, CustomerPromoDto>
  get copyWith =>
      _CustomerPromoDtoCopyWithImpl<CustomerPromoDto, CustomerPromoDto>(
        this as CustomerPromoDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CustomerPromoDtoMapper.ensureInitialized().stringifyValue(
      this as CustomerPromoDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerPromoDtoMapper.ensureInitialized().equalsValue(
      this as CustomerPromoDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerPromoDtoMapper.ensureInitialized().hashValue(
      this as CustomerPromoDto,
    );
  }
}

extension CustomerPromoDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerPromoDto, $Out> {
  CustomerPromoDtoCopyWith<$R, CustomerPromoDto, $Out>
  get $asCustomerPromoDto =>
      $base.as((v, t, t2) => _CustomerPromoDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomerPromoDtoCopyWith<$R, $In extends CustomerPromoDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  PromoCopyWith<$R, Promo, Promo>? get promoExpanded;
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? customer,
    String? promo,
    int? completedOrders,
    bool? isRewardEarned,
    bool? isRewardRedeemed,
    String? redeemedOnSale,
    Promo? promoExpanded,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  CustomerPromoDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomerPromoDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerPromoDto, $Out>
    implements CustomerPromoDtoCopyWith<$R, CustomerPromoDto, $Out> {
  _CustomerPromoDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerPromoDto> $mapper =
      CustomerPromoDtoMapper.ensureInitialized();
  @override
  PromoCopyWith<$R, Promo, Promo>? get promoExpanded =>
      $value.promoExpanded?.copyWith.$chain((v) => call(promoExpanded: v));
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? customer,
    String? promo,
    int? completedOrders,
    bool? isRewardEarned,
    bool? isRewardRedeemed,
    Object? redeemedOnSale = $none,
    Object? promoExpanded = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (customer != null) #customer: customer,
      if (promo != null) #promo: promo,
      if (completedOrders != null) #completedOrders: completedOrders,
      if (isRewardEarned != null) #isRewardEarned: isRewardEarned,
      if (isRewardRedeemed != null) #isRewardRedeemed: isRewardRedeemed,
      if (redeemedOnSale != $none) #redeemedOnSale: redeemedOnSale,
      if (promoExpanded != $none) #promoExpanded: promoExpanded,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CustomerPromoDto $make(CopyWithData data) => CustomerPromoDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    customer: data.get(#customer, or: $value.customer),
    promo: data.get(#promo, or: $value.promo),
    completedOrders: data.get(#completedOrders, or: $value.completedOrders),
    isRewardEarned: data.get(#isRewardEarned, or: $value.isRewardEarned),
    isRewardRedeemed: data.get(#isRewardRedeemed, or: $value.isRewardRedeemed),
    redeemedOnSale: data.get(#redeemedOnSale, or: $value.redeemedOnSale),
    promoExpanded: data.get(#promoExpanded, or: $value.promoExpanded),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CustomerPromoDtoCopyWith<$R2, CustomerPromoDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomerPromoDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

