/// Data class holding today's add-ons (product line items) summary.
///
/// "Add-ons" are the product line items attached to sales (e.g. detergent,
/// fabric softener) as opposed to laundry service items.
class AddOnsSummaryData {
  const AddOnsSummaryData({
    required this.totalQuantity,
    required this.totalRevenue,
    required this.items,
  });

  /// Total number of add-on units sold on the selected day.
  final num totalQuantity;

  /// Total revenue from add-ons sold on the selected day.
  final num totalRevenue;

  /// Per-product breakdown, sorted by quantity descending.
  final List<AddOnBreakdownItem> items;
}

/// A single add-on product entry in the breakdown, aggregated across all
/// sales for the selected day.
class AddOnBreakdownItem {
  const AddOnBreakdownItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.revenue,
    required this.orderCount,
  });

  final String productId;

  /// Snapshot of the product name at time of sale.
  final String productName;

  /// Total quantity sold across all orders on the selected day.
  final num quantity;

  /// Total revenue (sum of subtotals) for this product on the selected day.
  final num revenue;

  /// Number of distinct orders that included this add-on.
  final int orderCount;
}
