// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_membership_dto.dart';

class OrganizationMembershipDtoMapper
    extends ClassMapperBase<OrganizationMembershipDto> {
  OrganizationMembershipDtoMapper._();

  static OrganizationMembershipDtoMapper? _instance;
  static OrganizationMembershipDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationMembershipDtoMapper._(),
      );
      OrganizationDtoMapper.ensureInitialized();
      UserRoleDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationMembershipDto';

  static String _$id(OrganizationMembershipDto v) => v.id;
  static const Field<OrganizationMembershipDto, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$organization(OrganizationMembershipDto v) => v.organization;
  static const Field<OrganizationMembershipDto, String> _f$organization = Field(
    'organization',
    _$organization,
  );
  static String _$user(OrganizationMembershipDto v) => v.user;
  static const Field<OrganizationMembershipDto, String> _f$user = Field(
    'user',
    _$user,
  );
  static String _$status(OrganizationMembershipDto v) => v.status;
  static const Field<OrganizationMembershipDto, String> _f$status = Field(
    'status',
    _$status,
  );
  static String _$joinedAt(OrganizationMembershipDto v) => v.joinedAt;
  static const Field<OrganizationMembershipDto, String> _f$joinedAt = Field(
    'joinedAt',
    _$joinedAt,
  );
  static String? _$role(OrganizationMembershipDto v) => v.role;
  static const Field<OrganizationMembershipDto, String> _f$role = Field(
    'role',
    _$role,
    opt: true,
  );
  static OrganizationDto? _$expandedOrganization(OrganizationMembershipDto v) =>
      v.expandedOrganization;
  static const Field<OrganizationMembershipDto, OrganizationDto>
      _f$expandedOrganization = Field(
    'expandedOrganization',
    _$expandedOrganization,
    opt: true,
  );
  static UserRoleDto? _$expandedRole(OrganizationMembershipDto v) =>
      v.expandedRole;
  static const Field<OrganizationMembershipDto, UserRoleDto> _f$expandedRole =
      Field('expandedRole', _$expandedRole, opt: true);

  @override
  final MappableFields<OrganizationMembershipDto> fields = const {
    #id: _f$id,
    #organization: _f$organization,
    #user: _f$user,
    #status: _f$status,
    #joinedAt: _f$joinedAt,
    #role: _f$role,
    #expandedOrganization: _f$expandedOrganization,
    #expandedRole: _f$expandedRole,
  };

  static OrganizationMembershipDto _instantiate(DecodingData data) {
    return OrganizationMembershipDto(
      id: data.dec(_f$id),
      organization: data.dec(_f$organization),
      user: data.dec(_f$user),
      status: data.dec(_f$status),
      joinedAt: data.dec(_f$joinedAt),
      role: data.dec(_f$role),
      expandedOrganization: data.dec(_f$expandedOrganization),
      expandedRole: data.dec(_f$expandedRole),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationMembershipDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationMembershipDto>(map);
  }

  static OrganizationMembershipDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationMembershipDto>(json);
  }
}

mixin OrganizationMembershipDtoMappable {
  String toJson() {
    return OrganizationMembershipDtoMapper.ensureInitialized()
        .encodeJson<OrganizationMembershipDto>(
      this as OrganizationMembershipDto,
    );
  }

  Map<String, dynamic> toMap() {
    return OrganizationMembershipDtoMapper.ensureInitialized()
        .encodeMap<OrganizationMembershipDto>(
      this as OrganizationMembershipDto,
    );
  }

  OrganizationMembershipDtoCopyWith<OrganizationMembershipDto,
          OrganizationMembershipDto, OrganizationMembershipDto>
      get copyWith => _OrganizationMembershipDtoCopyWithImpl<
              OrganizationMembershipDto, OrganizationMembershipDto>(
          this as OrganizationMembershipDto, $identity, $identity);
  @override
  String toString() {
    return OrganizationMembershipDtoMapper.ensureInitialized().stringifyValue(
      this as OrganizationMembershipDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationMembershipDtoMapper.ensureInitialized().equalsValue(
      this as OrganizationMembershipDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationMembershipDtoMapper.ensureInitialized().hashValue(
      this as OrganizationMembershipDto,
    );
  }
}

extension OrganizationMembershipDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationMembershipDto, $Out> {
  OrganizationMembershipDtoCopyWith<$R, OrganizationMembershipDto, $Out>
      get $asOrganizationMembershipDto => $base.as(
            (v, t, t2) =>
                _OrganizationMembershipDtoCopyWithImpl<$R, $Out>(v, t, t2),
          );
}

abstract class OrganizationMembershipDtoCopyWith<
    $R,
    $In extends OrganizationMembershipDto,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  OrganizationDtoCopyWith<$R, OrganizationDto, OrganizationDto>?
      get expandedOrganization;
  UserRoleDtoCopyWith<$R, UserRoleDto, UserRoleDto>? get expandedRole;
  $R call({
    String? id,
    String? organization,
    String? user,
    String? status,
    String? joinedAt,
    String? role,
    OrganizationDto? expandedOrganization,
    UserRoleDto? expandedRole,
  });
  OrganizationMembershipDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationMembershipDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationMembershipDto, $Out>
    implements
        OrganizationMembershipDtoCopyWith<$R, OrganizationMembershipDto, $Out> {
  _OrganizationMembershipDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationMembershipDto> $mapper =
      OrganizationMembershipDtoMapper.ensureInitialized();
  @override
  OrganizationDtoCopyWith<$R, OrganizationDto, OrganizationDto>?
      get expandedOrganization => $value.expandedOrganization?.copyWith.$chain(
            (v) => call(expandedOrganization: v),
          );
  @override
  UserRoleDtoCopyWith<$R, UserRoleDto, UserRoleDto>? get expandedRole =>
      $value.expandedRole?.copyWith.$chain((v) => call(expandedRole: v));
  @override
  $R call({
    String? id,
    String? organization,
    String? user,
    String? status,
    String? joinedAt,
    Object? role = $none,
    Object? expandedOrganization = $none,
    Object? expandedRole = $none,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (organization != null) #organization: organization,
          if (user != null) #user: user,
          if (status != null) #status: status,
          if (joinedAt != null) #joinedAt: joinedAt,
          if (role != $none) #role: role,
          if (expandedOrganization != $none)
            #expandedOrganization: expandedOrganization,
          if (expandedRole != $none) #expandedRole: expandedRole,
        }),
      );
  @override
  OrganizationMembershipDto $make(CopyWithData data) =>
      OrganizationMembershipDto(
        id: data.get(#id, or: $value.id),
        organization: data.get(#organization, or: $value.organization),
        user: data.get(#user, or: $value.user),
        status: data.get(#status, or: $value.status),
        joinedAt: data.get(#joinedAt, or: $value.joinedAt),
        role: data.get(#role, or: $value.role),
        expandedOrganization: data.get(
          #expandedOrganization,
          or: $value.expandedOrganization,
        ),
        expandedRole: data.get(#expandedRole, or: $value.expandedRole),
      );

  @override
  OrganizationMembershipDtoCopyWith<$R2, OrganizationMembershipDto, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _OrganizationMembershipDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
