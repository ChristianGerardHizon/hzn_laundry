import 'package:dart_mappable/dart_mappable.dart';

part 'payment_type.mapper.dart';

/// Type of payment transaction.
@MappableEnum()
enum PaymentType {
  payment,
  deposit,
  refund;

  String get displayName => switch (this) {
        PaymentType.payment => 'Payment',
        PaymentType.deposit => 'GCash/Bank',
        PaymentType.refund => 'Refund',
      };
}
