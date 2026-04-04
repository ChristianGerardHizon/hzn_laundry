// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'customer.dart';

class CustomerMapper extends ClassMapperBase<Customer> {
  CustomerMapper._();

  static CustomerMapper? _instance;
  static CustomerMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Customer';

  static String _$id(Customer v) => v.id;
  static const Field<Customer, String> _f$id = Field('id', _$id);
  static String _$name(Customer v) => v.name;
  static const Field<Customer, String> _f$name = Field('name', _$name);
  static String? _$phone(Customer v) => v.phone;
  static const Field<Customer, String> _f$phone = Field(
    'phone',
    _$phone,
    opt: true,
  );
  static String? _$address(Customer v) => v.address;
  static const Field<Customer, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static String? _$notes(Customer v) => v.notes;
  static const Field<Customer, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static DateTime? _$created(Customer v) => v.created;
  static const Field<Customer, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Customer v) => v.updated;
  static const Field<Customer, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Customer> fields = const {
    #id: _f$id,
    #name: _f$name,
    #phone: _f$phone,
    #address: _f$address,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Customer _instantiate(DecodingData data) {
    return Customer(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      phone: data.dec(_f$phone),
      address: data.dec(_f$address),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Customer fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Customer>(map);
  }

  static Customer fromJson(String json) {
    return ensureInitialized().decodeJson<Customer>(json);
  }
}

mixin CustomerMappable {
  String toJson() {
    return CustomerMapper.ensureInitialized().encodeJson<Customer>(
      this as Customer,
    );
  }

  Map<String, dynamic> toMap() {
    return CustomerMapper.ensureInitialized().encodeMap<Customer>(
      this as Customer,
    );
  }

  CustomerCopyWith<Customer, Customer, Customer> get copyWith =>
      _CustomerCopyWithImpl<Customer, Customer>(
        this as Customer,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CustomerMapper.ensureInitialized().stringifyValue(this as Customer);
  }

  @override
  bool operator ==(Object other) {
    return CustomerMapper.ensureInitialized().equalsValue(
      this as Customer,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerMapper.ensureInitialized().hashValue(this as Customer);
  }
}

extension CustomerValueCopy<$R, $Out> on ObjectCopyWith<$R, Customer, $Out> {
  CustomerCopyWith<$R, Customer, $Out> get $asCustomer =>
      $base.as((v, t, t2) => _CustomerCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomerCopyWith<$R, $In extends Customer, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    DateTime? created,
    DateTime? updated,
  });
  CustomerCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CustomerCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Customer, $Out>
    implements CustomerCopyWith<$R, Customer, $Out> {
  _CustomerCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Customer> $mapper =
      CustomerMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    Object? phone = $none,
    Object? address = $none,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (phone != $none) #phone: phone,
      if (address != $none) #address: address,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Customer $make(CopyWithData data) => Customer(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    phone: data.get(#phone, or: $value.phone),
    address: data.get(#address, or: $value.address),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CustomerCopyWith<$R2, Customer, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomerCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

