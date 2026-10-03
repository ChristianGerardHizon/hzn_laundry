import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/feature_key.dart';
import 'organization_entitlements_provider.dart';

part 'feature_enabled_provider.g.dart';

/// Whether [feature] is enabled for the current organization.
///
/// While entitlements are still loading this returns `true` so navigation does
/// not flicker or redirect deep links prematurely; server guards still apply.
@Riverpod(keepAlive: true)
bool featureEnabled(Ref ref, FeatureKey feature) {
  final entitlements = ref.watch(currentOrganizationEntitlementsProvider);
  // Default-off features stay hidden until entitlements actually resolve.
  return entitlements.value?.isEnabled(feature) ?? !feature.defaultOff;
}
