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
    this.machineId,
    this.machineName,
    this.machine,
    this.storageId,
    this.storageName,
    this.storageLocation,
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

  /// Assigned machine ID.
  final String? machineId;

  /// Snapshot of machine name at time of assignment.
  final String? machineName;

  /// Expanded Machine (optional).
  final Machine? machine;

  /// Assigned storage ID.
  final String? storageId;

  /// Snapshot of storage name at time of assignment.
  final String? storageName;

  /// Expanded StorageLocation (optional).
  final StorageLocation? storageLocation;

  /// Service item completion status.
  final ServiceItemStatus? status;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
