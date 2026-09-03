// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_dto.dart';

class OrganizationDtoMapper extends ClassMapperBase<OrganizationDto> {
  OrganizationDtoMapper._();

  static OrganizationDtoMapper? _instance;
  static OrganizationDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationDto';

  static String _$id(OrganizationDto v) => v.id;
  static const Field<OrganizationDto, String> _f$id = Field('id', _$id);
  static String _$name(OrganizationDto v) => v.name;
  static const Field<OrganizationDto, String> _f$name = Field('name', _$name);
  static String? _$contactNumber(OrganizationDto v) => v.contactNumber;
  static const Field<OrganizationDto, String> _f$contactNumber = Field(
    'contactNumber',
    _$contactNumber,
    opt: true,
  );
  static String? _$address(OrganizationDto v) => v.address;
  static const Field<OrganizationDto, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static String? _$onboardingCompletedAt(OrganizationDto v) =>
      v.onboardingCompletedAt;
  static const Field<OrganizationDto, String> _f$onboardingCompletedAt = Field(
    'onboardingCompletedAt',
    _$onboardingCompletedAt,
    opt: true,
  );
  static bool _$isDeleted(OrganizationDto v) => v.isDeleted;
  static const Field<OrganizationDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(OrganizationDto v) => v.created;
  static const Field<OrganizationDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(OrganizationDto v) => v.updated;
  static const Field<OrganizationDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<OrganizationDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #contactNumber: _f$contactNumber,
    #address: _f$address,
    #onboardingCompletedAt: _f$onboardingCompletedAt,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static OrganizationDto _instantiate(DecodingData data) {
    return OrganizationDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      contactNumber: data.dec(_f$contactNumber),
      address: data.dec(_f$address),
      onboardingCompletedAt: data.dec(_f$onboardingCompletedAt),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationDto>(map);
  }

  static OrganizationDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationDto>(json);
  }
}

mixin OrganizationDtoMappable {
  String toJson() {
    return OrganizationDtoMapper.ensureInitialized()
        .encodeJson<OrganizationDto>(this as OrganizationDto);
  }

  Map<String, dynamic> toMap() {
    return OrganizationDtoMapper.ensureInitialized().encodeMap<OrganizationDto>(
      this as OrganizationDto,
    );
  }

  OrganizationDtoCopyWith<OrganizationDto, OrganizationDto, OrganizationDto>
      get copyWith =>
          _OrganizationDtoCopyWithImpl<OrganizationDto, OrganizationDto>(
            this as OrganizationDto,
            $identity,
            $identity,
          );
  @override
  String toString() {
    return OrganizationDtoMapper.ensureInitialized().stringifyValue(
      this as OrganizationDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationDtoMapper.ensureInitialized().equalsValue(
      this as OrganizationDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationDtoMapper.ensureInitialized().hashValue(
      this as OrganizationDto,
    );
  }
}

extension OrganizationDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationDto, $Out> {
  OrganizationDtoCopyWith<$R, OrganizationDto, $Out> get $asOrganizationDto =>
      $base.as((v, t, t2) => _OrganizationDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrganizationDtoCopyWith<$R, $In extends OrganizationDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? contactNumber,
    String? address,
    String? onboardingCompletedAt,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  OrganizationDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationDto, $Out>
    implements OrganizationDtoCopyWith<$R, OrganizationDto, $Out> {
  _OrganizationDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationDto> $mapper =
      OrganizationDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    Object? contactNumber = $none,
    Object? address = $none,
    Object? onboardingCompletedAt = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (name != null) #name: name,
          if (contactNumber != $none) #contactNumber: contactNumber,
          if (address != $none) #address: address,
          if (onboardingCompletedAt != $none)
            #onboardingCompletedAt: onboardingCompletedAt,
          if (isDeleted != null) #isDeleted: isDeleted,
          if (created != $none) #created: created,
          if (updated != $none) #updated: updated,
        }),
      );
  @override
  OrganizationDto $make(CopyWithData data) => OrganizationDto(
        id: data.get(#id, or: $value.id),
        name: data.get(#name, or: $value.name),
        contactNumber: data.get(#contactNumber, or: $value.contactNumber),
        address: data.get(#address, or: $value.address),
        onboardingCompletedAt: data.get(
          #onboardingCompletedAt,
          or: $value.onboardingCompletedAt,
        ),
        isDeleted: data.get(#isDeleted, or: $value.isDeleted),
        created: data.get(#created, or: $value.created),
        updated: data.get(#updated, or: $value.updated),
      );

  @override
  OrganizationDtoCopyWith<$R2, OrganizationDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _OrganizationDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
