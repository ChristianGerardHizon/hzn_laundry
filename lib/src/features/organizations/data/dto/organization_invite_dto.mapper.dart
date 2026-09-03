// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_invite_dto.dart';

class OrganizationInviteDtoMapper
    extends ClassMapperBase<OrganizationInviteDto> {
  OrganizationInviteDtoMapper._();

  static OrganizationInviteDtoMapper? _instance;
  static OrganizationInviteDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationInviteDtoMapper._());
      UserRoleDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationInviteDto';

  static String _$id(OrganizationInviteDto v) => v.id;
  static const Field<OrganizationInviteDto, String> _f$id = Field('id', _$id);
  static String _$organization(OrganizationInviteDto v) => v.organization;
  static const Field<OrganizationInviteDto, String> _f$organization = Field(
    'organization',
    _$organization,
  );
  static String _$email(OrganizationInviteDto v) => v.email;
  static const Field<OrganizationInviteDto, String> _f$email = Field(
    'email',
    _$email,
  );
  static String _$status(OrganizationInviteDto v) => v.status;
  static const Field<OrganizationInviteDto, String> _f$status = Field(
    'status',
    _$status,
  );
  static String _$expiresAt(OrganizationInviteDto v) => v.expiresAt;
  static const Field<OrganizationInviteDto, String> _f$expiresAt = Field(
    'expiresAt',
    _$expiresAt,
  );
  static String? _$role(OrganizationInviteDto v) => v.role;
  static const Field<OrganizationInviteDto, String> _f$role = Field(
    'role',
    _$role,
    opt: true,
  );
  static String? _$organizationName(OrganizationInviteDto v) =>
      v.organizationName;
  static const Field<OrganizationInviteDto, String> _f$organizationName = Field(
    'organizationName',
    _$organizationName,
    opt: true,
  );
  static UserRoleDto? _$expandedRole(OrganizationInviteDto v) => v.expandedRole;
  static const Field<OrganizationInviteDto, UserRoleDto> _f$expandedRole =
      Field('expandedRole', _$expandedRole, opt: true);

  @override
  final MappableFields<OrganizationInviteDto> fields = const {
    #id: _f$id,
    #organization: _f$organization,
    #email: _f$email,
    #status: _f$status,
    #expiresAt: _f$expiresAt,
    #role: _f$role,
    #organizationName: _f$organizationName,
    #expandedRole: _f$expandedRole,
  };

  static OrganizationInviteDto _instantiate(DecodingData data) {
    return OrganizationInviteDto(
      id: data.dec(_f$id),
      organization: data.dec(_f$organization),
      email: data.dec(_f$email),
      status: data.dec(_f$status),
      expiresAt: data.dec(_f$expiresAt),
      role: data.dec(_f$role),
      organizationName: data.dec(_f$organizationName),
      expandedRole: data.dec(_f$expandedRole),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationInviteDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationInviteDto>(map);
  }

  static OrganizationInviteDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationInviteDto>(json);
  }
}

mixin OrganizationInviteDtoMappable {
  String toJson() {
    return OrganizationInviteDtoMapper.ensureInitialized()
        .encodeJson<OrganizationInviteDto>(this as OrganizationInviteDto);
  }

  Map<String, dynamic> toMap() {
    return OrganizationInviteDtoMapper.ensureInitialized()
        .encodeMap<OrganizationInviteDto>(this as OrganizationInviteDto);
  }

  OrganizationInviteDtoCopyWith<OrganizationInviteDto, OrganizationInviteDto,
      OrganizationInviteDto> get copyWith => _OrganizationInviteDtoCopyWithImpl<
          OrganizationInviteDto, OrganizationInviteDto>(
      this as OrganizationInviteDto, $identity, $identity);
  @override
  String toString() {
    return OrganizationInviteDtoMapper.ensureInitialized().stringifyValue(
      this as OrganizationInviteDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationInviteDtoMapper.ensureInitialized().equalsValue(
      this as OrganizationInviteDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationInviteDtoMapper.ensureInitialized().hashValue(
      this as OrganizationInviteDto,
    );
  }
}

extension OrganizationInviteDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationInviteDto, $Out> {
  OrganizationInviteDtoCopyWith<$R, OrganizationInviteDto, $Out>
      get $asOrganizationInviteDto => $base.as(
            (v, t, t2) =>
                _OrganizationInviteDtoCopyWithImpl<$R, $Out>(v, t, t2),
          );
}

abstract class OrganizationInviteDtoCopyWith<
    $R,
    $In extends OrganizationInviteDto,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  UserRoleDtoCopyWith<$R, UserRoleDto, UserRoleDto>? get expandedRole;
  $R call({
    String? id,
    String? organization,
    String? email,
    String? status,
    String? expiresAt,
    String? role,
    String? organizationName,
    UserRoleDto? expandedRole,
  });
  OrganizationInviteDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationInviteDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationInviteDto, $Out>
    implements OrganizationInviteDtoCopyWith<$R, OrganizationInviteDto, $Out> {
  _OrganizationInviteDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationInviteDto> $mapper =
      OrganizationInviteDtoMapper.ensureInitialized();
  @override
  UserRoleDtoCopyWith<$R, UserRoleDto, UserRoleDto>? get expandedRole =>
      $value.expandedRole?.copyWith.$chain((v) => call(expandedRole: v));
  @override
  $R call({
    String? id,
    String? organization,
    String? email,
    String? status,
    String? expiresAt,
    Object? role = $none,
    Object? organizationName = $none,
    Object? expandedRole = $none,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (organization != null) #organization: organization,
          if (email != null) #email: email,
          if (status != null) #status: status,
          if (expiresAt != null) #expiresAt: expiresAt,
          if (role != $none) #role: role,
          if (organizationName != $none) #organizationName: organizationName,
          if (expandedRole != $none) #expandedRole: expandedRole,
        }),
      );
  @override
  OrganizationInviteDto $make(CopyWithData data) => OrganizationInviteDto(
        id: data.get(#id, or: $value.id),
        organization: data.get(#organization, or: $value.organization),
        email: data.get(#email, or: $value.email),
        status: data.get(#status, or: $value.status),
        expiresAt: data.get(#expiresAt, or: $value.expiresAt),
        role: data.get(#role, or: $value.role),
        organizationName:
            data.get(#organizationName, or: $value.organizationName),
        expandedRole: data.get(#expandedRole, or: $value.expandedRole),
      );

  @override
  OrganizationInviteDtoCopyWith<$R2, OrganizationInviteDto, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _OrganizationInviteDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
