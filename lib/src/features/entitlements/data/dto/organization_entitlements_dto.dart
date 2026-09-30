import '../../domain/entitlement_limit.dart';
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
    final limits = <LimitKey, EntitlementLimit>{};
    final rawLimits = json['limits'];
    if (rawLimits is List) {
      for (final raw in rawLimits) {
        if (raw is! Map) continue;
        final key = LimitKey.fromKey(raw['key'] as String? ?? '');
        if (key == null) continue; // Unknown key from a newer server.
        limits[key] = EntitlementLimit(
          key: key,
          limit: _asPositiveInt(raw['limit']),
          used: _asInt(raw['used']) ?? 0,
          planLimit: _asPositiveInt(raw['planLimit']),
          overrideValue: _asInt(raw['overrideValue']),
          source: LimitSource.fromString(raw['source'] as String?),
          note: raw['note'] as String? ?? '',
        );
      }
    }
    return OrganizationEntitlements(
      items: items,
      limits: limits,
      hasSubscription: json['hasSubscription'] as bool? ?? true,
      packageName: json['packageName'] as String? ?? '',
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// A limit of 0 / null means unlimited.
  static int? _asPositiveInt(dynamic value) {
    final v = _asInt(value);
    return v != null && v > 0 ? v : null;
  }
}
