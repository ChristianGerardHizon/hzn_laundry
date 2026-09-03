import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/system.routes.dart';
import '../../../pos/presentation/services/thermal_print_service.dart';
import '../controllers/printer_configs_controller.dart';
import '../controllers/selected_printer_id_provider.dart';
import 'dialogs/printer_config_form_dialog.dart';
import 'empty_system_state.dart';
import 'system_nav_panel.dart';
import 'theme_settings_panel.dart';

/// Three-panel tablet layout for device-specific system settings.
class TabletSystemLayout extends ConsumerWidget {
  const TabletSystemLayout({
    super.key,
    required this.detailChild,
  });

  /// The detail panel content from the router.
  final Widget detailChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerState = GoRouterState.of(context);
    final path = routerState.uri.path;
    final selectedId = routerState.pathParameters['id'];

    final currentMode = path.contains('/appearance')
        ? SystemMode.appearance
        : SystemMode.printers;

    return Row(
      children: [
        SystemNavPanel(
          currentMode: currentMode,
          onModeChanged: (mode) {
            switch (mode) {
              case SystemMode.printers:
                const PrinterSettingsRoute().go(context);
              case SystemMode.appearance:
                const AppearanceRoute().go(context);
            }
          },
        ),
        const VerticalDivider(width: 1),
        if (currentMode == SystemMode.appearance)
          const Expanded(child: ThemeSettingsPanel())
        else ...[
          SizedBox(
            width: 320,
            child: _PrinterListWrapper(selectedId: selectedId),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedId != null
                ? detailChild
                : EmptySystemState(mode: currentMode),
          ),
        ],
      ],
    );
  }
}

class _PrinterListWrapper extends ConsumerWidget {
  const _PrinterListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final printersAsync = ref.watch(printerConfigsControllerProvider);
    final controller = ref.read(printerConfigsControllerProvider.notifier);
    final selectedPrinterId = ref.watch(selectedPrinterIdProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printers'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'printer_fab',
        onPressed: () => showPrinterConfigFormDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (!isThermalPrintingSupported)
            Container(
              width: double.infinity,
              color: theme.colorScheme.secondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      kThermalPrintingUnsupportedMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: printersAsync.when(
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
                      final isSelected = printer.id == selectedId;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primaryContainer,
                          child: Icon(
                            printer.connectionType.icon,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onPrimaryContainer,
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
                        onTap: () =>
                            PrinterDetailRoute(id: printer.id).go(context),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
