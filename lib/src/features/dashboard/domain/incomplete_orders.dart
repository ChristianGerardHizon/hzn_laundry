import '../../pos/domain/order_status.dart';
import '../../pos/domain/sale.dart';
import '../../services/domain/sale_service_item.dart';

/// Why an order is listed on the Needs attention KPI.
enum OrderDataIssue {
  stillProcessing,
  missingMachines,
  missingPacks,
}

/// One order that still needs processing or is missing machines/packs.
class IncompleteOrderEntry {
  const IncompleteOrderEntry({
    required this.sale,
    required this.issues,
  });

  final Sale sale;
  final List<OrderDataIssue> issues;

  String get saleId => sale.id;
  String get receiptNumber => sale.receiptNumber;
  String? get customerName => sale.customerDisplay;
  OrderStatus get orderStatus => sale.orderStatus;
}

class IncompleteOrdersData {
  const IncompleteOrdersData({required this.orders});

  final List<IncompleteOrderEntry> orders;

  int get count => orders.length;

  int get processingCount =>
      orders.where((o) => o.orderStatus == OrderStatus.processing).length;

  int get missingDataCount => orders
      .where(
        (o) =>
            o.issues.contains(OrderDataIssue.missingMachines) ||
            o.issues.contains(OrderDataIssue.missingPacks),
      )
      .length;

  bool get hasIssues => orders.isNotEmpty;
}

bool saleHasMachine(
  List<SaleServiceItem> serviceItems,
) {
  if (serviceItems.isEmpty) return true;
  return serviceItems.every((item) => item.hasMachineAssigned);
}

List<OrderDataIssue> issuesForSale({
  required Sale sale,
  required List<SaleServiceItem> serviceItems,
}) {
  final issues = <OrderDataIssue>[];
  if (sale.orderStatus == OrderStatus.processing) {
    issues.add(OrderDataIssue.stillProcessing);
  }
  if (!saleHasMachine(serviceItems)) {
    issues.add(OrderDataIssue.missingMachines);
  }
  if (sale.packs <= 0) {
    issues.add(OrderDataIssue.missingPacks);
  }
  return issues;
}
