import 'subscription_status.dart';

/// Default days before [periodEnd] when an active subscription is treated as
/// due soon (used when billing settings are unavailable).
const kSubscriptionExpiringSoonDays = 7;

/// Whether an active subscription's paid window ends within
/// [warningDaysBeforeDue] days.
bool isSubscriptionDueSoon(
  SubscriptionStatus status,
  DateTime periodEnd, {
  int warningDaysBeforeDue = kSubscriptionExpiringSoonDays,
}) {
  if (status != SubscriptionStatus.active) return false;
  if (warningDaysBeforeDue < 0) return false;
  final windowEnd = DateTime.now().add(
    Duration(days: warningDaysBeforeDue),
  );
  return !periodEnd.isAfter(windowEnd);
}

/// Whole days remaining until [periodEnd], clamped for display (at least 1
/// when still in the due-soon window).
int subscriptionDaysRemaining(
  DateTime periodEnd, {
  int warningDaysBeforeDue = kSubscriptionExpiringSoonDays,
}) {
  final days = periodEnd.difference(DateTime.now()).inDays;
  final maxDays = warningDaysBeforeDue < 1 ? 1 : warningDaysBeforeDue;
  return days.clamp(1, maxDays);
}
