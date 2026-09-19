/// Lightweight KPI + chart data for the Orders report tab.
class OrdersReportSummary {
  const OrdersReportSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.paidCount,
    required this.unpaidCount,
    required this.revenueByDay,
  });

  final num totalRevenue;
  final int totalOrders;
  final int paidCount;
  final int unpaidCount;

  /// Net payment revenue per calendar day (from vw_sales_daily_summary).
  final Map<DateTime, num> revenueByDay;

  static const empty = OrdersReportSummary(
    totalRevenue: 0,
    totalOrders: 0,
    paidCount: 0,
    unpaidCount: 0,
    revenueByDay: {},
  );
}
