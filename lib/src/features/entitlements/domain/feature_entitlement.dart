import 'feature_key.dart';

/// Why a feature resolved to its current state for an organization.
enum EntitlementSource {
  /// Included in the organization's subscription package (or legacy org with
  /// no subscription).
  plan('plan'),

  /// Not part of the subscription package and not overridden.
  notInPlan('notInPlan'),

  /// Super Admin forced the feature on, regardless of the package.
  superAdminEnabled('superAdminEnabled'),

  /// Super Admin forced the feature off, regardless of the package.
  superAdminDisabled('superAdminDisabled');

  const EntitlementSource(this.value);

  final String value;

  bool get isOverride =>
      this == EntitlementSource.superAdminEnabled ||
      this == EntitlementSource.superAdminDisabled;

  static EntitlementSource fromString(String? value) {
    for (final s in EntitlementSource.values) {
      if (s.value == value) return s;
    }
    return EntitlementSource.plan;
  }
}

/// Resolved state of one feature for an organization.
class FeatureEntitlement {
  const FeatureEntitlement({
    required this.feature,
    required this.enabled,
    required this.source,
    this.planIncluded = true,
    this.overrideEnabled,
    this.note = '',
    this.blockedBy,
  });

  final FeatureKey feature;

  /// Final state after override, plan, and dependency resolution.
  final bool enabled;
  final EntitlementSource source;

  /// Whether the subscription package includes this feature.
  final bool planIncluded;

  /// Super Admin override value; null means "follow plan".
  final bool? overrideEnabled;
  final String note;

  /// Parent feature that is off, making this one unavailable.
  final FeatureKey? blockedBy;

  bool get hasOverride => overrideEnabled != null;
}
