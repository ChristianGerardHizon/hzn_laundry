import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../customers/data/repositories/customer_repository.dart';
import '../../../customers/presentation/controllers/customers_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_refresh.dart';
import '../../../employees/data/repositories/employee_repository.dart';
import '../../../employees/presentation/controllers/employees_controller.dart';
import '../../../machines/presentation/controllers/machines_controller.dart';
import '../../../pos/data/repositories/pos_group_repository.dart';
import '../../../pos/presentation/cart_controller.dart';
import '../../../pos/presentation/controllers/pos_groups_controller.dart';
import '../../../products/data/repositories/product_category_repository.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/presentation/controllers/paginated_products_controller.dart';
import '../../../promos/data/repositories/promo_repository.dart';
import '../../../promos/presentation/controllers/promos_controller.dart';
import '../../../quantity_units/data/repositories/quantity_unit_repository.dart';
import '../../../sales/presentation/controllers/paginated_sales_controller.dart';
import '../../../sales/presentation/controllers/sale_provider.dart';
import '../../../services/data/repositories/service_category_repository.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../../services/presentation/controllers/services_controller.dart';
import '../../../settings/presentation/controllers/printer_configs_controller.dart';
import '../../../settings/presentation/controllers/product_categories_controller.dart';
import '../../../settings/presentation/controllers/quantity_units_controller.dart';
import '../../../storages/presentation/controllers/storage_locations_controller.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/data/repositories/user_role_repository.dart';
import '../../../users/presentation/controllers/paginated_users_controller.dart';
import '../../../users/presentation/controllers/org_pending_invites_controller.dart';
import '../../../users/presentation/controllers/user_entity_cache.dart';
import '../../../users/presentation/controllers/user_roles_controller.dart';

/// Flushes tenant-scoped keepAlive providers and repository TTL caches.
///
/// Call after the current organization id has been persisted and reloaded so
/// All Branches / list screens cannot keep showing the previous org's data.
///
/// Uses [ProviderContainer.invalidate] (not [Ref.invalidate]) because this runs
/// from an ancestor of org-scoped providers; Ref.invalidate would trip
/// Riverpod's circular-dependency assert in debug.
void invalidateOrganizationScopedProviders(Ref ref) {
  final invalidate = ref.container.invalidate;
  invalidateAllDashboardProviders(invalidate);

  invalidate(cartControllerProvider);
  invalidate(customersControllerProvider);
  invalidate(paginatedSalesControllerProvider);
  invalidate(saleProvider);
  invalidate(paginatedProductsControllerProvider);
  invalidate(servicesControllerProvider);
  invalidate(promosControllerProvider);
  invalidate(employeesControllerProvider);
  invalidate(paginatedUsersControllerProvider);
  invalidate(orgPendingInvitesControllerProvider);
  invalidate(userRolesControllerProvider);
  invalidate(machinesControllerProvider);
  invalidate(storageLocationsControllerProvider);
  invalidate(printerConfigsControllerProvider);
  invalidate(posGroupsControllerProvider);
  invalidate(productCategoriesControllerProvider);
  invalidate(quantityUnitsControllerProvider);

  ref.read(customerRepositoryProvider).invalidateCache();
  ref.read(productRepositoryProvider).invalidateCache();
  ref.read(serviceRepositoryProvider).invalidateCache();
  ref.read(promoRepositoryProvider).invalidateCache();
  ref.read(employeeRepositoryProvider).invalidateCache();
  ref.read(userRepositoryProvider).invalidateCache();
  ref.read(userRoleRepositoryProvider).invalidateCache();
  ref.read(posGroupRepositoryProvider).invalidateCache();
  ref.read(productCategoryRepositoryProvider).invalidateCache();
  ref.read(quantityUnitRepositoryProvider).invalidateCache();
  ref.read(serviceCategoryRepositoryProvider).invalidateCache();

  ref.read(userEntityCacheProvider.notifier).clear();
}
