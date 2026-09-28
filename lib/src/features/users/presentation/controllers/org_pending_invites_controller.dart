import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../organizations/data/repositories/organization_invite_repository.dart';
import '../../../organizations/domain/organization_invite.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';

part 'org_pending_invites_controller.g.dart';

/// Outcome of [OrgPendingInvitesController.resend].
enum InviteResendResult {
  sent,
  alreadyAccepted,
  stale,
  failed,
}

/// Pending organization invites for the current org (Management Users).
@Riverpod(keepAlive: true)
class OrgPendingInvitesController extends _$OrgPendingInvitesController {
  @override
  Future<List<OrganizationInvite>> build() async {
    final orgId = ref.watch(currentOrganizationIdProvider);
    if (orgId == null || orgId.isEmpty) return const [];

    final result = await ref
        .read(organizationInviteRepositoryProvider)
        .listForOrganization(orgId);

    return result.fold((_) => const [], (list) => list);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final orgId = ref.read(currentOrganizationIdProvider);
      if (orgId == null || orgId.isEmpty) return const <OrganizationInvite>[];
      final result = await ref
          .read(organizationInviteRepositoryProvider)
          .listForOrganization(orgId);
      return result.fold((f) => throw f, (list) => list);
    });
  }

  void _removeLocally(String inviteId) {
    state.whenData((list) {
      state = AsyncValue.data(
        list.where((i) => i.id != inviteId).toList(),
      );
    });
  }

  Future<bool> revoke(String inviteId) async {
    final result =
        await ref.read(organizationInviteRepositoryProvider).revoke(inviteId);
    return result.fold(
      (_) => false,
      (_) {
        _removeLocally(inviteId);
        return true;
      },
    );
  }

  Future<InviteResendResult> resend(String inviteId) async {
    final result =
        await ref.read(organizationInviteRepositoryProvider).resend(inviteId);

    final outcome = result.fold(
      (failure) {
        final msg = Failure.displayErrorMessage(failure).toLowerCase();
        if (msg.contains('already accepted')) {
          return InviteResendResult.alreadyAccepted;
        }
        if (msg.contains('expired') || msg.contains('no longer pending')) {
          return InviteResendResult.stale;
        }
        return InviteResendResult.failed;
      },
      (_) => InviteResendResult.sent,
    );

    if (outcome == InviteResendResult.alreadyAccepted ||
        outcome == InviteResendResult.stale) {
      _removeLocally(inviteId);
      await refresh();
    }

    return outcome;
  }
}
