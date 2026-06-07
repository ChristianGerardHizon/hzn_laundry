import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../machines/data/dto/machine_dto.dart';
import '../../../storages/data/dto/storage_location_dto.dart';
import '../../domain/sale_service_item.dart';
import '../../domain/service_item_status.dart';
import 'service_dto.dart';

part 'sale_service_item_dto.mapper.dart';

@MappableClass()
class SaleServiceItemDto with SaleServiceItemDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String sale;
  final String service;
  final String serviceName;
  final num quantity;
  final num unitPrice;
  final num subtotal;
  final List<String> machine;
  final String? machineName;
  final Map<String, dynamic> machineLoadCounts;
  final Map<String, dynamic> machineWeights;
  final List<String> storage;
  final String? storageName;
  final String? status;
  final String? created;
  final String? updated;

  const SaleServiceItemDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.sale,
    required this.service,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.machine = const [],
    this.machineName,
    this.machineLoadCounts = const {},
    this.machineWeights = const {},
    this.storage = const [],
    this.storageName,
    this.status,
    this.created,
    this.updated,
  });

  factory SaleServiceItemDto.fromRecord(RecordModel record) {
    return SaleServiceItemDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      sale: record.getStringValue('sale'),
      service: record.getStringValue('service'),
      serviceName: record.getStringValue('serviceName'),
      quantity: record.getDoubleValue('quantity'),
      unitPrice: record.getDoubleValue('unitPrice'),
      subtotal: record.getDoubleValue('subtotal'),
      machine: record.getListValue<String>('machine'),
      machineName: record.getStringValue('machineName'),
      machineLoadCounts: Map<String, dynamic>.from(
        (record.data['machineLoadCounts'] as Map?) ?? {},
      ),
      machineWeights: Map<String, dynamic>.from(
        (record.data['machineWeights'] as Map?) ?? {},
      ),
      storage: record.getListValue<String>('storage'),
      storageName: record.getStringValue('storageName'),
      status: record.getStringValue('status'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  SaleServiceItem toEntity({
    RecordModel? serviceExpanded,
    RecordModel? machineExpanded,
    List<RecordModel>? storageExpanded,
  }) {
    return SaleServiceItem(
      id: id,
      saleId: sale,
      serviceId: service,
      serviceName: serviceName,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      service: serviceExpanded != null
          ? ServiceDto.fromRecord(serviceExpanded).toEntity()
          : null,
      machineIds: machine,
      machineId: machine.isNotEmpty ? machine.first : null,
      machineName: machineName,
      machineLoadCounts: machineLoadCounts.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      machineWeights: machineWeights.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      machine: machineExpanded != null
          ? MachineDto.fromRecord(machineExpanded).toEntity()
          : null,
      storageIds: storage,
      storageName: storageName,
      storageLocations: storageExpanded != null
          ? storageExpanded
              .map((r) => StorageLocationDto.fromRecord(r).toEntity())
              .toList()
          : const [],
      status: ServiceItemStatus.fromDbValue(status),
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
