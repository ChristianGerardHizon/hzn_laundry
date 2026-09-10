import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../users/data/dto/user_role_dto.dart';
import '../../domain/organization_membership.dart';
import 'organization_dto.dart';

part 'organization_membership_dto.mapper.dart';

@MappableClass()
class OrganizationMembershipDto with OrganizationMembershipDtoMappable {
  const OrganizationMembershipDto({
    required this.id,
    required this.organization,
    required this.user,
    required this.status,
    required this.joinedAt,
    this.role,
    this.expandedOrganization,
    this.expandedRole,
  });

  final String id;
  final String organization;
  final String user;
  final String? role;
  final String status;
  final String joinedAt;
  final OrganizationDto? expandedOrganization;
  final UserRoleDto? expandedRole;

  factory OrganizationMembershipDto.fromRecord(RecordModel record) {
    final json = record.toJson();
    OrganizationDto? org;
    UserRoleDto? roleDto;

    final expand = json['expand'];
    if (expand is Map<String, dynamic>) {
      final orgJson = expand['organization'];
      if (orgJson is Map<String, dynamic>) {
        org = OrganizationDto.fromJson(orgJson);
      }
      final roleJson = expand['role'];
      if (roleJson is Map<String, dynamic>) {
        roleDto = UserRoleDto.fromJson(roleJson);
      }
    }

    return OrganizationMembershipDto(
      id: json['id'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      user: json['user'] as String? ?? '',
      role: json['role'] as String?,
      status: json['status'] as String? ?? 'active',
      joinedAt: json['joinedAt'] as String? ?? '',
      expandedOrganization: org,
      expandedRole: roleDto,
    );
  }

  OrganizationMembership toEntity() {
    return OrganizationMembership(
      id: id,
      organizationId: organization,
      userId: user,
      status: status,
      joinedAt: parseToLocal(joinedAt) ?? DateTime.now(),
      role: expandedRole?.toEntity(),
      organization: expandedOrganization?.toEntity(),
    );
  }
}
