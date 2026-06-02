import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/customer_history_repository.dart';
import '../../domain/customer_history.dart';

part 'customer_history_controller.g.dart';

/// Fetches customer history by token.
@riverpod
Future<CustomerHistory> customerHistory(Ref ref, String token) async {
  final repo = ref.watch(customerHistoryRepositoryProvider);
  final result = await repo.fetchByToken(token);
  return result.fold(
    (failure) => throw failure,
    (history) => history,
  );
}

/// Fetches a single sale's detail (items + services) by token + saleId.
@riverpod
Future<CustomerHistorySaleDetail> customerHistorySaleDetail(
  Ref ref,
  String token,
  String saleId,
) async {
  final repo = ref.watch(customerHistoryRepositoryProvider);
  final result = await repo.fetchSaleDetail(token, saleId);
  return result.fold(
    (failure) => throw failure,
    (detail) => detail,
  );
}
