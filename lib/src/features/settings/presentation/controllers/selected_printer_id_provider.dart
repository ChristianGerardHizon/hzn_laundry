import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../data/repositories/printer_config_repository.dart';

part 'selected_printer_id_provider.g.dart';

/// Provider to get/set the printer selected on this device.
@Riverpod(keepAlive: true)
class SelectedPrinterId extends _$SelectedPrinterId {
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  Future<String?> build() async {
    // Ensure one-time server import has run before reading the selected ID.
    await ref.watch(printerConfigRepositoryProvider).fetchAll();
    final selected = await _storage.read(key: selectedPrinterIdKey);
    if (selected != null && selected.isNotEmpty) return selected;
    return _storage.read(key: legacyLocalDefaultPrinterKey);
  }

  /// Sets the selected printer ID for this device.
  Future<void> setSelected(String printerId) async {
    await _storage.write(key: selectedPrinterIdKey, value: printerId);
    state = AsyncData(printerId);
  }

  /// Clears the selected printer.
  Future<void> clearSelected() async {
    await _storage.delete(key: selectedPrinterIdKey);
    await _storage.delete(key: legacyLocalDefaultPrinterKey);
    state = const AsyncData(null);
  }
}
