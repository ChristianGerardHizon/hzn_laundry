import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/order_status_history_repository.dart';
import '../../../pos/domain/order_status_history.dart';

part 'order_status_history_provider.g.dart';

/// Provider for fetching status history entries for a sale.
@riverpod
Future<List<OrderStatusHistory>> orderStatusHistory(
  Ref ref,
  String saleId,
) async {
  final repository = ref.watch(orderStatusHistoryRepositoryProvider);
  final result = await repository.fetchBySale(saleId);
  return result.fold((f) => [], (history) => history);
}
