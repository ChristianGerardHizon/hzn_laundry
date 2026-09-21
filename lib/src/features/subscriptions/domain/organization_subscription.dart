import 'package:dart_mappable/dart_mappable.dart';

import 'billing_interval_unit.dart';
import 'subscription_status.dart';

part 'organization_subscription.mapper.dart';

/// Active (or historical) subscription assignment for an organization.
@MappableClass()
class OrganizationSubscription with OrganizationSubscriptionMappable {
  const OrganizationSubscription({
    required this.id,
    required this.organizationId,
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.intervalCount,
    required this.intervalUnit,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    this.graceEndsAt,
    this.nextReminderAt,
    this.manualUnlockUntil,
    this.lastReminderSentAt,
    this.isDeleted = false,
  });

  final String id;
  final String organizationId;
  final String packageId;
  final String packageName;
  final num price;
  final int intervalCount;
  final BillingIntervalUnit intervalUnit;
  final SubscriptionStatus status;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime? graceEndsAt;
  final DateTime? nextReminderAt;
  final DateTime? manualUnlockUntil;
  final DateTime? lastReminderSentAt;
  final bool isDeleted;

  /// Locked and not covered by an active manual unlock window.
  bool get isEffectivelyLocked {
    if (status != SubscriptionStatus.locked) return false;
    final until = manualUnlockUntil;
    return until == null || !until.isAfter(DateTime.now());
  }

  bool get isInGrace => status == SubscriptionStatus.grace;

  /// Grace or locked (including temporary manual unlock) needs admin attention.
  bool get needsAttention =>
      isInGrace || status == SubscriptionStatus.locked;
}
