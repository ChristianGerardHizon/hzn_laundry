import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/order_status_history.dart';
import '../dto/order_status_history_dto.dart';

part 'order_status_history_repository.g.dart';

/// Repository interface for order status history operations.
abstract class OrderStatusHistoryRepository {
  /// Fetches all status history entries for a sale.
  FutureEither<List<OrderStatusHistory>> fetchBySale(String saleId);

  /// Creates a new status history entry.
  FutureEither<OrderStatusHistory> create({
    required String saleId,
    required String statusType,
    required String fromStatus,
    required String toStatus,
    String? description,
  });
}

/// Provides the OrderStatusHistoryRepository instance.
@Riverpod(keepAlive: true)
OrderStatusHistoryRepository orderStatusHistoryRepository(Ref ref) {
  return OrderStatusHistoryRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [OrderStatusHistoryRepository] using PocketBase.
class OrderStatusHistoryRepositoryImpl implements OrderStatusHistoryRepository {
  final PocketBase _pb;

  OrderStatusHistoryRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.orderStatusHistory);

  OrderStatusHistory _toEntity(RecordModel record) {
    final dto = OrderStatusHistoryDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<OrderStatusHistory>> fetchBySale(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(
          filter: 'sale = "$saleId"',
          sort: '-created',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrderStatusHistory> create({
    required String saleId,
    required String statusType,
    required String fromStatus,
    required String toStatus,
    String? description,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = OrderStatusHistoryDto.toCreateBody(
          saleId: saleId,
          statusType: statusType,
          fromStatus: fromStatus,
          toStatus: toStatus,
          description: description,
        );

        final record = await _collection.create(body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}
