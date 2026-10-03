import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../organizations/data/repositories/organization_membership_repository.dart';
import '../../../organizations/domain/organization_membership.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import 'user_provider.dart';

part 'user_org_assignment_provider.g.dart';

/// Role (from current-org membership) + branch (from users record).
class UserOrgAssignment {
  const UserOrgAssignment({
    this.roleId,
    this.roleName,
    this.branchId,
    this.branchName,
  });

  final String? roleId;
  final String? roleName;
  final String? branchId;
  final String? branchName;

  String get displayRole =>
      (roleName != null && roleName!.isNotEmpty) ? roleName! : 'No Role';

  String get displayBranch =>
      (branchName != null && branchName!.isNotEmpty) ? branchName! : 'No Branch';

  bool get hasRole => roleId != null && roleId!.isNotEmpty;

  bool get hasBranch => branchId != null && branchId!.isNotEmpty;
}

/// Assignment for [userId] in the currently selected organization.
///
/// Role comes from `organizationMemberships`; branch from the users record.
@riverpod
Future<UserOrgAssignment> userOrgAssignment(Ref ref, String userId) async {
  final orgId = ref.watch(currentOrganizationIdProvider);
  final user = await ref.watch(userProvider(userId).future);

  final branchId = user?.branchId;
  final branchName = user?.branchName;

  if (orgId == null || orgId.isEmpty || userId.isEmpty) {
    return UserOrgAssignment(
      branchId: branchId,
      branchName: branchName,
    );
  }

  final authUserId = ref.watch(currentAuthProvider)?.user.id;
  OrganizationMembership? membership;

  if (authUserId != null && authUserId == userId) {
    await ref.watch(currentOrganizationControllerProvider.future);
    membership = ref
        .read(currentOrganizationControllerProvider.notifier)
        .membershipFor(orgId);
  } else {
    final result = await ref
        .read(organizationMembershipRepositoryProvider)
        .findForUserInOrganization(userId, orgId);
    membership = result.fold((_) => null, (value) => value);
  }

  final roleName = membership?.roleName;
  return UserOrgAssignment(
    roleId: membership?.role?.id,
    roleName: (roleName != null && roleName.isNotEmpty) ? roleName : null,
    branchId: branchId,
    branchName: branchName,
  );
}
