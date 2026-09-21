import 'package:dart_mappable/dart_mappable.dart';

part 'billing_interval_unit.mapper.dart';

/// Billing interval unit for subscription packages.
@MappableEnum()
enum BillingIntervalUnit {
  day,
  month,
  year;

  /// Parse a string to [BillingIntervalUnit], defaults to [month].
  static BillingIntervalUnit fromString(String? value) {
    return BillingIntervalUnit.values.firstWhere(
      (unit) => unit.name == value,
      orElse: () => BillingIntervalUnit.month,
    );
  }

  String get displayName => switch (this) {
        BillingIntervalUnit.day => 'Day',
        BillingIntervalUnit.month => 'Month',
        BillingIntervalUnit.year => 'Year',
      };
}
