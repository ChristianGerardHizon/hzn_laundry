import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/sale_consumable_usage_repository.dart';
import '../../../pos/domain/sale_consumable_usage.dart';
import '../../domain/consumables_usage_summary.dart';
import 'sales_summary_controller.dart';

part 'consumables_usage_summary_controller.g.dart';

/// Today's consumable usage, aggregated per product.
///
/// Uses the same non-voided sales as [salesSummary]. Cost visibility is a
/// UI concern (`usage.cost.view`).
@Riverpod(keepAlive: true)
Future<ConsumablesUsageSummaryData> consumablesUsageSummary(Ref ref) async {
  final summary = await ref.watch(salesSummaryProvider.future);
  final saleIds = summary.salesItems.map((s) => s.saleId).toList();
  final result = await ref
      .read(saleConsumableUsageRepositoryProvider)
      .fetchForSales(saleIds);
  final usages = result.fold(
    (_) => const <SaleConsumableUsage>[],
    (list) => list,
  );
  return ConsumablesUsageSummaryData.fromUsages(
    usages: usages,
    orderCount: saleIds.length,
  );
}
