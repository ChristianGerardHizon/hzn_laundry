import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/delivery_rate.dart';
import '../dto/delivery_rate_dto.dart';

part 'delivery_rate_repository.g.dart';

/// Delivery rates per branch. The server keeps exactly one default per branch
/// (first rate becomes default; setting a default clears the others).
abstract class DeliveryRateRepository {
  FutureEither<List<DeliveryRate>> fetchForBranch(String branchId);
  FutureEither<DeliveryRate> create(DeliveryRate rate);
  FutureEither<DeliveryRate> update(DeliveryRate rate);

  /// Soft delete. The server promotes another rate if this was the default.
  FutureEither<void> delete(String id);
}

@Riverpod(keepAlive: true)
DeliveryRateRepository deliveryRateRepository(Ref ref) =>
    DeliveryRateRepositoryImpl(ref.watch(pocketbaseProvider));

class DeliveryRateRepositoryImpl implements DeliveryRateRepository {
  DeliveryRateRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.branchDeliveryRates);

  @override
  FutureEither<List<DeliveryRate>> fetchForBranch(String branchId) {
    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(
          filter: PBFilters.forBranch(branchId).build(),
          sort: '-isDefault,created',
        );
        return records.map(DeliveryRateDto.fromRecord).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<DeliveryRate> create(DeliveryRate rate) {
    return TaskEither.tryCatch(
      () async => DeliveryRateDto.fromRecord(
        await _collection.create(body: DeliveryRateDto.toBody(rate)),
      ),
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<DeliveryRate> update(DeliveryRate rate) {
    return TaskEither.tryCatch(
      () async => DeliveryRateDto.fromRecord(
        await _collection.update(rate.id, body: DeliveryRateDto.toBody(rate)),
      ),
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) {
    return TaskEither.tryCatch(
      () async {
        await _collection.update(id, body: {'isDeleted': true});
      },
      Failure.handle,
    ).run();
  }
}
