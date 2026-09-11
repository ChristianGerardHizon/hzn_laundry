import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../users/data/dto/user_role_dto.dart';
import '../../domain/organization_invite.dart';

part 'organization_invite_dto.mapper.dart';

@MappableClass()
class OrganizationInviteDto with OrganizationInviteDtoMappable {
  const OrganizationInviteDto({
    required this.id,
    required this.organization,
    required this.email,
    required this.status,
    required this.expiresAt,
    this.role,
    this.organizationName,
    this.expandedRole,
  });

  final String id;
  final String organization;
  final String? organizationName;
  final String email;
  final String? role;
  final String status;
  final String expiresAt;
  final UserRoleDto? expandedRole;

  factory OrganizationInviteDto.fromJson(Map<String, dynamic> json) {
    UserRoleDto? roleDto;
    String? orgName;
    final expand = json['expand'];
    if (expand is Map<String, dynamic>) {
      final roleJson = expand['role'];
      if (roleJson is Map<String, dynamic>) {
        roleDto = UserRoleDto.fromJson(roleJson);
      }
      final orgJson = expand['organization'];
      if (orgJson is Map<String, dynamic>) {
        orgName = orgJson['name'] as String?;
      }
    }

    return OrganizationInviteDto(
      id: json['id'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      organizationName: orgName,
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
      status: json['status'] as String? ?? 'pending',
      expiresAt: json['expiresAt'] as String? ?? '',
      expandedRole: roleDto,
    );
  }

  factory OrganizationInviteDto.fromRecord(RecordModel record) {
    return OrganizationInviteDto.fromJson(record.toJson());
  }

  OrganizationInvite toEntity() {
    return OrganizationInvite(
      id: id,
      organizationId: organization,
      organizationName: organizationName,
      email: email,
      status: status,
      expiresAt: parseToLocal(expiresAt) ?? DateTime.now(),
      role: expandedRole?.toEntity(),
    );
  }
}
