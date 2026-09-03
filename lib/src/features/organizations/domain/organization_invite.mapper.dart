// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_invite.dart';

class OrganizationInviteMapper extends ClassMapperBase<OrganizationInvite> {
  OrganizationInviteMapper._();

  static OrganizationInviteMapper? _instance;
  static OrganizationInviteMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationInviteMapper._());
      UserRoleMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationInvite';

  static String _$id(OrganizationInvite v) => v.id;
  static const Field<OrganizationInvite, String> _f$id = Field('id', _$id);
  static String _$organizationId(OrganizationInvite v) => v.organizationId;
  static const Field<OrganizationInvite, String> _f$organizationId = Field(
    'organizationId',
    _$organizationId,
  );
  static String _$email(OrganizationInvite v) => v.email;
  static const Field<OrganizationInvite, String> _f$email = Field(
    'email',
    _$email,
  );
  static String _$status(OrganizationInvite v) => v.status;
  static const Field<OrganizationInvite, String> _f$status = Field(
    'status',
    _$status,
  );
  static DateTime _$expiresAt(OrganizationInvite v) => v.expiresAt;
  static const Field<OrganizationInvite, DateTime> _f$expiresAt = Field(
    'expiresAt',
    _$expiresAt,
  );
  static String? _$organizationName(OrganizationInvite v) => v.organizationName;
  static const Field<OrganizationInvite, String> _f$organizationName = Field(
    'organizationName',
    _$organizationName,
    opt: true,
  );
  static UserRole? _$role(OrganizationInvite v) => v.role;
  static const Field<OrganizationInvite, UserRole> _f$role = Field(
    'role',
    _$role,
    opt: true,
  );

  @override
  final MappableFields<OrganizationInvite> fields = const {
    #id: _f$id,
    #organizationId: _f$organizationId,
    #email: _f$email,
    #status: _f$status,
    #expiresAt: _f$expiresAt,
    #organizationName: _f$organizationName,
    #role: _f$role,
  };

  static OrganizationInvite _instantiate(DecodingData data) {
    return OrganizationInvite(
      id: data.dec(_f$id),
      organizationId: data.dec(_f$organizationId),
      email: data.dec(_f$email),
      status: data.dec(_f$status),
      expiresAt: data.dec(_f$expiresAt),
      organizationName: data.dec(_f$organizationName),
      role: data.dec(_f$role),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationInvite fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationInvite>(map);
  }

  static OrganizationInvite fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationInvite>(json);
  }
}

mixin OrganizationInviteMappable {
  String toJson() {
    return OrganizationInviteMapper.ensureInitialized()
        .encodeJson<OrganizationInvite>(this as OrganizationInvite);
  }

  Map<String, dynamic> toMap() {
    return OrganizationInviteMapper.ensureInitialized()
        .encodeMap<OrganizationInvite>(this as OrganizationInvite);
  }

  OrganizationInviteCopyWith<
    OrganizationInvite,
    OrganizationInvite,
    OrganizationInvite
  >
  get copyWith =>
      _OrganizationInviteCopyWithImpl<OrganizationInvite, OrganizationInvite>(
        this as OrganizationInvite,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrganizationInviteMapper.ensureInitialized().stringifyValue(
      this as OrganizationInvite,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationInviteMapper.ensureInitialized().equalsValue(
      this as OrganizationInvite,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationInviteMapper.ensureInitialized().hashValue(
      this as OrganizationInvite,
    );
  }
}

extension OrganizationInviteValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationInvite, $Out> {
  OrganizationInviteCopyWith<$R, OrganizationInvite, $Out>
  get $asOrganizationInvite => $base.as(
    (v, t, t2) => _OrganizationInviteCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationInviteCopyWith<
  $R,
  $In extends OrganizationInvite,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  UserRoleCopyWith<$R, UserRole, UserRole>? get role;
  $R call({
    String? id,
    String? organizationId,
    String? email,
    String? status,
    DateTime? expiresAt,
    String? organizationName,
    UserRole? role,
  });
  OrganizationInviteCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationInviteCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationInvite, $Out>
    implements OrganizationInviteCopyWith<$R, OrganizationInvite, $Out> {
  _OrganizationInviteCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationInvite> $mapper =
      OrganizationInviteMapper.ensureInitialized();
  @override
  UserRoleCopyWith<$R, UserRole, UserRole>? get role =>
      $value.role?.copyWith.$chain((v) => call(role: v));
  @override
  $R call({
    String? id,
    String? organizationId,
    String? email,
    String? status,
    DateTime? expiresAt,
    Object? organizationName = $none,
    Object? role = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (organizationId != null) #organizationId: organizationId,
      if (email != null) #email: email,
      if (status != null) #status: status,
      if (expiresAt != null) #expiresAt: expiresAt,
      if (organizationName != $none) #organizationName: organizationName,
      if (role != $none) #role: role,
    }),
  );
  @override
  OrganizationInvite $make(CopyWithData data) => OrganizationInvite(
    id: data.get(#id, or: $value.id),
    organizationId: data.get(#organizationId, or: $value.organizationId),
    email: data.get(#email, or: $value.email),
    status: data.get(#status, or: $value.status),
    expiresAt: data.get(#expiresAt, or: $value.expiresAt),
    organizationName: data.get(#organizationName, or: $value.organizationName),
    role: data.get(#role, or: $value.role),
  );

  @override
  OrganizationInviteCopyWith<$R2, OrganizationInvite, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrganizationInviteCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

