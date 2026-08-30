import 'package:dart_mappable/dart_mappable.dart';

import '../../machines/domain/machine.dart';
import '../../storages/domain/storage_location.dart';
import 'service.dart';
import 'service_item_status.dart';

part 'sale_service_item.mapper.dart';

/// Sale Service Item domain model.
///
/// Represents a service line item in a finalized sale.
@MappableClass()
class SaleServiceItem with SaleServiceItemMappable {
  const SaleServiceItem({
    required this.id,
    required this.saleId,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.service,
    this.machineIds = const [],
    this.machineId,
    this.machineName,
    this.machine,
    this.machineLoadCounts = const {},
    this.machineWeights = const {},
    this.storageIds = const [],
    this.storageName,
    this.storageLocations = const [],
    this.status,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent Sale ID.
  final String saleId;

  /// Service ID.
  final String serviceId;

  /// Snapshot of service name at time of sale.
  final String serviceName;

  /// Quantity.
  final num quantity;

  /// Price per unit at time of sale.
  final num unitPrice;

  /// Line total (quantity * unitPrice).
  final num subtotal;

  /// Expanded Service (optional).
  final Service? service;

  /// All assigned machine IDs (full list from PB relation).
  final List<String> machineIds;

  /// Assigned machine ID (first from list, for backward compat).
  final String? machineId;

  /// Snapshot of machine name at time of assignment.
  final String? machineName;

  /// Expanded Machine (optional).
  final Machine? machine;

  /// Load count per machine (machine ID → number of cycles).
  /// Machines not present default to 1.
  final Map<String, int> machineLoadCounts;

  /// Entered weight (kg) per machine (machine ID → weight) that produced the
  /// auto load count. Supplementary/auditable; [machineLoadCounts] remains the
  /// source of truth for the actual load count.
  final Map<String, double> machineWeights;

  /// Assigned storage IDs.
  final List<String> storageIds;

  /// Snapshot of storage names at time of assignment.
  final String? storageName;

  /// Expanded StorageLocations (optional).
  final List<StorageLocation> storageLocations;

  /// Service item completion status.
  final ServiceItemStatus? status;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// True when this line has at least one assigned machine.
  bool get hasMachineAssigned {
    if (machineIds.any((id) => id.isNotEmpty)) return true;
    return machineName != null && machineName!.isNotEmpty;
  }

  /// Storage label for UI: snapshot name, else expanded location names.
  String? get displayStorageName {
    final snapshot = storageName?.trim();
    if (snapshot != null && snapshot.isNotEmpty) return snapshot;
    final names = storageLocations
        .map((location) => location.name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (names.isEmpty) return null;
    return names.join(', ');
  }
}
