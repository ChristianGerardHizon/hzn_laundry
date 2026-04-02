import '../../pos/domain/payment.dart';

/// A payment with associated sale context for report display.
class PaymentReportEntry {
  const PaymentReportEntry({
    required this.payment,
    required this.saleId,
    this.receiptNumber = '',
    this.customerName,
    this.saleStatus = '',
  });

  final Payment payment;
  final String saleId;
  final String receiptNumber;
  final String? customerName;
  final String saleStatus;

  bool get isVoided => saleStatus == 'voided';
}
