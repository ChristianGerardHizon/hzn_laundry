import '../../pos/domain/sale_item.dart';
import '../../services/domain/sale_service_item.dart';

/// Data class holding today's sales summary totals and breakdown.
class SalesSummaryData {
  const SalesSummaryData({
    required this.totalSales,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.items,
  });

  /// Sum of all sale amounts (today's sales + backlog sales paid today).
  final num totalSales;

  /// Sum of amounts for paid sales.
  final num totalPaid;

  /// Sum of amounts for unpaid sales.
  final num totalUnpaid;

  /// Individual sale breakdown entries.
  final List<SalesSummaryItem> items;
}

/// A single sale entry in the summary breakdown.
class SalesSummaryItem {
  const SalesSummaryItem({
    required this.saleId,
    required this.receiptNumber,
    required this.totalAmount,
    required this.isPaid,
    required this.isBacklog,
    this.customerName,
    this.postedDate,
    this.serviceItems = const [],
    this.saleItems = const [],
  });

  final String saleId;
  final String receiptNumber;
  final num totalAmount;
  final bool isPaid;

  /// True if the sale was created before today but paid today.
  final bool isBacklog;

  final String? customerName;
  final DateTime? postedDate;

  /// Service line items for this sale.
  final List<SaleServiceItem> serviceItems;

  /// Product/add-on line items for this sale.
  final List<SaleItem> saleItems;
}
