import 'package:dart_mappable/dart_mappable.dart';

import '../../pos/domain/order_status.dart';
import '../../pos/domain/payment_status.dart';

part 'customer_history.mapper.dart';

/// Public-facing customer summary returned by the history endpoint.
@MappableClass()
class CustomerHistoryCustomer with CustomerHistoryCustomerMappable {
  const CustomerHistoryCustomer({
    required this.id,
    required this.name,
    this.phone,
  });

  final String id;
  final String name;
  final String? phone;
}

/// Public-facing sale entry shown in the customer history list.
@MappableClass()
class CustomerHistorySale with CustomerHistorySaleMappable {
  const CustomerHistorySale({
    required this.id,
    required this.receiptNumber,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.isPaid,
    this.packs = 0,
    this.notes,
    this.pickedUpAt,
    this.postedDate,
    this.created,
  });

  final String id;
  final String receiptNumber;
  final num totalAmount;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final bool isPaid;
  final int packs;
  final String? notes;
  final DateTime? pickedUpAt;
  final DateTime? postedDate;
  final DateTime? created;

  bool get isPending => orderStatus != OrderStatus.pickedUp;
  bool get isUnpaid => paymentStatus != PaymentStatus.paid;
}

/// Line item on a sale (product).
@MappableClass()
class CustomerHistoryItem with CustomerHistoryItemMappable {
  const CustomerHistoryItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final String id;
  final String productName;
  final num quantity;
  final num unitPrice;
  final num subtotal;
}

/// Service line item on a sale.
@MappableClass()
class CustomerHistoryServiceItem with CustomerHistoryServiceItemMappable {
  const CustomerHistoryServiceItem({
    required this.id,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.status,
    this.machineName,
    this.storageName,
  });

  final String id;
  final String serviceName;
  final num quantity;
  final num unitPrice;
  final num subtotal;
  final String? status;
  final String? machineName;
  final String? storageName;
}

/// Full detail of a single sale for the public history view.
@MappableClass()
class CustomerHistorySaleDetail with CustomerHistorySaleDetailMappable {
  const CustomerHistorySaleDetail({
    required this.customer,
    required this.sale,
    required this.items,
    required this.services,
  });

  final CustomerHistoryCustomer customer;
  final CustomerHistorySale sale;
  final List<CustomerHistoryItem> items;
  final List<CustomerHistoryServiceItem> services;
}

/// Aggregate of customer + their sales.
@MappableClass()
class CustomerHistory with CustomerHistoryMappable {
  const CustomerHistory({
    required this.customer,
    required this.sales,
  });

  final CustomerHistoryCustomer customer;
  final List<CustomerHistorySale> sales;

  int get pendingCount => sales.where((s) => s.isPending).length;
  int get unpaidCount => sales.where((s) => s.isUnpaid).length;
}
