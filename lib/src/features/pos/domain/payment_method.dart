import 'package:dart_mappable/dart_mappable.dart';

part 'payment_method.mapper.dart';

/// Payment methods supported by the POS system.
@MappableEnum()
enum PaymentMethod {
  cash,
  gcash,
  card,
  bankTransfer,
  check;

  String get displayName => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.gcash => 'GCash',
        PaymentMethod.card => 'Card',
        PaymentMethod.bankTransfer => 'Bank Transfer',
        PaymentMethod.check => 'Check',
      };
}
