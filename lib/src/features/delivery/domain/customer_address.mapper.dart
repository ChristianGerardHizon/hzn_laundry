// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'customer_address.dart';

class CustomerAddressMapper extends ClassMapperBase<CustomerAddress> {
  CustomerAddressMapper._();

  static CustomerAddressMapper? _instance;
  static CustomerAddressMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerAddressMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerAddress';

  static String _$id(CustomerAddress v) => v.id;
  static const Field<CustomerAddress, String> _f$id = Field('id', _$id);
  static String _$customerId(CustomerAddress v) => v.customerId;
  static const Field<CustomerAddress, String> _f$customerId = Field(
    'customerId',
    _$customerId,
  );
  static String _$address(CustomerAddress v) => v.address;
  static const Field<CustomerAddress, String> _f$address = Field(
    'address',
    _$address,
  );
  static String? _$label(CustomerAddress v) => v.label;
  static const Field<CustomerAddress, String> _f$label = Field(
    'label',
    _$label,
    opt: true,
  );
  static String? _$notes(CustomerAddress v) => v.notes;
  static const Field<CustomerAddress, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static num? _$distanceKm(CustomerAddress v) => v.distanceKm;
  static const Field<CustomerAddress, num> _f$distanceKm = Field(
    'distanceKm',
    _$distanceKm,
    opt: true,
  );
  static String? _$deliveryRateId(CustomerAddress v) => v.deliveryRateId;
  static const Field<CustomerAddress, String> _f$deliveryRateId = Field(
    'deliveryRateId',
    _$deliveryRateId,
    opt: true,
  );
  static bool _$isDefault(CustomerAddress v) => v.isDefault;
  static const Field<CustomerAddress, bool> _f$isDefault = Field(
    'isDefault',
    _$isDefault,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<CustomerAddress> fields = const {
    #id: _f$id,
    #customerId: _f$customerId,
    #address: _f$address,
    #label: _f$label,
    #notes: _f$notes,
    #distanceKm: _f$distanceKm,
    #deliveryRateId: _f$deliveryRateId,
    #isDefault: _f$isDefault,
  };

  static CustomerAddress _instantiate(DecodingData data) {
    return CustomerAddress(
      id: data.dec(_f$id),
      customerId: data.dec(_f$customerId),
      address: data.dec(_f$address),
      label: data.dec(_f$label),
      notes: data.dec(_f$notes),
      distanceKm: data.dec(_f$distanceKm),
      deliveryRateId: data.dec(_f$deliveryRateId),
      isDefault: data.dec(_f$isDefault),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerAddress fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerAddress>(map);
  }

  static CustomerAddress fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerAddress>(json);
  }
}

mixin CustomerAddressMappable {
  String toJson() {
    return CustomerAddressMapper.ensureInitialized()
        .encodeJson<CustomerAddress>(this as CustomerAddress);
  }

  Map<String, dynamic> toMap() {
    return CustomerAddressMapper.ensureInitialized().encodeMap<CustomerAddress>(
      this as CustomerAddress,
    );
  }

  CustomerAddressCopyWith<CustomerAddress, CustomerAddress, CustomerAddress>
  get copyWith =>
      _CustomerAddressCopyWithImpl<CustomerAddress, CustomerAddress>(
        this as CustomerAddress,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CustomerAddressMapper.ensureInitialized().stringifyValue(
      this as CustomerAddress,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerAddressMapper.ensureInitialized().equalsValue(
      this as CustomerAddress,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerAddressMapper.ensureInitialized().hashValue(
      this as CustomerAddress,
    );
  }
}

extension CustomerAddressValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerAddress, $Out> {
  CustomerAddressCopyWith<$R, CustomerAddress, $Out> get $asCustomerAddress =>
      $base.as((v, t, t2) => _CustomerAddressCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomerAddressCopyWith<$R, $In extends CustomerAddress, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? customerId,
    String? address,
    String? label,
    String? notes,
    num? distanceKm,
    String? deliveryRateId,
    bool? isDefault,
  });
  CustomerAddressCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomerAddressCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerAddress, $Out>
    implements CustomerAddressCopyWith<$R, CustomerAddress, $Out> {
  _CustomerAddressCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerAddress> $mapper =
      CustomerAddressMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? customerId,
    String? address,
    Object? label = $none,
    Object? notes = $none,
    Object? distanceKm = $none,
    Object? deliveryRateId = $none,
    bool? isDefault,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (customerId != null) #customerId: customerId,
      if (address != null) #address: address,
      if (label != $none) #label: label,
      if (notes != $none) #notes: notes,
      if (distanceKm != $none) #distanceKm: distanceKm,
      if (deliveryRateId != $none) #deliveryRateId: deliveryRateId,
      if (isDefault != null) #isDefault: isDefault,
    }),
  );
  @override
  CustomerAddress $make(CopyWithData data) => CustomerAddress(
    id: data.get(#id, or: $value.id),
    customerId: data.get(#customerId, or: $value.customerId),
    address: data.get(#address, or: $value.address),
    label: data.get(#label, or: $value.label),
    notes: data.get(#notes, or: $value.notes),
    distanceKm: data.get(#distanceKm, or: $value.distanceKm),
    deliveryRateId: data.get(#deliveryRateId, or: $value.deliveryRateId),
    isDefault: data.get(#isDefault, or: $value.isDefault),
  );

  @override
  CustomerAddressCopyWith<$R2, CustomerAddress, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomerAddressCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

