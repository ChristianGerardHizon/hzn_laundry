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
  final String? machine;
  final String? machineName;
  final String? storage;
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
    this.machine,
    this.machineName,
    this.storage,
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
      machine: record.getStringValue('machine'),
      machineName: record.getStringValue('machineName'),
      storage: record.getStringValue('storage'),
      storageName: record.getStringValue('storageName'),
      status: record.getStringValue('status'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  SaleServiceItem toEntity({
    RecordModel? serviceExpanded,
    RecordModel? machineExpanded,
    RecordModel? storageExpanded,
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
      machineId: machine != null && machine!.isNotEmpty ? machine : null,
      machineName: machineName,
      machine: machineExpanded != null
          ? MachineDto.fromRecord(machineExpanded).toEntity()
          : null,
      storageId: storage != null && storage!.isNotEmpty ? storage : null,
      storageName: storageName,
      storageLocation: storageExpanded != null
          ? StorageLocationDto.fromRecord(storageExpanded).toEntity()
          : null,
      status: ServiceItemStatus.fromDbValue(status),
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
