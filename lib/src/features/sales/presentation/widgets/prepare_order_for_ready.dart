import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../pos/domain/sale.dart';
import '../../../services/domain/sale_service_item.dart';
import '../../../settings/data/repositories/feature_flag_repository.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_service_items_provider.dart';
import 'assign_machines_dialog.dart';
import 'assign_storages_dialog.dart';

/// Returns true when the service line has at least one machine assigned.
bool serviceItemHasMachine(SaleServiceItem item) => item.hasMachineAssigned;

bool _serviceItemHasStorage(SaleServiceItem item) =>
    item.storageName != null && item.storageName!.isNotEmpty;

bool _machinesOk(List<SaleServiceItem> items) =>
    items.isEmpty || items.every(serviceItemHasMachine);

bool _packsOk(Sale sale) => sale.packs > 0;

bool _storageOk(List<SaleServiceItem> items, bool storageRequired) =>
    !storageRequired || items.isEmpty || items.every(_serviceItemHasStorage);

Map<String, List<String>> _machineAssignmentsFrom(
  List<SaleServiceItem> items,
) {
  final map = <String, List<String>>{};
  for (final item in items) {
    if (item.machineIds.isNotEmpty) {
      map[item.id] = List<String>.from(item.machineIds);
    }
  }
  return map;
}

Map<String, Map<String, int>> _loadCountsFrom(List<SaleServiceItem> items) {
  final map = <String, Map<String, int>>{};
  for (final item in items) {
    if (item.machineLoadCounts.isNotEmpty) {
      map[item.id] = Map<String, int>.from(item.machineLoadCounts);
    }
  }
  return map;
}

Map<String, List<String>> _storageAssignmentsFrom(
  List<SaleServiceItem> items,
) {
  final map = <String, List<String>>{};
  for (final item in items) {
    if (item.storageIds.isNotEmpty) {
      map[item.id] = List<String>.from(item.storageIds);
    }
  }
  return map;
}

Future<List<SaleServiceItem>> _freshServiceItems(
  WidgetRef ref,
  String saleId,
) async {
  ref.invalidate(saleServiceItemsProvider(saleId));
  return ref.read(saleServiceItemsProvider(saleId).future).catchError(
        (_) => <SaleServiceItem>[],
      );
}

Future<Sale> _freshSale(WidgetRef ref, String saleId, Sale fallback) async {
  ref.invalidate(saleProvider(saleId));
  try {
    final loaded = await ref.read(saleProvider(saleId).future);
    return loaded ?? fallback;
  } catch (_) {
    return fallback;
  }
}

/// Shows required machine then packs/storage dialogs for Ready-for-pickup.
///
/// Skips dialogs when washer, packs, and (when required) storage are already
/// set. Returns `true` when the order has machines on every service line and
/// `packs > 0`. Returns `false` if the user cancels or validation fails.
Future<bool> prepareOrderForReadyStatus({
  required BuildContext context,
  required WidgetRef ref,
  required String saleId,
  Sale? sale,
}) async {
  final loaded = sale ?? await ref.read(saleProvider(saleId).future);
  if (loaded == null) return false;
  var currentSale = loaded;

  var serviceItems = ref.read(saleServiceItemsProvider(saleId)).value ??
      await ref.read(saleServiceItemsProvider(saleId).future).catchError(
            (_) => <SaleServiceItem>[],
          );

  final storageRequired =
      await ref.read(requireStorageEnabledProvider.future).catchError(
            (_) => false,
          );

  var machinesOk = _machinesOk(serviceItems);
  var packsOk = _packsOk(currentSale);
  var storageOk = _storageOk(serviceItems, storageRequired);

  // Everything already set — no prompts needed.
  if (machinesOk && packsOk && storageOk) return true;

  if (!machinesOk) {
    if (!context.mounted) return false;
    final machinesResult = await showAssignMachinesDialog(
      context,
      serviceItems: serviceItems,
      initialAssignments: _machineAssignmentsFrom(serviceItems),
      initialLoadCounts: _loadCountsFrom(serviceItems),
      requireAssignment: true,
    );
    if (machinesResult == null || !context.mounted) return false;

    serviceItems = await _freshServiceItems(ref, saleId);
    currentSale = await _freshSale(ref, saleId, currentSale);
    machinesOk = _machinesOk(serviceItems);
    packsOk = _packsOk(currentSale);
    storageOk = _storageOk(serviceItems, storageRequired);
  }

  if (!packsOk || !storageOk) {
    if (!context.mounted) return false;
    final storageResult = await showAssignStoragesDialog(
      context,
      saleId: saleId,
      serviceItems: serviceItems,
      initialAssignments: _storageAssignmentsFrom(serviceItems),
      initialPacks: currentSale.packs > 0 ? currentSale.packs : null,
      requirePacks: true,
    );
    if (storageResult == null || !context.mounted) return false;

    serviceItems = await _freshServiceItems(ref, saleId);
    currentSale = await _freshSale(ref, saleId, currentSale);
  }

  if (serviceItems.isNotEmpty &&
      serviceItems.any((item) => !serviceItemHasMachine(item))) {
    if (context.mounted) {
      showErrorSnackBar(
        context,
        message:
            'All services must have a machine assigned before marking as Ready.',
      );
    }
    return false;
  }

  if (currentSale.packs <= 0) {
    if (context.mounted) {
      showErrorSnackBar(
        context,
        message: 'Pack count must be set before marking as Ready.',
      );
    }
    return false;
  }

  if (storageRequired && serviceItems.isNotEmpty) {
    final missing = serviceItems.any((item) => !_serviceItemHasStorage(item));
    if (missing) {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          message:
              'All services must have a storage location assigned before marking as Ready.',
        );
      }
      return false;
    }
  }

  return true;
}
