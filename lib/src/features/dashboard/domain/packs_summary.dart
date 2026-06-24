/// A single order's packs contribution shown on the dashboard modal.
class PacksOrderEntry {
  const PacksOrderEntry({
    required this.saleId,
    required this.receiptNumber,
    required this.customerName,
    required this.packs,
    required this.orderStatus,
  });

  final String saleId;
  final String receiptNumber;
  final String? customerName;
  final int packs;
  final String orderStatus;
}

/// Summary of today's total packs shown on the dashboard KPI.
class TotalPacksSummary {
  const TotalPacksSummary({
    required this.totalPacks,
    required this.orders,
  });

  final int totalPacks;
  final List<PacksOrderEntry> orders;

  static const empty = TotalPacksSummary(totalPacks: 0, orders: []);
}
