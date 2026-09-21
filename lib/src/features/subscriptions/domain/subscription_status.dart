import 'package:dart_mappable/dart_mappable.dart';

part 'subscription_status.mapper.dart';

/// Lifecycle status of an organization subscription.
@MappableEnum()
enum SubscriptionStatus {
  active,
  grace,
  locked,
  cancelled;

  /// Parse a string to [SubscriptionStatus], defaults to [active].
  static SubscriptionStatus fromString(String? value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SubscriptionStatus.active,
    );
  }

  String get displayName => switch (this) {
        SubscriptionStatus.active => 'Active',
        SubscriptionStatus.grace => 'Grace',
        SubscriptionStatus.locked => 'Locked',
        SubscriptionStatus.cancelled => 'Cancelled',
      };
}
