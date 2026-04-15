import 'package:dart_mappable/dart_mappable.dart';

import 'payment_method.dart';
import 'payment_type.dart';

part 'payment.mapper.dart';

/// Payment domain model.
///
/// Represents a payment transaction against a sale.
@MappableClass()
class Payment with PaymentMappable {
  const Payment({
    required this.id,
    required this.saleId,
    required this.amount,
    required this.paymentMethod,
    required this.type,
    this.isVoided = false,
    this.paymentRef,
    this.paymentProofUrl,
    this.notes,
    this.postedDate,
    this.voidedAt,
    this.voidReason,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// FK to sale record.
  final String saleId;

  /// Payment amount.
  final num amount;

  /// Payment method (cash, card, etc.).
  final PaymentMethod paymentMethod;

  /// Type of payment (payment, deposit, refund).
  final PaymentType type;

  /// Whether this payment has been voided by an admin.
  final bool isVoided;

  /// External payment reference.
  final String? paymentRef;

  /// URL of the payment proof image.
  final String? paymentProofUrl;

  /// Optional notes.
  final String? notes;

  /// Business/transaction date (editable).
  final DateTime? postedDate;

  /// Timestamp when the payment was voided.
  final DateTime? voidedAt;

  /// Optional admin note for the void action.
  final String? voidReason;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
