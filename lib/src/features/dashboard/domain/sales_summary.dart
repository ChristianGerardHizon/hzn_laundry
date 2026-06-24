import '../../pos/domain/sale_item.dart';
import '../../services/domain/sale_service_item.dart';

/// Data class holding today's sales summary totals and breakdown.
class SalesSummaryData {
  const SalesSummaryData({
    required this.totalSales,
    required this.totalPaymentsReceived,
    required this.totalOutstanding,
    required this.salesItems,
    required this.paymentItems,
    required this.outstandingItems,
  });

  /// Sum of all order amounts created on the selected day.
  final num totalSales;

  /// Sum of all payment amounts posted on the selected day.
  final num totalPaymentsReceived;

  /// Remaining unpaid balance for orders created on the selected day.
  final num totalOutstanding;

  /// Breakdown of orders created on the selected day.
  final List<SalesSummaryItem> salesItems;

  /// Breakdown of payment receipts posted on the selected day, grouped by sale.
  final List<SalesSummaryItem> paymentItems;

  /// Breakdown of outstanding balances for orders created on the selected day.
  final List<SalesSummaryItem> outstandingItems;
}

/// A single sale entry in the summary breakdown.
class SalesSummaryItem {
  const SalesSummaryItem({
    required this.saleId,
    required this.receiptNumber,
    required this.totalAmount,
    required this.isPaid,
    required this.isBacklog,
    required this.statusLabel,
    this.customerName,
    this.postedDate,
    this.packs = 0,
    this.serviceItems = const [],
    this.saleItems = const [],
  });

  final String saleId;
  final String receiptNumber;
  final num totalAmount;
  final bool isPaid;

  /// True if the sale was created before today but paid today.
  final bool isBacklog;

  /// Badge label shown in breakdown lists.
  final String statusLabel;

  final String? customerName;
  final DateTime? postedDate;

  /// Number of laundry bags/packs for this order.
  final int packs;

  /// Service line items for this sale.
  final List<SaleServiceItem> serviceItems;

  /// Product/add-on line items for this sale.
  final List<SaleItem> saleItems;
}
