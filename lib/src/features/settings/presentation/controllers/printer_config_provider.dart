import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/printer_config_repository.dart';
import '../../domain/printer_config.dart';
import 'printer_configs_controller.dart';
import 'selected_printer_id_provider.dart';

part 'printer_config_provider.g.dart';

/// Provider to fetch a single printer config by ID.
@riverpod
Future<PrinterConfig?> printerConfig(Ref ref, String id) async {
  if (id.isEmpty) return null;

  final repository = ref.watch(printerConfigRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold(
    (failure) => null,
    (config) => config,
  );
}

/// The printer selected on this device, if it exists and is enabled.
@riverpod
Future<PrinterConfig?> selectedPrinter(Ref ref) async {
  final selectedId = await ref.watch(selectedPrinterIdProvider.future);
  final printers = await ref.watch(printerConfigsControllerProvider.future);

  if (selectedId == null || selectedId.isEmpty) return null;

  PrinterConfig? match;
  for (final printer in printers) {
    if (printer.id == selectedId) {
      match = printer;
      break;
    }
  }

  if (match == null || !match.isEnabled) {
    Future.microtask(() {
      ref.read(selectedPrinterIdProvider.notifier).clearSelected();
    });
    return null;
  }

  return match;
}
