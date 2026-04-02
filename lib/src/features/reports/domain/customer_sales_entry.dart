/// Aggregated sales stats for a customer within a date range.
class CustomerSalesEntry {
  const CustomerSalesEntry({
    required this.customerId,
    required this.customerName,
    required this.orderCount,
    required this.totalSpent,
    required this.totalPaid,
    required this.paidOrderCount,
  });

  final String? customerId;
  final String customerName;
  final int orderCount;
  final num totalSpent;
  final num totalPaid;
  final int paidOrderCount;

  num get unpaidAmount => totalSpent - totalPaid;
  bool get isFullyPaid => totalPaid >= totalSpent;
  int get unpaidOrderCount => orderCount - paidOrderCount;
}
