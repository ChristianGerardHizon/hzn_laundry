import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../data/repositories/entitlement_repository.dart';
import '../../domain/organization_entitlements.dart';

part 'organization_entitlements_provider.g.dart';

/// Resolved entitlements for the current organization.
///
/// Re-resolves automatically when the current organization changes. Fails open
/// (everything enabled) on errors: the server guards still enforce, and a
/// transient network error must not hide the whole app.
@Riverpod(keepAlive: true)
Future<OrganizationEntitlements> currentOrganizationEntitlements(
    Ref ref) async {
  final orgId = ref.watch(currentOrganizationIdProvider);
  if (orgId == null || orgId.isEmpty) {
    return OrganizationEntitlements.allEnabled();
  }
  final result = await ref.read(entitlementRepositoryProvider).fetch(orgId);
  return result.fold(
    (_) => OrganizationEntitlements.allEnabled(),
    (entitlements) => entitlements,
  );
}

/// Entitlements for any organization by id (Super Admin feature access UI).
@riverpod
Future<OrganizationEntitlements> organizationEntitlements(
  Ref ref,
  String organizationId,
) async {
  final result =
      await ref.read(entitlementRepositoryProvider).fetch(organizationId);
  return result.fold((failure) => throw failure, (value) => value);
}
