import 'package:dart_mappable/dart_mappable.dart';

import '../../users/domain/user_role.dart';

part 'organization_invite.mapper.dart';

/// Token-based invite to join an organization. Token is server-hidden.
@MappableClass()
class OrganizationInvite with OrganizationInviteMappable {
  const OrganizationInvite({
    required this.id,
    required this.organizationId,
    required this.email,
    required this.status,
    required this.expiresAt,
    this.organizationName,
    this.role,
  });

  final String id;
  final String organizationId;
  final String? organizationName;
  final String email;
  final UserRole? role;
  final String status;
  final DateTime expiresAt;

  bool get isPending => status == 'pending';

  String get roleName => role?.name ?? '';
}
