import 'package:dart_mappable/dart_mappable.dart';

part 'payment_status.mapper.dart';

/// Payment status of a sale.
@MappableEnum()
enum PaymentStatus {
  unpaid,
  partial,
  paid;

  String get displayName => switch (this) {
        PaymentStatus.unpaid => 'Unpaid',
        PaymentStatus.partial => 'Partial',
        PaymentStatus.paid => 'Paid',
      };
}
