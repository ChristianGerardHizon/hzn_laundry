/// Broad grouping used to organize the feature list in the UI.
enum FeatureCategory { module, subFeature }

/// Catalog of features that can be granted by a subscription package or
/// forced on/off per organization by a Super Admin.
///
/// Keep in sync with `FEATURE_CATALOG` in
/// `server/pb_hooks/lib/feature_entitlements_helpers.js`.
enum FeatureKey {
  employees(
    'employees',
    'Employees',
    'Staff records and payroll deductions',
    FeatureCategory.module,
  ),
  attendance(
    'attendance',
    'Attendance',
    'Employee clock in/out records',
    FeatureCategory.module,
    requires: FeatureKey.employees,
  ),
  products(
    'products',
    'Products & inventory',
    'Product catalog, stock lots and adjustments',
    FeatureCategory.module,
  ),
  promos(
    'promos',
    'Promos',
    'Loyalty and promo campaigns',
    FeatureCategory.module,
  ),
  reports(
    'reports',
    'Reports',
    'Sales, orders, payroll and usage reports',
    FeatureCategory.module,
  ),
  activities(
    'activities',
    'Activity log',
    'Audit log of changes made in the system',
    FeatureCategory.module,
  ),
  consumableUsage(
    'consumableUsage',
    'Consumable usage',
    'Record house-chemical usage on orders',
    FeatureCategory.subFeature,
    requires: FeatureKey.products,
  ),
  machineLoadRules(
    'machineLoadRules',
    'Machine load rules',
    'Weight-to-load rules per machine',
    FeatureCategory.subFeature,
  ),
  storages(
    'storages',
    'Storage locations',
    'Storage locations for ready laundry',
    FeatureCategory.subFeature,
  ),
  posGroups(
    'posGroups',
    'Cashier layout groups',
    'Custom cashier layout with POS groups',
    FeatureCategory.subFeature,
  ),
  customerHistoryLink(
    'customerHistoryLink',
    'Customer history link',
    'Public order-history link for customers',
    FeatureCategory.subFeature,
  ),
  multiBranch(
    'multiBranch',
    'Multiple branches',
    'Branch switcher, All Branches mode and extra branches',
    FeatureCategory.subFeature,
  );

  const FeatureKey(
    this.key,
    this.label,
    this.description,
    this.category, {
    this.requires,
  });

  /// PocketBase / API key.
  final String key;
  final String label;
  final String description;
  final FeatureCategory category;

  /// Parent feature that must also be enabled.
  final FeatureKey? requires;

  static FeatureKey? fromKey(String key) {
    for (final f in FeatureKey.values) {
      if (f.key == key) return f;
    }
    return null;
  }
}
