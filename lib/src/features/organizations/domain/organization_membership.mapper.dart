// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_membership.dart';

class OrganizationMembershipMapper
    extends ClassMapperBase<OrganizationMembership> {
  OrganizationMembershipMapper._();

  static OrganizationMembershipMapper? _instance;
  static OrganizationMembershipMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationMembershipMapper._());
      UserRoleMapper.ensureInitialized();
      OrganizationMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationMembership';

  static String _$id(OrganizationMembership v) => v.id;
  static const Field<OrganizationMembership, String> _f$id = Field('id', _$id);
  static String _$organizationId(OrganizationMembership v) => v.organizationId;
  static const Field<OrganizationMembership, String> _f$organizationId = Field(
    'organizationId',
    _$organizationId,
  );
  static String _$userId(OrganizationMembership v) => v.userId;
  static const Field<OrganizationMembership, String> _f$userId = Field(
    'userId',
    _$userId,
  );
  static String _$status(OrganizationMembership v) => v.status;
  static const Field<OrganizationMembership, String> _f$status = Field(
    'status',
    _$status,
  );
  static DateTime _$joinedAt(OrganizationMembership v) => v.joinedAt;
  static const Field<OrganizationMembership, DateTime> _f$joinedAt = Field(
    'joinedAt',
    _$joinedAt,
  );
  static UserRole? _$role(OrganizationMembership v) => v.role;
  static const Field<OrganizationMembership, UserRole> _f$role = Field(
    'role',
    _$role,
    opt: true,
  );
  static Organization? _$organization(OrganizationMembership v) =>
      v.organization;
  static const Field<OrganizationMembership, Organization> _f$organization =
      Field('organization', _$organization, opt: true);

  @override
  final MappableFields<OrganizationMembership> fields = const {
    #id: _f$id,
    #organizationId: _f$organizationId,
    #userId: _f$userId,
    #status: _f$status,
    #joinedAt: _f$joinedAt,
    #role: _f$role,
    #organization: _f$organization,
  };

  static OrganizationMembership _instantiate(DecodingData data) {
    return OrganizationMembership(
      id: data.dec(_f$id),
      organizationId: data.dec(_f$organizationId),
      userId: data.dec(_f$userId),
      status: data.dec(_f$status),
      joinedAt: data.dec(_f$joinedAt),
      role: data.dec(_f$role),
      organization: data.dec(_f$organization),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationMembership fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationMembership>(map);
  }

  static OrganizationMembership fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationMembership>(json);
  }
}

mixin OrganizationMembershipMappable {
  String toJson() {
    return OrganizationMembershipMapper.ensureInitialized()
        .encodeJson<OrganizationMembership>(this as OrganizationMembership);
  }

  Map<String, dynamic> toMap() {
    return OrganizationMembershipMapper.ensureInitialized()
        .encodeMap<OrganizationMembership>(this as OrganizationMembership);
  }

  OrganizationMembershipCopyWith<
    OrganizationMembership,
    OrganizationMembership,
    OrganizationMembership
  >
  get copyWith =>
      _OrganizationMembershipCopyWithImpl<
        OrganizationMembership,
        OrganizationMembership
      >(this as OrganizationMembership, $identity, $identity);
  @override
  String toString() {
    return OrganizationMembershipMapper.ensureInitialized().stringifyValue(
      this as OrganizationMembership,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationMembershipMapper.ensureInitialized().equalsValue(
      this as OrganizationMembership,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationMembershipMapper.ensureInitialized().hashValue(
      this as OrganizationMembership,
    );
  }
}

extension OrganizationMembershipValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationMembership, $Out> {
  OrganizationMembershipCopyWith<$R, OrganizationMembership, $Out>
  get $asOrganizationMembership => $base.as(
    (v, t, t2) => _OrganizationMembershipCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationMembershipCopyWith<
  $R,
  $In extends OrganizationMembership,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  UserRoleCopyWith<$R, UserRole, UserRole>? get role;
  OrganizationCopyWith<$R, Organization, Organization>? get organization;
  $R call({
    String? id,
    String? organizationId,
    String? userId,
    String? status,
    DateTime? joinedAt,
    UserRole? role,
    Organization? organization,
  });
  OrganizationMembershipCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationMembershipCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationMembership, $Out>
    implements
        OrganizationMembershipCopyWith<$R, OrganizationMembership, $Out> {
  _OrganizationMembershipCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationMembership> $mapper =
      OrganizationMembershipMapper.ensureInitialized();
  @override
  UserRoleCopyWith<$R, UserRole, UserRole>? get role =>
      $value.role?.copyWith.$chain((v) => call(role: v));
  @override
  OrganizationCopyWith<$R, Organization, Organization>? get organization =>
      $value.organization?.copyWith.$chain((v) => call(organization: v));
  @override
  $R call({
    String? id,
    String? organizationId,
    String? userId,
    String? status,
    DateTime? joinedAt,
    Object? role = $none,
    Object? organization = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (organizationId != null) #organizationId: organizationId,
      if (userId != null) #userId: userId,
      if (status != null) #status: status,
      if (joinedAt != null) #joinedAt: joinedAt,
      if (role != $none) #role: role,
      if (organization != $none) #organization: organization,
    }),
  );
  @override
  OrganizationMembership $make(CopyWithData data) => OrganizationMembership(
    id: data.get(#id, or: $value.id),
    organizationId: data.get(#organizationId, or: $value.organizationId),
    userId: data.get(#userId, or: $value.userId),
    status: data.get(#status, or: $value.status),
    joinedAt: data.get(#joinedAt, or: $value.joinedAt),
    role: data.get(#role, or: $value.role),
    organization: data.get(#organization, or: $value.organization),
  );

  @override
  OrganizationMembershipCopyWith<$R2, OrganizationMembership, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationMembershipCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

