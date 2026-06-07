/// Data class holding today's machine-load summary, broken down per order.
///
/// A "load" is a machine cycle assigned to a sale's service items
/// (`saleServiceItems.machineLoadCounts`). The total is the sum of all load
/// counts across every assigned machine for the day's orders.
class LoadsSummaryData {
  const LoadsSummaryData({
    required this.totalLoads,
    required this.orders,
  });

  /// Total number of machine loads across all orders on the selected day.
  final int totalLoads;

  /// Per-order breakdown, sorted by load count descending.
  final List<LoadsOrderEntry> orders;
}

/// A single order entry in the loads breakdown, aggregating the load counts
/// across all of the order's assigned machines.
class LoadsOrderEntry {
  const LoadsOrderEntry({
    required this.saleId,
    required this.receiptNumber,
    required this.loads,
    this.customerName,
  });

  final String saleId;
  final String receiptNumber;

  /// Total machine loads for this order.
  final int loads;

  final String? customerName;
}
