import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/sale_consumable_usage.dart';
import '../dto/sale_consumable_usage_dto.dart';

part 'sale_consumable_usage_repository.g.dart';

abstract class SaleConsumableUsageRepository {
  FutureEither<List<SaleConsumableUsage>> fetchForSale(String saleId);
  FutureEither<List<SaleConsumableUsage>> fetchForSales(List<String> saleIds);
  FutureEither<SaleConsumableUsage> create(SaleConsumableUsage usage);
  FutureEither<SaleConsumableUsage> update(SaleConsumableUsage usage);
  FutureEither<void> delete(String id);
}

@Riverpod(keepAlive: true)
SaleConsumableUsageRepository saleConsumableUsageRepository(Ref ref) {
  return SaleConsumableUsageRepositoryImpl(ref.watch(pocketbaseProvider));
}

class SaleConsumableUsageRepositoryImpl
    implements SaleConsumableUsageRepository {
  SaleConsumableUsageRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.saleConsumableUsages);

  SaleConsumableUsage _toEntity(RecordModel record) {
    final productExpanded = record.get<RecordModel?>('expand.product');
    return SaleConsumableUsageDto.fromRecord(record)
        .toEntity(productExpanded: productExpanded);
  }

  @override
  FutureEither<List<SaleConsumableUsage>> fetchForSale(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(
          filter: 'sale = "$saleId"',
          sort: 'productName',
          expand: 'product,product.quantityUnit',
        );
        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<SaleConsumableUsage>> fetchForSales(
    List<String> saleIds,
  ) async {
    return TaskEither.tryCatch(
      () async {
        if (saleIds.isEmpty) return const <SaleConsumableUsage>[];
        final filter = saleIds.map((id) => 'sale = "$id"').join(' || ');
        final records = await _collection.getFullList(
          filter: '($filter)',
          expand: 'product,product.quantityUnit',
        );
        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<SaleConsumableUsage> create(SaleConsumableUsage usage) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.create(body: _body(usage));
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<SaleConsumableUsage> update(SaleConsumableUsage usage) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.update(usage.id, body: _body(usage));
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        await _collection.delete(id);
      },
      Failure.handle,
    ).run();
  }

  Map<String, dynamic> _body(SaleConsumableUsage usage) {
    return {
      'sale': usage.saleId,
      'product': usage.productId,
      'productName': usage.productName,
      'quantity': usage.quantity,
      'unitLabel': usage.unitLabel,
      'unitCost': usage.unitCost,
      'cost': usage.cost,
    };
  }
}
