/// Numeric limits enforced per organization.
///
/// Keep in sync with `LIMIT_CATALOG` in
/// `server/pb_hooks/lib/feature_entitlements_helpers.js`.
enum LimitKey {
  branches('branches', 'Branches'),
  employees('employees', 'Employees');

  const LimitKey(this.key, this.label);

  final String key;
  final String label;

  static LimitKey? fromKey(String key) {
    for (final l in LimitKey.values) {
      if (l.key == key) return l;
    }
    return null;
  }
}

/// Where the effective limit came from.
enum LimitSource {
  /// Package value.
  plan('plan'),

  /// Super Admin override for this organization.
  superAdmin('superAdmin'),

  /// No limit set anywhere.
  unlimited('unlimited');

  const LimitSource(this.value);

  final String value;

  static LimitSource fromString(String? value) {
    for (final s in LimitSource.values) {
      if (s.value == value) return s;
    }
    return LimitSource.unlimited;
  }
}

/// Resolved limit and current usage for one [LimitKey].
class EntitlementLimit {
  const EntitlementLimit({
    required this.key,
    this.limit,
    this.used = 0,
    this.planLimit,
    this.overrideValue,
    this.source = LimitSource.unlimited,
    this.note = '',
  });

  /// No limit and no usage information (used while unresolved / on errors).
  const EntitlementLimit.unlimited(this.key)
      : limit = null,
        used = 0,
        planLimit = null,
        overrideValue = null,
        source = LimitSource.unlimited,
        note = '';

  final LimitKey key;

  /// Effective maximum. `null` means unlimited.
  final int? limit;

  /// Current non-deleted count in the organization.
  final int used;

  /// Package value (`null` = unlimited).
  final int? planLimit;

  /// Super Admin override (`null` = none; `0` = forced unlimited).
  final int? overrideValue;
  final LimitSource source;
  final String note;

  bool get isUnlimited => limit == null;
  bool get hasOverride => overrideValue != null;

  /// True when no more can be added.
  bool get isReached => limit != null && used >= limit!;

  /// e.g. `3 / 5` or `3 / Unlimited`.
  String get usageLabel => '$used / ${limit ?? 'Unlimited'}';
}
