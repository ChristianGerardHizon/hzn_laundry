import 'sales_summary.dart';

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

  /// Aggregates product line items from today's sales, grouped per product.
  factory AddOnsSummaryData.fromSalesItems(List<SalesSummaryItem> sales) {
    if (sales.isEmpty) {
      return const AddOnsSummaryData(
        totalQuantity: 0,
        totalRevenue: 0,
        items: [],
      );
    }

    final byProduct = <String, _AddOnAggregate>{};
    num totalQuantity = 0;
    num totalRevenue = 0;

    for (final sale in sales) {
      for (final item in sale.saleItems) {
        if (item.productId.isEmpty) continue;
        totalQuantity += item.quantity;
        totalRevenue += item.subtotal;

        final aggregate = byProduct.putIfAbsent(
          item.productId,
          () => _AddOnAggregate(productName: item.productName),
        );
        aggregate.quantity += item.quantity;
        aggregate.revenue += item.subtotal;
        aggregate.saleIds.add(sale.saleId);
        if (item.productName.isNotEmpty) {
          aggregate.productName = item.productName;
        }
      }
    }

    final items = byProduct.entries
        .map(
          (entry) => AddOnBreakdownItem(
            productId: entry.key,
            productName: entry.value.productName,
            quantity: entry.value.quantity,
            revenue: entry.value.revenue,
            orderCount: entry.value.saleIds.length,
          ),
        )
        .toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return AddOnsSummaryData(
      totalQuantity: totalQuantity,
      totalRevenue: totalRevenue,
      items: items,
    );
  }

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

/// Mutable accumulator used while aggregating add-on line items per product.
class _AddOnAggregate {
  _AddOnAggregate({required this.productName});

  String productName;
  num quantity = 0;
  num revenue = 0;
  final Set<String> saleIds = {};
}
