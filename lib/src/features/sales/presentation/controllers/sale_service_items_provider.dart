import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/sales_repository.dart';
import '../../../services/domain/sale_service_item.dart';

part 'sale_service_items_provider.g.dart';

/// Provider for fetching sale service items by sale ID.
@riverpod
Future<List<SaleServiceItem>> saleServiceItems(Ref ref, String saleId) async {
  final repository = ref.watch(salesRepositoryProvider);
  final result = await repository.getSaleServiceItems(saleId);
  return result.fold((f) => [], (items) => items);
}
