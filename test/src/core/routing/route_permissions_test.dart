import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/routing/route_permissions.dart';
import 'package:hzn_laundry/src/core/routing/routes/dashboard.routes.dart';
import 'package:hzn_laundry/src/core/routing/routes/products.routes.dart';
import 'package:hzn_laundry/src/features/users/domain/user_role.dart';

void main() {
  group('canAccessPath', () {
    test('dashboard and organizations are always allowed', () {
      expect(canAccessPath(DashboardRoute.path, null), isTrue);
      expect(canAccessPath('/organizations', null), isTrue);
    });

    test('products requires products.view when role is set', () {
      final role = UserRole(
        id: 'r1',
        name: 'Cashier',
        permissions: const [Permissions.salesView],
      );
      expect(canAccessPath(ProductsRoute.path, role), isFalse);

      final withProducts = UserRole(
        id: 'r2',
        name: 'Stock',
        permissions: const [Permissions.productsView],
      );
      expect(canAccessPath(ProductsRoute.path, withProducts), isTrue);
    });

    test('admin can access everything', () {
      final admin = UserRole(
        id: 'admin',
        name: 'Admin',
        permissions: const [Permissions.systemAdmin],
      );
      expect(canAccessPath(ProductsRoute.path, admin), isTrue);
      expect(canAccessPath('/management/users', admin), isTrue);
    });
  });

  group('fallbackPathFor', () {
    test('returns dashboard when nothing else is allowed', () {
      final role = UserRole(
        id: 'r1',
        name: 'Limited',
        permissions: const [],
      );
      expect(fallbackPathFor(role), DashboardRoute.path);
    });
  });

  group('matchesRoutePath', () {
    test('does not treat sibling prefixes as nested', () {
      expect(matchesRoutePath('/memberships', '/members'), isFalse);
      expect(matchesRoutePath('/products/abc', ProductsRoute.path), isTrue);
    });
  });
}
