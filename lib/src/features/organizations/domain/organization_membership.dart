import 'package:dart_mappable/dart_mappable.dart';

import '../../users/domain/user_role.dart';
import 'organization.dart';

part 'organization_membership.mapper.dart';

/// Join between a user and an organization, with a role for that org.
@MappableClass()
class OrganizationMembership with OrganizationMembershipMappable {
  const OrganizationMembership({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    this.role,
    this.organization,
  });

  final String id;
  final String organizationId;
  final String userId;
  final UserRole? role;
  final String status;
  final DateTime joinedAt;
  final Organization? organization;

  bool get isActive => status == 'active';

  bool get canManageMembers =>
      role?.hasPermission(Permissions.membersManage) == true ||
      (role?.isAdmin ?? false);

  String get organizationName => organization?.name ?? organizationId;

  String get roleName => role?.name ?? '';
}
