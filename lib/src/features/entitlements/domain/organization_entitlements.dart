import 'feature_entitlement.dart';
import 'feature_key.dart';

/// Resolved feature entitlements for one organization.
class OrganizationEntitlements {
  const OrganizationEntitlements({
    required this.items,
    this.hasSubscription = true,
    this.packageName = '',
  });

  /// Everything enabled. Used while unresolved or when the fetch fails, so a
  /// transient error never hides the whole app (the server still enforces).
  factory OrganizationEntitlements.allEnabled() {
    return OrganizationEntitlements(
      hasSubscription: false,
      items: {
        for (final f in FeatureKey.values)
          f: FeatureEntitlement(
            feature: f,
            enabled: true,
            source: EntitlementSource.plan,
          ),
      },
    );
  }

  final Map<FeatureKey, FeatureEntitlement> items;
  final bool hasSubscription;
  final String packageName;

  FeatureEntitlement of(FeatureKey feature) {
    return items[feature] ??
        FeatureEntitlement(
          feature: feature,
          enabled: true,
          source: EntitlementSource.plan,
        );
  }

  bool isEnabled(FeatureKey feature) => of(feature).enabled;

  /// Entitlements in catalog order.
  List<FeatureEntitlement> get ordered =>
      [for (final f in FeatureKey.values) of(f)];
}
