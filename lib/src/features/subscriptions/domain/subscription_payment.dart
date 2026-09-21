import 'package:dart_mappable/dart_mappable.dart';

import 'subscription_payment_status.dart';

part 'subscription_payment.mapper.dart';

/// QRPH proof submission for an organization subscription period.
@MappableClass()
class SubscriptionPayment with SubscriptionPaymentMappable {
  const SubscriptionPayment({
    required this.id,
    required this.organizationId,
    required this.subscriptionId,
    required this.amount,
    required this.status,
    this.proofImageUrl,
    this.note,
    this.adminNote,
    required this.submittedById,
    this.reviewedById,
    this.reviewedAt,
    this.created,
    this.organizationName,
  });

  final String id;
  final String organizationId;
  final String subscriptionId;
  final num amount;
  final SubscriptionPaymentStatus status;
  final String? proofImageUrl;
  final String? note;
  final String? adminNote;
  final String submittedById;
  final String? reviewedById;
  final DateTime? reviewedAt;
  final DateTime? created;
  final String? organizationName;
}
