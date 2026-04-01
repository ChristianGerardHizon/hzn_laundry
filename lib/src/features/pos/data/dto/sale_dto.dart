import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/order_status.dart';
import '../../domain/sale.dart';

part 'sale_dto.mapper.dart';

@MappableClass()
class SaleDto with SaleDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String receiptNumber;
  final String branch;
  final String cashier;
  final num totalAmount;
  final String status;
  final String orderStatus;
  final bool isPaid;
  final String? pickedUpAt;
  final String? customer;
  final String? customerName;
  final String? notes;
  final String? created;
  final String? updated;

  const SaleDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.receiptNumber,
    required this.branch,
    required this.cashier,
    required this.totalAmount,
    required this.status,
    this.orderStatus = 'pending',
    this.isPaid = false,
    this.pickedUpAt,
    this.customer,
    this.customerName,
    this.notes,
    this.created,
    this.updated,
  });

  factory SaleDto.fromRecord(RecordModel record) {
    return SaleDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      receiptNumber: record.getStringValue('receiptNumber'),
      branch: record.getStringValue('branch'),
      cashier: record.getStringValue('cashier'),
      totalAmount: record.getDoubleValue('totalAmount'),
      status: record.getStringValue('status'),
      orderStatus: record.getStringValue('orderStatus'),
      isPaid: record.getBoolValue('isPaid'),
      pickedUpAt: record.get<String>('pickedUpAt'),
      customer: record.getStringValue('customer'),
      customerName: record.getStringValue('customerName'),
      notes: record.getStringValue('notes'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  Sale toEntity() {
    return Sale(
      id: id,
      receiptNumber: receiptNumber,
      branchId: branch,
      cashierId: cashier,
      totalAmount: totalAmount,
      status: status,
      orderStatus: _parseOrderStatus(orderStatus),
      isPaid: isPaid,
      pickedUpAt: parseToLocal(pickedUpAt),
      customerId: customer != null && customer!.isNotEmpty ? customer : null,
      customerName: customerName != null && customerName!.isNotEmpty ? customerName : null,
      notes: notes,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'ready':
        return OrderStatus.ready;
      case 'pickedup':
        return OrderStatus.pickedUp;
      default:
        return OrderStatus.pending;
    }
  }
}
