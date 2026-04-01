/// Data class representing a top-selling product or service.
class TopSellingItem {
  const TopSellingItem({
    required this.name,
    required this.itemId,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.transactionCount,
  });

  final String name;
  final String itemId;
  final int totalQuantitySold;
  final double totalRevenue;
  final int transactionCount;
}
