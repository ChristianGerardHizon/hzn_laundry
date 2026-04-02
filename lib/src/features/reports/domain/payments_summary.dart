import '../../pos/domain/payment_method.dart';
import '../../pos/domain/payment_type.dart';

/// Aggregated payment summary from the vw_payments_daily_summary view.
class PaymentsDailySummaryEntry {
  const PaymentsDailySummaryEntry({
    required this.date,
    required this.paymentMethod,
    required this.paymentType,
    required this.paymentCount,
    required this.totalAmount,
  });

  final DateTime date;
  final PaymentMethod paymentMethod;
  final PaymentType paymentType;
  final int paymentCount;
  final num totalAmount;
}
