import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/printer_config_repository.dart';
import '../../domain/printer_config.dart';
import 'selected_printer_id_provider.dart';

part 'printer_configs_controller.g.dart';

/// Controller for managing printer configuration list state.
///
/// Provides methods for fetching and CRUD operations on printer configs.
@Riverpod(keepAlive: true)
class PrinterConfigsController extends _$PrinterConfigsController {
  PrinterConfigRepository get _repository =>
      ref.read(printerConfigRepositoryProvider);

  @override
  Future<List<PrinterConfig>> build() async {
    final result = await _repository.fetchAll();
    return result.fold(
      (failure) => throw failure,
      (configs) => configs,
    );
  }

  /// Refreshes the printer config list.
  Future<void> refresh() async {
    state = const AsyncLoading();

    final result = await _repository.fetchAll();

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (configs) => AsyncData(configs),
    );
  }

  /// Creates a new printer configuration.
  Future<bool> createConfig(PrinterConfig config, {bool select = false}) async {
    final result = await _repository.create(config);
    final newConfig = result.fold<PrinterConfig?>(
      (failure) => null,
      (config) => config,
    );
    if (newConfig == null) return false;

    final currentList = state.value ?? [];
    final updatedList = [newConfig, ...currentList];
    state = AsyncData(updatedList);

    final shouldSelect = select || updatedList.length == 1;
    if (shouldSelect && newConfig.isEnabled) {
      await ref
          .read(selectedPrinterIdProvider.notifier)
          .setSelected(newConfig.id);
    }
    return true;
  }

  /// Updates an existing printer configuration.
  Future<bool> updateConfig(PrinterConfig config) async {
    final result = await _repository.update(config);
    final updatedConfig = result.fold<PrinterConfig?>(
      (failure) => null,
      (config) => config,
    );
    if (updatedConfig == null) return false;

    final currentList = state.value ?? [];
    final updatedList = currentList.map((c) {
      if (c.id == updatedConfig.id) return updatedConfig;
      return c;
    }).toList();
    state = AsyncData(updatedList);
    return true;
  }

  /// Deletes a printer configuration.
  Future<bool> deleteConfig(String id) async {
    final result = await _repository.delete(id);
    final failed = result.fold((failure) => true, (_) => false);
    if (failed) return false;

    final currentList = state.value ?? [];
    final updatedList = currentList.where((c) => c.id != id).toList();
    state = AsyncData(updatedList);

    final selectedId = ref.read(selectedPrinterIdProvider).value;
    if (selectedId == id) {
      PrinterConfig? next;
      for (final printer in updatedList) {
        if (printer.isEnabled) {
          next = printer;
          break;
        }
      }
      if (next != null) {
        await ref.read(selectedPrinterIdProvider.notifier).setSelected(next.id);
      } else {
        await ref.read(selectedPrinterIdProvider.notifier).clearSelected();
      }
    }
    return true;
  }
}
