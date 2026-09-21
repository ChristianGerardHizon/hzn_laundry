import 'package:dart_mappable/dart_mappable.dart';

part 'subscription_payment_status.mapper.dart';

/// Review status of a subscription payment proof submission.
@MappableEnum()
enum SubscriptionPaymentStatus {
  pending,
  approved,
  rejected;

  /// Parse a string to [SubscriptionPaymentStatus], defaults to [pending].
  static SubscriptionPaymentStatus fromString(String? value) {
    return SubscriptionPaymentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SubscriptionPaymentStatus.pending,
    );
  }

  String get displayName => switch (this) {
        SubscriptionPaymentStatus.pending => 'Pending',
        SubscriptionPaymentStatus.approved => 'Approved',
        SubscriptionPaymentStatus.rejected => 'Rejected',
      };
}
