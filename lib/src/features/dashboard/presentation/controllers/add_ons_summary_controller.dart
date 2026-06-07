import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/data/dto/sale_item_dto.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/add_ons_summary.dart';
import 'dashboard_date_override_provider.dart';

part 'add_ons_summary_controller.g.dart';

/// Summary of add-ons (product line items) sold on the effective dashboard
/// date, aggregated per product.
///
/// Add-ons are the product line items (`saleItems`) attached to sales, as
/// opposed to laundry service items. Voided sales are excluded.
@riverpod
Future<AddOnsSummaryData> addOnsSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final now = ref.watch(dashboardEffectiveDateProvider);
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final startUtc = dayStart.toPocketBaseUtc();
  final endUtc = dayEnd.toPocketBaseUtc();

  final salesBranchFilter = branchId != null ? ' && branch = "$branchId"' : '';
  final todaySalesFilter =
      "status != 'voided' && postedDate >= '$startUtc' && postedDate < '$endUtc'$salesBranchFilter";

  final saleRecords =
      await pb.collection(PocketBaseCollections.sales).getFullList(
            filter: todaySalesFilter,
          );

  final saleIds =
      saleRecords.map((record) => SaleDto.fromRecord(record).toEntity().id).toList();

  if (saleIds.isEmpty) {
    return const AddOnsSummaryData(
      totalQuantity: 0,
      totalRevenue: 0,
      items: [],
    );
  }

  final saleIdFilters = saleIds.map((id) => 'sale = "$id"').join(' || ');

  final itemRecords =
      await pb.collection(PocketBaseCollections.saleItems).getFullList(
            filter: '($saleIdFilters)',
          );

  // Aggregate per product.
  final byProduct = <String, _Aggregate>{};
  num totalQuantity = 0;
  num totalRevenue = 0;

  for (final record in itemRecords) {
    final item = SaleItemDto.fromRecord(record).toEntity();
    totalQuantity += item.quantity;
    totalRevenue += item.subtotal;

    final aggregate = byProduct.putIfAbsent(
      item.productId,
      () => _Aggregate(productName: item.productName),
    );
    aggregate.quantity += item.quantity;
    aggregate.revenue += item.subtotal;
    aggregate.saleIds.add(item.saleId);
    // Keep the latest non-empty product name snapshot.
    if (item.productName.isNotEmpty) {
      aggregate.productName = item.productName;
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
