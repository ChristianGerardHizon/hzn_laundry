import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/loads_summary.dart';
import 'sales_summary_controller.dart';

part 'loads_summary_controller.g.dart';

/// Summary of machine loads for the effective dashboard date, broken down per
/// order.
///
/// A load is a machine cycle assigned to a sale's service items
/// (`saleServiceItems.machineLoadCounts`). Counts come from the service items
/// already loaded with today's sales, so this does not scan
/// `vw_loads_summary`. Voided sales are excluded by [salesSummary].
@Riverpod(keepAlive: true)
Future<LoadsSummaryData> loadsSummary(Ref ref) async {
  final summary = await ref.watch(salesSummaryProvider.future);
  return LoadsSummaryData.fromSalesItems(summary.salesItems);
}
