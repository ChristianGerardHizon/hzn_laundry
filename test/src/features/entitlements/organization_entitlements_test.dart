import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/widgets/nav_permissions.dart';
import 'package:hzn_laundry/src/features/entitlements/data/dto/organization_entitlements_dto.dart';
import 'package:hzn_laundry/src/features/entitlements/domain/feature_entitlement.dart';
import 'package:hzn_laundry/src/features/entitlements/domain/feature_key.dart';
import 'package:hzn_laundry/src/features/entitlements/domain/organization_entitlements.dart';
import 'package:hzn_laundry/src/features/users/domain/user_role.dart';

void main() {
  group('OrganizationEntitlements', () {
    test('allEnabled enables every feature except default-off ones', () {
      final all = OrganizationEntitlements.allEnabled();
      for (final f in FeatureKey.values) {
        expect(all.isEnabled(f), !f.defaultOff, reason: f.key);
      }
      expect(all.ordered.length, FeatureKey.values.length);
    });

    test('delivery is default-off and never enabled by fallbacks', () {
      expect(FeatureKey.delivery.defaultOff, isTrue);
      expect(OrganizationEntitlements.allEnabled().isEnabled(FeatureKey.delivery),
          isFalse);
      const e = OrganizationEntitlements(items: {});
      expect(e.isEnabled(FeatureKey.delivery), isFalse);
    });

    test('of() fails open for features missing from the response', () {
      const e = OrganizationEntitlements(items: {});
      expect(e.isEnabled(FeatureKey.reports), isTrue);
    });
  });

  group('OrganizationEntitlementsDto', () {
    test('parses sources, overrides, blockedBy, and package name', () {
      final e = OrganizationEntitlementsDto.fromJson({
        'hasSubscription': true,
        'packageName': 'Basic',
        'items': [
          {
            'key': 'reports',
            'enabled': true,
            'source': 'superAdminEnabled',
            'planIncluded': false,
            'overrideEnabled': true,
            'note': 'Trial',
          },
          {
            'key': 'employees',
            'enabled': false,
            'source': 'superAdminDisabled',
            'planIncluded': true,
            'overrideEnabled': false,
          },
          {
            'key': 'attendance',
            'enabled': false,
            'source': 'plan',
            'planIncluded': true,
            'blockedBy': 'employees',
          },
          {'key': 'promos', 'enabled': false, 'source': 'notInPlan'},
          {'key': 'someFutureFeature', 'enabled': true, 'source': 'plan'},
        ],
      });

      expect(e.packageName, 'Basic');
      expect(e.hasSubscription, isTrue);

      final reports = e.of(FeatureKey.reports);
      expect(reports.enabled, isTrue);
      expect(reports.source, EntitlementSource.superAdminEnabled);
      expect(reports.hasOverride, isTrue);
      expect(reports.planIncluded, isFalse);
      expect(reports.note, 'Trial');

      final employees = e.of(FeatureKey.employees);
      expect(employees.enabled, isFalse);
      expect(employees.source, EntitlementSource.superAdminDisabled);
      expect(employees.source.isOverride, isTrue);

      final attendance = e.of(FeatureKey.attendance);
      expect(attendance.enabled, isFalse);
      expect(attendance.blockedBy, FeatureKey.employees);
      expect(attendance.hasOverride, isFalse);

      expect(e.of(FeatureKey.promos).source, EntitlementSource.notInPlan);
      // Unknown keys are ignored.
      expect(e.items.length, 4);
    });

    test('defaults to plan source and empty items when fields are missing', () {
      final e = OrganizationEntitlementsDto.fromJson({});
      expect(e.items, isEmpty);
      expect(e.hasSubscription, isTrue);
      expect(EntitlementSource.fromString('bogus'), EntitlementSource.plan);
    });
  });

  group('filterNavItems feature gating', () {
    final allItems = buildAllNavItems((key) => key);
    final admin = UserRole(
      id: 'admin',
      name: 'Admin',
      permissions: const ['system.admin'],
    );

    test('without a feature callback nothing is hidden by features', () {
      expect(
        filterNavItems(allItems, admin).map((i) => i.id),
        allItems.map((i) => i.id),
      );
    });

    test('hides items whose feature is off, even for admins', () {
      final visible = filterNavItems(
        allItems,
        admin,
        isFeatureEnabled: (f) =>
            f != FeatureKey.employees && f != FeatureKey.reports,
      ).map((i) => i.id);

      expect(visible, isNot(contains(NavId.employees)));
      expect(visible, isNot(contains(NavId.reports)));
      expect(visible, contains(NavId.products));
      expect(visible, contains(NavId.dashboard));
    });
  });
}
