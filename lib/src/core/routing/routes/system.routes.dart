import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/settings/presentation/pages/system_shell.dart';
import '../../../features/settings/presentation/widgets/printer_config_detail_panel.dart';
import '../../../features/settings/presentation/widgets/theme_settings_panel.dart';
import '../../../features/settings/presentation/controllers/printer_configs_controller.dart';
import '../../../features/settings/presentation/controllers/selected_printer_id_provider.dart';
import '../../../features/settings/presentation/widgets/dialogs/printer_config_form_dialog.dart';
import '../../utils/breakpoints.dart';

part 'system.routes.g.dart';

/// System shell route for 3-panel layout.
///
/// On tablet: Shows nav rail + list + detail side-by-side
/// On mobile: Shows landing page, then list, then detail
@TypedShellRoute<SystemShellRoute>(
  routes: [
    TypedGoRoute<SystemRoute>(
      path: SystemRoute.path,
      routes: [
        // Product categories with detail
        TypedGoRoute<ProductCategoriesRoute>(
          path: 'product-categories',
          routes: [
            TypedGoRoute<ProductCategoryDetailRoute>(path: ':id'),
          ],
        ),
        // Quantity units with detail
        TypedGoRoute<QuantityUnitsRoute>(
          path: 'quantity-units',
          routes: [
            TypedGoRoute<QuantityUnitDetailRoute>(path: ':id'),
          ],
        ),
        // Machines with detail (incl. load rules)
        TypedGoRoute<MachinesRoute>(
          path: 'machines',
          routes: [
            TypedGoRoute<MachineDetailRoute>(path: ':id'),
          ],
        ),
        // Printer settings with detail
        TypedGoRoute<PrinterSettingsRoute>(
          path: 'printers',
          routes: [
            TypedGoRoute<PrinterDetailRoute>(path: ':id'),
          ],
        ),
        // Cashier layout groups with detail
        TypedGoRoute<CashierGroupsRoute>(
          path: 'cashier-groups',
          routes: [
            TypedGoRoute<CashierGroupDetailRoute>(path: ':id'),
          ],
        ),
        // Appearance/theme settings
        TypedGoRoute<AppearanceRoute>(path: 'appearance'),
        // Import products from CSV
        TypedGoRoute<ImportRoute>(path: 'import'),
        // Feature flags / workflow settings
        TypedGoRoute<FeatureFlagsRoute>(path: 'feature-flags'),
      ],
    ),
  ],
)
class SystemShellRoute extends ShellRouteData {
  const SystemShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return SystemShell(child: navigator);
  }
}

/// System root route.
///
/// On tablet: Redirects to /system/printers (3-panel layout)
/// On mobile: Shows landing page with Printers and Appearance options
class SystemRoute extends GoRouteData with $SystemRoute {
  const SystemRoute();

  static const path = '/system';

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    // Only redirect on tablet - mobile shows landing page
    if (Breakpoints.isTabletOrLarger(context) && state.uri.path == path) {
      return '$path/printers';
    }
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // Mobile: Show landing page with options
    return const _MobileSystemLandingPage();
  }
}

/// Product categories — redirected to Management.
class ProductCategoriesRoute extends GoRouteData with $ProductCategoriesRoute {
  const ProductCategoriesRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/product-categories';
  }
}

/// Product category detail — redirected to Management.
class ProductCategoryDetailRoute extends GoRouteData
    with $ProductCategoryDetailRoute {
  const ProductCategoryDetailRoute({required this.id});

  final String id;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/product-categories/${Uri.encodeComponent(id)}';
  }
}

/// Quantity units — redirected to Management.
class QuantityUnitsRoute extends GoRouteData with $QuantityUnitsRoute {
  const QuantityUnitsRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/quantity-units';
  }
}

/// Quantity unit detail — redirected to Management.
class QuantityUnitDetailRoute extends GoRouteData
    with $QuantityUnitDetailRoute {
  const QuantityUnitDetailRoute({required this.id});

  final String id;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/quantity-units/${Uri.encodeComponent(id)}';
  }
}

/// Machines — redirected to Management.
class MachinesRoute extends GoRouteData with $MachinesRoute {
  const MachinesRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/machines';
  }
}

/// Machine detail — redirected to Management.
class MachineDetailRoute extends GoRouteData with $MachineDetailRoute {
  const MachineDetailRoute({required this.id});

  final String id;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/machines/${Uri.encodeComponent(id)}';
  }
}

/// Printer settings management route.
class PrinterSettingsRoute extends GoRouteData with $PrinterSettingsRoute {
  const PrinterSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show printers list
    return const _MobilePrinterListPage();
  }
}

/// Printer detail route.
class PrinterDetailRoute extends GoRouteData with $PrinterDetailRoute {
  const PrinterDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PrinterConfigDetailPanel(printerId: id);
  }
}

/// Appearance/theme settings route.
class AppearanceRoute extends GoRouteData with $AppearanceRoute {
  const AppearanceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ThemeSettingsPanel();
  }
}

/// Import products — redirected to Management.
class ImportRoute extends GoRouteData with $ImportRoute {
  const ImportRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/import';
  }
}

/// Feature flags / workflow settings — redirected to Management.
class FeatureFlagsRoute extends GoRouteData with $FeatureFlagsRoute {
  const FeatureFlagsRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/settings';
  }
}

/// Cashier groups — redirected to Management.
class CashierGroupsRoute extends GoRouteData with $CashierGroupsRoute {
  const CashierGroupsRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/cashier-groups';
  }
}

/// Cashier group detail — redirected to Management.
class CashierGroupDetailRoute extends GoRouteData
    with $CashierGroupDetailRoute {
  const CashierGroupDetailRoute({required this.id});

  final String id;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/management/cashier-groups/${Uri.encodeComponent(id)}';
  }
}

// ============================================================================
// Mobile Pages
// ============================================================================

/// Mobile landing page for system settings with option cards.
class _MobileSystemLandingPage extends StatelessWidget {
  const _MobileSystemLandingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SystemOptionCard(
            icon: Icons.print,
            title: 'Printers',
            description: 'Configure thermal receipt printers on this device',
            color: Colors.orange,
            onTap: () => const PrinterSettingsRoute().go(context),
          ),
          const SizedBox(height: 16),
          _SystemOptionCard(
            icon: Icons.palette,
            title: 'Appearance',
            description: 'Customize app theme and colors',
            color: Colors.purple,
            onTap: () => const AppearanceRoute().go(context),
          ),
        ],
      ),
    );
  }
}

/// Card widget for system option selection.
class _SystemOptionCard extends StatelessWidget {
  const _SystemOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile printer list page.
class _MobilePrinterListPage extends ConsumerWidget {
  const _MobilePrinterListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final printersAsync = ref.watch(printerConfigsControllerProvider);
    final controller = ref.read(printerConfigsControllerProvider.notifier);
    final selectedPrinterId = ref.watch(selectedPrinterIdProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printers'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'printer_fab',
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
      body: printersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (printers) {
          if (printers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.print_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No printers configured',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a printer',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              itemCount: printers.length,
              itemBuilder: (context, index) {
                final printer = printers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      printer.connectionType.icon,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(printer.name)),
                      if (selectedPrinterId == printer.id)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Selected',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${printer.connectionType.displayName} • ${printer.paperWidth.displayName}',
                  ),
                  trailing: printer.isEnabled
                      ? const Icon(Icons.chevron_right)
                      : Icon(Icons.block, color: theme.colorScheme.error),
                  onTap: () => PrinterDetailRoute(id: printer.id).push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showPrinterConfigFormDialog(context);
  }
}
