import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/add_ons_summary.dart';
import 'dashboard_date_override_provider.dart';

part 'add_ons_summary_controller.g.dart';

/// Summary of add-ons (product line items) sold on the effective dashboard
/// date, aggregated per product.
///
/// Add-ons are the product line items (`saleItems`) attached to sales, as
/// opposed to laundry service items. The `vw_add_ons_summary` view collapses
/// each sale's line items to one row per (sale, product) carrying the sale's
/// branch + postedDate, so this provider range-filters by the day and folds
/// the rows per product. Voided sales are excluded by the view.
@Riverpod(keepAlive: true)
Future<AddOnsSummaryData> addOnsSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final startUtc = dayStart.toPocketBaseUtc();
  final endUtc = dayEnd.toPocketBaseUtc();

  final branchFilter = branchId != null ? ' && branch = "$branchId"' : '';
  final filter =
      "postedDate >= '$startUtc' && postedDate < '$endUtc'$branchFilter";

  final rows = await pb
      .collection(PocketBaseCollections.vwAddOnsSummary)
      .getFullList(filter: filter);

  if (rows.isEmpty) {
    return const AddOnsSummaryData(
      totalQuantity: 0,
      totalRevenue: 0,
      items: [],
    );
  }

  // Aggregate per product. Each row is one (sale, product) pair.
  final byProduct = <String, _Aggregate>{};
  num totalQuantity = 0;
  num totalRevenue = 0;

  for (final record in rows) {
    final productId = record.getStringValue('product');
    if (productId.isEmpty) continue;
    final quantity = record.getDoubleValue('quantity');
    final revenue = record.getDoubleValue('revenue');
    final productName = record.getStringValue('productName');
    final saleId = record.getStringValue('sale');

    totalQuantity += quantity;
    totalRevenue += revenue;

    final aggregate = byProduct.putIfAbsent(
      productId,
      () => _Aggregate(productName: productName),
    );
    aggregate.quantity += quantity;
    aggregate.revenue += revenue;
    if (saleId.isNotEmpty) aggregate.saleIds.add(saleId);
    // Keep the latest non-empty product name snapshot.
    if (productName.isNotEmpty) {
      aggregate.productName = productName;
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

/// Mutable accumulator used while aggregating add-on line items per product.
class _Aggregate {
  _Aggregate({required this.productName});

  String productName;
  num quantity = 0;
  num revenue = 0;
  final Set<String> saleIds = {};
}
