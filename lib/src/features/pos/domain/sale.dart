import 'package:dart_mappable/dart_mappable.dart';

import 'fulfillment_type.dart';
import 'order_status.dart';
import 'payment_status.dart';

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
    this.paymentStatus = PaymentStatus.unpaid,
    this.packs = 0,
    this.pickedUpAt,
    this.customerId,
    this.customerName,
    this.notes,
    this.postedDate,
    this.readyForPickupAt,
    this.sendNotification = true,
    this.readyNotificationSentAt,
    this.pickedUpNotificationSentAt,
    this.voidedById,
    this.voidedAt,
    this.fulfillmentType = FulfillmentType.pickup,
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

  /// Payment status: unpaid, partial, or paid (auto-calculated from payments).
  final PaymentStatus paymentStatus;

  /// Number of laundry bags/packs used for this order.
  final int packs;

  /// Timestamp when the order was picked up.
  final DateTime? pickedUpAt;

  /// Linked customer ID (optional).
  final String? customerId;

  /// Customer name (for display).
  final String? customerName;

  /// Internal notes.
  final String? notes;

  /// Business/transaction date (editable).
  final DateTime? postedDate;

  /// Optional promised ready-for-pickup date/time.
  final DateTime? readyForPickupAt;

  /// When true, notify the customer (email now; SMS later) on Ready / Picked Up.
  final bool sendNotification;

  /// When the ready-for-pickup notification was last sent successfully.
  final DateTime? readyNotificationSentAt;

  /// When the picked-up notification was last sent successfully.
  final DateTime? pickedUpNotificationSentAt;

  /// User who voided this sale.
  final String? voidedById;

  /// Timestamp when the sale was voided.
  final DateTime? voidedAt;

  /// Pickup (default) or delivery. Delivery requires the `delivery` feature.
  final FulfillmentType fulfillmentType;

  /// Delivery address (delivery orders).
  final String? deliveryAddress;

  /// Delivery notes (landmarks, preferred time window, etc.).
  final String? deliveryNotes;

  /// Distance to the customer in kilometres, typed in by staff.
  final num? distanceKm;

  /// Per-km rate used for this order (prefilled from the branch default).
  final num? deliveryRatePerKm;

  /// Final delivery fee included in [totalAmount].
  final num deliveryFee;

  /// True when staff typed the fee instead of using the calculated amount.
  final bool deliveryFeeOverridden;

  /// When the order left for delivery.
  final DateTime? forDeliveryAt;

  /// When the out-for-delivery notification was last sent successfully.
  final DateTime? forDeliveryNotificationSentAt;

  /// Optional proof-of-delivery photo file name (PocketBase file field).
  final String? deliveryPhoto;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Returns display name for customer.
  String? get customerDisplay => customerName;

  /// Returns true if this is a delivery order.
  bool get isDelivery => fulfillmentType.isDelivery;

  /// Returns true if order has been picked up (delivered, for delivery orders).
  bool get isPickedUp => orderStatus == OrderStatus.pickedUp;

  /// Returns true if a ready notification has already been sent.
  bool get hasReadyNotificationBeenSent => readyNotificationSentAt != null;

  /// Returns true if a picked-up notification has already been sent.
  bool get hasPickedUpNotificationBeenSent =>
      pickedUpNotificationSentAt != null;
}
