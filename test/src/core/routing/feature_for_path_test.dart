import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/routing/route_permissions.dart';
import 'package:hzn_laundry/src/features/entitlements/domain/feature_key.dart';

void main() {
  group('featureForPath', () {
    test('maps module routes to their feature', () {
      expect(featureForPath('/products'), FeatureKey.products);
      expect(featureForPath('/products/abc'), FeatureKey.products);
      expect(featureForPath('/employees'), FeatureKey.employees);
      expect(featureForPath('/reports'), FeatureKey.reports);
      expect(featureForPath('/activities'), FeatureKey.activities);
      expect(featureForPath('/promos'), FeatureKey.promos);
    });

    test('maps sub-feature management routes', () {
      expect(featureForPath('/management/storages'), FeatureKey.storages);
      expect(
        featureForPath('/management/cashier-groups'),
        FeatureKey.posGroups,
      );
    });

    test('returns null for ungated routes', () {
      expect(featureForPath('/dashboard'), isNull);
      expect(featureForPath('/customers'), isNull);
      expect(featureForPath('/management/users'), isNull);
    });
  });
}
