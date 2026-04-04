// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'customer_dto.dart';

class CustomerDtoMapper extends ClassMapperBase<CustomerDto> {
  CustomerDtoMapper._();

  static CustomerDtoMapper? _instance;
  static CustomerDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerDto';

  static String _$id(CustomerDto v) => v.id;
  static const Field<CustomerDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(CustomerDto v) => v.collectionId;
  static const Field<CustomerDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(CustomerDto v) => v.collectionName;
  static const Field<CustomerDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(CustomerDto v) => v.name;
  static const Field<CustomerDto, String> _f$name = Field('name', _$name);
  static String? _$phone(CustomerDto v) => v.phone;
  static const Field<CustomerDto, String> _f$phone = Field(
    'phone',
    _$phone,
    opt: true,
  );
  static String? _$address(CustomerDto v) => v.address;
  static const Field<CustomerDto, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static String? _$notes(CustomerDto v) => v.notes;
  static const Field<CustomerDto, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$created(CustomerDto v) => v.created;
  static const Field<CustomerDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(CustomerDto v) => v.updated;
  static const Field<CustomerDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CustomerDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #phone: _f$phone,
    #address: _f$address,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CustomerDto _instantiate(DecodingData data) {
    return CustomerDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
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

  static CustomerDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerDto>(map);
  }

  static CustomerDto fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerDto>(json);
  }
}

mixin CustomerDtoMappable {
  String toJson() {
    return CustomerDtoMapper.ensureInitialized().encodeJson<CustomerDto>(
      this as CustomerDto,
    );
  }

  Map<String, dynamic> toMap() {
    return CustomerDtoMapper.ensureInitialized().encodeMap<CustomerDto>(
      this as CustomerDto,
    );
  }

  CustomerDtoCopyWith<CustomerDto, CustomerDto, CustomerDto> get copyWith =>
      _CustomerDtoCopyWithImpl<CustomerDto, CustomerDto>(
        this as CustomerDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CustomerDtoMapper.ensureInitialized().stringifyValue(
      this as CustomerDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerDtoMapper.ensureInitialized().equalsValue(
      this as CustomerDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerDtoMapper.ensureInitialized().hashValue(this as CustomerDto);
  }
}

extension CustomerDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerDto, $Out> {
  CustomerDtoCopyWith<$R, CustomerDto, $Out> get $asCustomerDto =>
      $base.as((v, t, t2) => _CustomerDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomerDtoCopyWith<$R, $In extends CustomerDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? phone,
    String? address,
    String? notes,
    String? created,
    String? updated,
  });
  CustomerDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CustomerDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerDto, $Out>
    implements CustomerDtoCopyWith<$R, CustomerDto, $Out> {
  _CustomerDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerDto> $mapper =
      CustomerDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    Object? phone = $none,
    Object? address = $none,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (phone != $none) #phone: phone,
      if (address != $none) #address: address,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CustomerDto $make(CopyWithData data) => CustomerDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    phone: data.get(#phone, or: $value.phone),
    address: data.get(#address, or: $value.address),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CustomerDtoCopyWith<$R2, CustomerDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomerDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

