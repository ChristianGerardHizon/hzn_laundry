import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../../core/utils/permission_service.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../../../pos/presentation/services/thermal_print_service.dart';

/// Dialog for discovering Bluetooth printers.
class PrinterDiscoveryDialog extends HookConsumerWidget {
  const PrinterDiscoveryDialog({
    super.key,
    required this.onPrinterSelected,
  });

  final void Function(String name, String address) onPrinterSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    final isScanning = useState(false);
    final devices = useState<List<BluetoothInfo>>([]);
    final error = useState<String?>(null);
    final isPermissionPermanentlyDenied = useState(false);

    Future<void> scanForPrinters() async {
      if (!isThermalPrintingSupported) {
        error.value = kThermalPrintingUnsupportedMessage;
        isScanning.value = false;
        return;
      }

      isScanning.value = true;
      error.value = null;
      isPermissionPermanentlyDenied.value = false;

      try {
        final printService = ref.read(thermalPrintServiceProvider.notifier);
        final isEnabled = await printService.isBluetoothEnabled();

        if (!isEnabled) {
          error.value =
              'Bluetooth is not enabled. Please enable Bluetooth and try again.';
          isScanning.value = false;
          return;
        }

        final foundDevices = await printService.discoverBluetoothPrinters();
        devices.value = foundDevices;

        if (foundDevices.isEmpty) {
          error.value =
              'No Bluetooth devices found. Make sure your printer is paired and turned on.';
        }
      } on PermissionDeniedException catch (e) {
        error.value = e.message;
        isPermissionPermanentlyDenied.value = e.isPermanent;
      } catch (e) {
        error.value = 'Error scanning for devices: $e';
      } finally {
        isScanning.value = false;
      }
    }

    useEffect(() {
      scanForPrinters();
      return null;
    }, []);

    return DialogCloseHandler(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                  const Icon(Icons.bluetooth_searching),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Discover Printers',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (!isScanning.value)
                  IconButton(
                    onPressed: scanForPrinters,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Scan again',
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Select a paired Bluetooth device from the list below.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _buildContent(
              context,
              isScanning: isScanning.value,
              devices: devices.value,
              error: error.value,
              isPermissionPermanentlyDenied:
                  isPermissionPermanentlyDenied.value,
              onRetry: scanForPrinters,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isScanning,
    required List<BluetoothInfo> devices,
    required String? error,
    required bool isPermissionPermanentlyDenied,
    required VoidCallback onRetry,
  }) {
    final theme = Theme.of(context);

    if (isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning for Bluetooth devices...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPermissionPermanentlyDenied
                    ? Icons.block
                    : Icons.bluetooth_disabled,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              if (isPermissionPermanentlyDenied)
                FilledButton.icon(
                  onPressed: () async {
                    await PermissionService.openSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                )
              else
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
            ],
          ),
        ),
      );
    }

    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No devices found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure your printer is paired with this device.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.print,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(device.name),
          subtitle: Text(device.macAdress),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onPrinterSelected(device.name, device.macAdress),
        );
      },
    );
  }
}

/// Shows the printer discovery dialog.
void showPrinterDiscoveryDialog(
  BuildContext context, {
  required void Function(String name, String address) onPrinterSelected,
}) {
  showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: PrinterDiscoveryDialog(onPrinterSelected: onPrinterSelected),
    ),
  );
}
