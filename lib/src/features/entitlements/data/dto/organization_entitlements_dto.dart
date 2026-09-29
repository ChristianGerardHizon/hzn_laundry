import '../../domain/feature_entitlement.dart';
import '../../domain/feature_key.dart';
import '../../domain/organization_entitlements.dart';

/// Parses the `/api/organizations/{id}/entitlements` response.
class OrganizationEntitlementsDto {
  const OrganizationEntitlementsDto._();

  static OrganizationEntitlements fromJson(Map<String, dynamic> json) {
    final items = <FeatureKey, FeatureEntitlement>{};
    final rawItems = json['items'];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is! Map) continue;
        final feature = FeatureKey.fromKey(raw['key'] as String? ?? '');
        if (feature == null) continue; // Unknown key from a newer server.
        items[feature] = FeatureEntitlement(
          feature: feature,
          enabled: raw['enabled'] as bool? ?? true,
          source: EntitlementSource.fromString(raw['source'] as String?),
          planIncluded: raw['planIncluded'] as bool? ?? true,
          overrideEnabled: raw['overrideEnabled'] as bool?,
          note: raw['note'] as String? ?? '',
          blockedBy: FeatureKey.fromKey(raw['blockedBy'] as String? ?? ''),
        );
      }
    }
    return OrganizationEntitlements(
      items: items,
      hasSubscription: json['hasSubscription'] as bool? ?? true,
      packageName: json['packageName'] as String? ?? '',
    );
  }
}
