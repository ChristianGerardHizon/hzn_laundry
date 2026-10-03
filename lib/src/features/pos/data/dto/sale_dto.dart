import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/fulfillment_type.dart';
import '../../domain/order_status.dart';
import '../../domain/payment_status.dart';
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
  final String paymentStatus;
  final int packs;
  final String? pickedUpAt;
  final String? customer;
  final String? customerName;
  final String? notes;
  final String? postedDate;
  final String? readyForPickupAt;
  final bool sendNotification;
  final String? readyNotificationSentAt;
  final String? pickedUpNotificationSentAt;
  final String? voidedBy;
  final String? voidedAt;
  final String? fulfillmentType;
  final String? deliveryAddress;
  final String? deliveryNotes;
  final num? distanceKm;
  final num? deliveryRatePerKm;
  final num deliveryFee;
  final bool deliveryFeeOverridden;
  final String? forDeliveryAt;
  final String? forDeliveryNotificationSentAt;
  final String? deliveryPhoto;
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
    this.paymentStatus = 'unpaid',
    this.packs = 0,
    this.pickedUpAt,
    this.customer,
    this.customerName,
    this.notes,
    this.postedDate,
    this.readyForPickupAt,
    this.sendNotification = true,
    this.readyNotificationSentAt,
    this.pickedUpNotificationSentAt,
    this.voidedBy,
    this.voidedAt,
    this.fulfillmentType,
    this.deliveryAddress,
    this.deliveryNotes,
    this.distanceKm,
    this.deliveryRatePerKm,
    this.deliveryFee = 0,
    this.deliveryFeeOverridden = false,
    this.forDeliveryAt,
    this.forDeliveryNotificationSentAt,
    this.deliveryPhoto,
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
      paymentStatus: record.getStringValue('paymentStatus'),
      packs: record.getIntValue('packs'),
      pickedUpAt: record.get<String>('pickedUpAt'),
      customer: record.getStringValue('customer'),
      customerName: record.getStringValue('customerName'),
      notes: record.getStringValue('notes'),
      postedDate: record.get<String>('postedDate'),
      readyForPickupAt: record.get<String>('readyForPickupAt'),
      // Missing field (pre-migration) treats as enabled — matches server default.
      sendNotification: record.data.containsKey('sendNotification')
          ? record.getBoolValue('sendNotification')
          : true,
      readyNotificationSentAt: record.get<String>('readyNotificationSentAt'),
      pickedUpNotificationSentAt:
          record.get<String>('pickedUpNotificationSentAt'),
      voidedBy: record.getStringValue('voidedBy'),
      voidedAt: record.get<String>('voidedAt'),
      fulfillmentType: record.getStringValue('fulfillmentType'),
      deliveryAddress: record.getStringValue('deliveryAddress'),
      deliveryNotes: record.getStringValue('deliveryNotes'),
      distanceKm: record.data['distanceKm'] is num
          ? record.data['distanceKm'] as num
          : null,
      deliveryRatePerKm: record.data['deliveryRatePerKm'] is num
          ? record.data['deliveryRatePerKm'] as num
          : null,
      deliveryFee: record.getDoubleValue('deliveryFee'),
      deliveryFeeOverridden: record.getBoolValue('deliveryFeeOverridden'),
      forDeliveryAt: record.get<String>('forDeliveryAt'),
      forDeliveryNotificationSentAt:
          record.get<String>('forDeliveryNotificationSentAt'),
      deliveryPhoto: record.getStringValue('deliveryPhoto'),
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
      paymentStatus: _parsePaymentStatus(paymentStatus),
      packs: packs,
      pickedUpAt: parseToLocal(pickedUpAt),
      customerId: customer != null && customer!.isNotEmpty ? customer : null,
      customerName: customerName != null && customerName!.isNotEmpty
          ? customerName
          : null,
      notes: notes,
      postedDate: parseToLocal(postedDate),
      readyForPickupAt: parseToLocal(readyForPickupAt),
      sendNotification: sendNotification,
      readyNotificationSentAt: parseToLocal(readyNotificationSentAt),
      pickedUpNotificationSentAt: parseToLocal(pickedUpNotificationSentAt),
      voidedById: voidedBy != null && voidedBy!.isNotEmpty ? voidedBy : null,
      voidedAt: parseToLocal(voidedAt),
      fulfillmentType: FulfillmentType.parse(fulfillmentType),
      deliveryAddress: deliveryAddress != null && deliveryAddress!.isNotEmpty
          ? deliveryAddress
          : null,
      deliveryNotes: deliveryNotes != null && deliveryNotes!.isNotEmpty
          ? deliveryNotes
          : null,
      distanceKm: distanceKm,
      deliveryRatePerKm: deliveryRatePerKm,
      deliveryFee: deliveryFee,
      deliveryFeeOverridden: deliveryFeeOverridden,
      forDeliveryAt: parseToLocal(forDeliveryAt),
      forDeliveryNotificationSentAt:
          parseToLocal(forDeliveryNotificationSentAt),
      deliveryPhoto: deliveryPhoto != null && deliveryPhoto!.isNotEmpty
          ? deliveryPhoto
          : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  PaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'partial':
        return PaymentStatus.partial;
      case 'paid':
        return PaymentStatus.paid;
      default:
        return PaymentStatus.unpaid;
    }
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'ready':
        return OrderStatus.ready;
      case 'fordelivery':
        return OrderStatus.forDelivery;
      case 'pickedup':
        return OrderStatus.pickedUp;
      default:
        return OrderStatus.pending;
    }
  }
}
