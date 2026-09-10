import '../../pos/domain/sale_consumable_usage.dart';

/// Aggregated house-consumable usage for a set of orders.
class ConsumablesUsageSummaryData {
  const ConsumablesUsageSummaryData({
    required this.totalQuantity,
    required this.totalCost,
    required this.orderCount,
    required this.items,
  });

  factory ConsumablesUsageSummaryData.fromUsages({
    required List<SaleConsumableUsage> usages,
    required int orderCount,
  }) {
    if (usages.isEmpty) {
      return ConsumablesUsageSummaryData(
        totalQuantity: 0,
        totalCost: 0,
        orderCount: orderCount,
        items: const [],
      );
    }

    final byProduct = <String, _UsageAggregate>{};
    num totalQuantity = 0;
    num totalCost = 0;

    for (final usage in usages) {
      if (usage.productId.isEmpty) continue;
      totalQuantity += usage.quantity;
      totalCost += usage.cost;

      final aggregate = byProduct.putIfAbsent(
        usage.productId,
        () => _UsageAggregate(productName: usage.productName),
      );
      aggregate.quantity += usage.quantity;
      aggregate.cost += usage.cost;
      aggregate.saleIds.add(usage.saleId);
      if (usage.productName.isNotEmpty) {
        aggregate.productName = usage.productName;
      }
    }

    final items = byProduct.entries
        .map(
          (entry) => ConsumableUsageBreakdownItem(
            productId: entry.key,
            productName: entry.value.productName,
            quantity: entry.value.quantity,
            cost: entry.value.cost,
            orderCount: entry.value.saleIds.length,
          ),
        )
        .toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return ConsumablesUsageSummaryData(
      totalQuantity: totalQuantity,
      totalCost: totalCost,
      orderCount: orderCount,
      items: items,
    );
  }

  final num totalQuantity;
  final num totalCost;
  final int orderCount;
  final List<ConsumableUsageBreakdownItem> items;

  num get averagePerOrder => orderCount <= 0 ? 0 : totalQuantity / orderCount;
}

class ConsumableUsageBreakdownItem {
  const ConsumableUsageBreakdownItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.cost,
    required this.orderCount,
  });

  final String productId;
  final String productName;
  final num quantity;
  final num cost;
  final int orderCount;
}

class _UsageAggregate {
  _UsageAggregate({required this.productName});

  String productName;
  num quantity = 0;
  num cost = 0;
  final Set<String> saleIds = {};
}
