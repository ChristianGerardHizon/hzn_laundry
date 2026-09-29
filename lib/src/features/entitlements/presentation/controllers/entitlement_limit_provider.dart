import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entitlement_limit.dart';
import 'organization_entitlements_provider.dart';

part 'entitlement_limit_provider.g.dart';

/// Resolved limit and usage for the current organization.
///
/// Unlimited while entitlements are loading or if the fetch failed (the server
/// still enforces).
@riverpod
EntitlementLimit entitlementLimit(Ref ref, LimitKey key) {
  final entitlements = ref.watch(currentOrganizationEntitlementsProvider).value;
  return entitlements?.limitOf(key) ?? EntitlementLimit.unlimited(key);
}
