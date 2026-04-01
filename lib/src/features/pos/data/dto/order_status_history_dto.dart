import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/order_status_history.dart';

part 'order_status_history_dto.mapper.dart';

/// Data Transfer Object for OrderStatusHistory from PocketBase.
@MappableClass()
class OrderStatusHistoryDto with OrderStatusHistoryDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String sale;
  final String statusType;
  final String fromStatus;
  final String toStatus;
  final String? description;
  final String? created;
  final String? updated;

  const OrderStatusHistoryDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.sale,
    required this.statusType,
    required this.fromStatus,
    required this.toStatus,
    this.description,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory OrderStatusHistoryDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return OrderStatusHistoryDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      sale: json['sale'] as String? ?? '',
      statusType: json['statusType'] as String? ?? 'orderStatus',
      fromStatus: json['fromStatus'] as String? ?? '',
      toStatus: json['toStatus'] as String? ?? '',
      description: json['description'] as String?,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain OrderStatusHistory entity.
  OrderStatusHistory toEntity() {
    return OrderStatusHistory(
      id: id,
      saleId: sale,
      statusType: _parseStatusType(statusType),
      fromStatus: fromStatus,
      toStatus: toStatus,
      description: description,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  StatusType _parseStatusType(String value) {
    switch (value) {
      case 'saleStatus':
        return StatusType.saleStatus;
      case 'orderStatus':
      default:
        return StatusType.orderStatus;
    }
  }

  /// Creates a JSON body for creating a new history entry in PocketBase.
  static Map<String, dynamic> toCreateBody({
    required String saleId,
    required String statusType,
    required String fromStatus,
    required String toStatus,
    String? description,
  }) {
    return {
      'sale': saleId,
      'statusType': statusType,
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      if (description != null) 'description': description,
    };
  }
}
