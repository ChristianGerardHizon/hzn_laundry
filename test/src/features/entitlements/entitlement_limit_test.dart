import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/features/entitlements/data/dto/organization_entitlements_dto.dart';
import 'package:hzn_laundry/src/features/entitlements/domain/entitlement_limit.dart';

void main() {
  group('EntitlementLimit', () {
    test('unlimited is never reached', () {
      const l = EntitlementLimit.unlimited(LimitKey.branches);
      expect(l.isUnlimited, isTrue);
      expect(l.isReached, isFalse);
      expect(l.usageLabel, '0 / Unlimited');
    });

    test('isReached when used >= limit', () {
      const under =
          EntitlementLimit(key: LimitKey.employees, limit: 3, used: 2);
      const at = EntitlementLimit(key: LimitKey.employees, limit: 3, used: 3);
      const over = EntitlementLimit(key: LimitKey.employees, limit: 3, used: 5);
      expect(under.isReached, isFalse);
      expect(at.isReached, isTrue);
      expect(over.isReached, isTrue);
      expect(at.usageLabel, '3 / 3');
    });
  });

  group('OrganizationEntitlementsDto limits', () {
    test('parses limits, treats 0/null as unlimited, skips unknown keys', () {
      final e = OrganizationEntitlementsDto.fromJson({
        'hasSubscription': true,
        'items': [],
        'limits': [
          {
            'key': 'branches',
            'limit': 2,
            'used': 2,
            'planLimit': 2,
            'overrideValue': null,
            'source': 'plan',
          },
          {
            'key': 'employees',
            'limit': 0,
            'used': 7,
            'planLimit': 5,
            'overrideValue': 0,
            'source': 'superAdmin',
            'note': 'VIP',
          },
          {'key': 'mystery', 'limit': 1, 'used': 0},
        ],
      });

      final branches = e.limitOf(LimitKey.branches);
      expect(branches.limit, 2);
      expect(branches.isReached, isTrue);
      expect(branches.source, LimitSource.plan);
      expect(branches.hasOverride, isFalse);

      final employees = e.limitOf(LimitKey.employees);
      expect(employees.limit, isNull);
      expect(employees.isReached, isFalse);
      expect(employees.hasOverride, isTrue);
      expect(employees.source, LimitSource.superAdmin);
      expect(employees.note, 'VIP');
      expect(e.limits.length, 2);
    });

    test('missing limits payload yields unlimited fallbacks', () {
      final e = OrganizationEntitlementsDto.fromJson({'items': []});
      expect(e.limitOf(LimitKey.branches).isUnlimited, isTrue);
      expect(e.limitOf(LimitKey.employees).isReached, isFalse);
    });
  });
}
