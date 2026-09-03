// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization.dart';

class OrganizationMapper extends ClassMapperBase<Organization> {
  OrganizationMapper._();

  static OrganizationMapper? _instance;
  static OrganizationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Organization';

  static String _$id(Organization v) => v.id;
  static const Field<Organization, String> _f$id = Field('id', _$id);
  static String _$name(Organization v) => v.name;
  static const Field<Organization, String> _f$name = Field('name', _$name);
  static String? _$contactNumber(Organization v) => v.contactNumber;
  static const Field<Organization, String> _f$contactNumber = Field(
    'contactNumber',
    _$contactNumber,
    opt: true,
  );
  static String? _$address(Organization v) => v.address;
  static const Field<Organization, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static DateTime? _$onboardingCompletedAt(Organization v) =>
      v.onboardingCompletedAt;
  static const Field<Organization, DateTime> _f$onboardingCompletedAt = Field(
    'onboardingCompletedAt',
    _$onboardingCompletedAt,
    opt: true,
  );
  static bool _$isDeleted(Organization v) => v.isDeleted;
  static const Field<Organization, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Organization v) => v.created;
  static const Field<Organization, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Organization v) => v.updated;
  static const Field<Organization, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Organization> fields = const {
    #id: _f$id,
    #name: _f$name,
    #contactNumber: _f$contactNumber,
    #address: _f$address,
    #onboardingCompletedAt: _f$onboardingCompletedAt,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Organization _instantiate(DecodingData data) {
    return Organization(
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

  static Organization fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Organization>(map);
  }

  static Organization fromJson(String json) {
    return ensureInitialized().decodeJson<Organization>(json);
  }
}

mixin OrganizationMappable {
  String toJson() {
    return OrganizationMapper.ensureInitialized().encodeJson<Organization>(
      this as Organization,
    );
  }

  Map<String, dynamic> toMap() {
    return OrganizationMapper.ensureInitialized().encodeMap<Organization>(
      this as Organization,
    );
  }

  OrganizationCopyWith<Organization, Organization, Organization> get copyWith =>
      _OrganizationCopyWithImpl<Organization, Organization>(
        this as Organization,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrganizationMapper.ensureInitialized().stringifyValue(
      this as Organization,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationMapper.ensureInitialized().equalsValue(
      this as Organization,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationMapper.ensureInitialized().hashValue(
      this as Organization,
    );
  }
}

extension OrganizationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Organization, $Out> {
  OrganizationCopyWith<$R, Organization, $Out> get $asOrganization =>
      $base.as((v, t, t2) => _OrganizationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrganizationCopyWith<$R, $In extends Organization, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? contactNumber,
    String? address,
    DateTime? onboardingCompletedAt,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  OrganizationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrganizationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Organization, $Out>
    implements OrganizationCopyWith<$R, Organization, $Out> {
  _OrganizationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Organization> $mapper =
      OrganizationMapper.ensureInitialized();
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
  Organization $make(CopyWithData data) => Organization(
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
  OrganizationCopyWith<$R2, Organization, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _OrganizationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
