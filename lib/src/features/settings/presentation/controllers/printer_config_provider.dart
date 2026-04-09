import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/printer_config_repository.dart';
import '../../domain/printer_config.dart';
import 'local_default_printer_provider.dart';

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

/// Provider to fetch the effective default printer configuration.
///
/// Priority: local default (device-specific) > server default.
/// If no local default is set, falls back to the server-configured default.
@riverpod
Future<PrinterConfig?> defaultPrinter(Ref ref) async {
  final localId = await ref.watch(localDefaultPrinterIdProvider.future);
  final repository = ref.watch(printerConfigRepositoryProvider);

  // Try local default first
  if (localId != null && localId.isNotEmpty) {
    final result = await repository.fetchOne(localId);
    final localPrinter = result.fold(
      (failure) => null,
      (config) => config,
    );
    // Only use local default if the printer exists and is enabled
    if (localPrinter != null && localPrinter.isEnabled) {
      return localPrinter;
    }
  }

  // Fall back to server default
  final result = await repository.fetchDefault();
  return result.fold(
    (failure) => null,
    (config) => config,
  );
}
