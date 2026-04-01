import 'package:dart_mappable/dart_mappable.dart';

import 'order_status.dart';

part 'sale.mapper.dart';

/// Sale domain model.
///
/// Represents a finalized transaction/receipt.
@MappableClass()
class Sale with SaleMappable {
  const Sale({
    required this.id,
    required this.receiptNumber,
    required this.branchId,
    required this.cashierId,
    required this.totalAmount,
    required this.status,
    this.orderStatus = OrderStatus.pending,
    this.isPaid = false,
    this.pickedUpAt,
    this.customerId,
    this.customerName,
    this.notes,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Human-readable receipt number.
  final String receiptNumber;

  /// Branch ID where sale occurred.
  final String branchId;

  /// Cashier User ID.
  final String cashierId;

  /// Total amount charged.
  final num totalAmount;

  /// Transaction status (completed, refunded, voided).
  final String status;

  /// Order fulfillment status (pending, processing, ready, pickedUp).
  final OrderStatus orderStatus;

  /// Whether the customer has fully paid (auto-calculated from payments).
  final bool isPaid;

  /// Timestamp when the order was picked up.
  final DateTime? pickedUpAt;

  /// Linked customer ID (optional).
  final String? customerId;

  /// Customer name (for display).
  final String? customerName;

  /// Internal notes.
  final String? notes;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Returns display name for customer.
  String? get customerDisplay => customerName;

  /// Returns true if order has been picked up.
  bool get isPickedUp => orderStatus == OrderStatus.pickedUp;
}
