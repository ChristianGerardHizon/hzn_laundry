import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/nav_permissions.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';

/// Whether the signed-in user may pay / view billing for [organizationId].
///
/// Mirrors the server guard (`requireOrgBillingAdmin`): platform system admins
/// or members who can manage the organization.
bool canManageOrgBilling(WidgetRef ref, String organizationId) {
  // Watch the controller so this recomputes once memberships load.
  ref.watch(currentOrganizationControllerProvider);
  if (ref.watch(currentUserRoleProvider).value?.isAdmin == true) return true;
  return ref
          .read(currentOrganizationControllerProvider.notifier)
          .membershipFor(organizationId)
          ?.canManageMembers ==
      true;
}
