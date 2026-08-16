import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/add_ons_summary.dart';
import 'sales_summary_controller.dart';

part 'add_ons_summary_controller.g.dart';

/// Summary of add-ons (product line items) sold on the effective dashboard
/// date, aggregated per product.
///
/// Add-ons are the product line items (`saleItems`) already loaded with
/// today's sales. Aggregating in memory avoids a full-history scan of
/// `vw_add_ons_summary`. Voided sales are excluded by [salesSummary].
@Riverpod(keepAlive: true)
Future<AddOnsSummaryData> addOnsSummary(Ref ref) async {
  final summary = await ref.watch(salesSummaryProvider.future);
  return AddOnsSummaryData.fromSalesItems(summary.salesItems);
}
