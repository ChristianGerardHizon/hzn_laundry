import 'entitlement_limit.dart';
import 'feature_entitlement.dart';
import 'feature_key.dart';

/// Resolved feature entitlements and limits for one organization.
class OrganizationEntitlements {
  const OrganizationEntitlements({
    required this.items,
    this.limits = const {},
    this.hasSubscription = true,
    this.packageName = '',
  });

  /// Everything enabled and unlimited. Used while unresolved or when the fetch
  /// fails, so a transient error never hides the whole app (the server still
  /// enforces).
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
  final Map<LimitKey, EntitlementLimit> limits;
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

  /// Limit for [key]; unlimited when missing from the response.
  EntitlementLimit limitOf(LimitKey key) =>
      limits[key] ?? EntitlementLimit.unlimited(key);

  /// Entitlements in catalog order.
  List<FeatureEntitlement> get ordered =>
      [for (final f in FeatureKey.values) of(f)];

  /// Limits in catalog order.
  List<EntitlementLimit> get orderedLimits =>
      [for (final l in LimitKey.values) limitOf(l)];
}
