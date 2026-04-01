import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/customer_promo.dart';
import '../dto/customer_promo_dto.dart';
import 'promo_repository.dart';

part 'customer_promo_repository.g.dart';

/// Repository interface for customer promo operations.
abstract class CustomerPromoRepository {
  /// Fetches all promos for a given customer.
  FutureEither<List<CustomerPromo>> fetchByCustomer(String customerId);

  /// Fetches redeemable promos for a customer (earned, not redeemed, promo active).
  FutureEither<List<CustomerPromo>> fetchRedeemable(String customerId);

  /// Enrolls a customer in a promo.
  FutureEither<CustomerPromo> enroll(String customerId, String promoId);

  /// Increments the completed order count for a customer promo.
  /// Automatically sets isRewardEarned when threshold is met.
  FutureEither<CustomerPromo> incrementOrders(String id);

  /// Marks a reward as redeemed on a given sale.
  FutureEither<CustomerPromo> redeemReward(String id, String saleId);

  /// Auto-enrolls a customer in all active promos they aren't yet enrolled in.
  FutureEither<void> autoEnrollCustomer(
    String customerId,
    PromoRepository promoRepo, {
    String? branchFilter,
  });

  /// Increments order counts for all active enrolled promos of a customer
  /// and auto-enrolls in any new active promos.
  FutureEither<void> incrementAndAutoEnroll(
    String customerId,
    PromoRepository promoRepo, {
    String? excludeCustomerPromoId,
    String? branchFilter,
  });
}

/// Provides the CustomerPromoRepository instance.
@Riverpod(keepAlive: true)
CustomerPromoRepository customerPromoRepository(Ref ref) {
  return CustomerPromoRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [CustomerPromoRepository] using PocketBase.
class CustomerPromoRepositoryImpl implements CustomerPromoRepository {
  final PocketBase _pb;

  CustomerPromoRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.customerPromos);

  String get _expand => 'promo';

  CustomerPromo _toEntity(RecordModel record) {
    final dto = CustomerPromoDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<CustomerPromo>> fetchByCustomer(
    String customerId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .notDeleted()
            .relation('customer', customerId)
            .build();

        final records = await _collection.getFullList(
          expand: _expand,
          filter: filter,
          sort: 'promo',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<CustomerPromo>> fetchRedeemable(
    String customerId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .notDeleted()
            .relation('customer', customerId)
            .build();
        final redeemFilter =
            '$filter && isRewardEarned = true && isRewardRedeemed = false';

        final records = await _collection.getFullList(
          expand: _expand,
          filter: redeemFilter,
          sort: 'promo',
        );

        // Further filter to only include promos that are currently active
        final results = records.map(_toEntity).where((cp) {
          final promo = cp.promo;
          return promo != null && promo.isCurrentlyActive;
        }).toList();

        return results;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<CustomerPromo> enroll(
    String customerId,
    String promoId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'customer': customerId,
          'promo': promoId,
          'completedOrders': 0,
          'isRewardEarned': false,
          'isRewardRedeemed': false,
          'isDeleted': false,
        };

        final record =
            await _collection.create(body: body, expand: _expand);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<CustomerPromo> incrementOrders(String id) async {
    return TaskEither.tryCatch(
      () async {
        // Fetch current record to get current count
        final current = await _collection.getOne(id, expand: _expand);
        final currentEntity = _toEntity(current);

        final newCount = currentEntity.completedOrders + 1;
        final threshold = currentEntity.promo?.requiredOrders ?? 0;
        final earned = newCount >= threshold;

        final body = <String, dynamic>{
          'completedOrders': newCount,
          'isRewardEarned': earned,
        };

        final record =
            await _collection.update(id, body: body, expand: _expand);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<CustomerPromo> redeemReward(
    String id,
    String saleId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'isRewardRedeemed': true,
          'redeemedOnSale': saleId,
        };

        final record =
            await _collection.update(id, body: body, expand: _expand);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> autoEnrollCustomer(
    String customerId,
    PromoRepository promoRepo, {
    String? branchFilter,
  }) async {
    return TaskEither.tryCatch(
      () async {
        // Get all active promos
        final promosResult =
            await promoRepo.fetchActive(branchFilter: branchFilter);
        final activePromos = promosResult.fold(
          (_) => <dynamic>[],
          (promos) => promos,
        );

        if (activePromos.isEmpty) return;

        // Get customer's existing enrollments
        final existingFilter = PBFilter()
            .notDeleted()
            .relation('customer', customerId)
            .build();
        final existingRecords = await _collection.getFullList(
          filter: existingFilter,
        );
        final enrolledPromoIds =
            existingRecords.map((r) => r.toJson()['promo'] as String).toSet();

        // Enroll in any missing active promos
        for (final promo in activePromos) {
          if (!enrolledPromoIds.contains(promo.id)) {
            await _collection.create(body: <String, dynamic>{
              'customer': customerId,
              'promo': promo.id,
              'completedOrders': 0,
              'isRewardEarned': false,
              'isRewardRedeemed': false,
              'isDeleted': false,
            });
          }
        }
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> incrementAndAutoEnroll(
    String customerId,
    PromoRepository promoRepo, {
    String? excludeCustomerPromoId,
    String? branchFilter,
  }) async {
    return TaskEither.tryCatch(
      () async {
        // Auto-enroll in any new promos first
        await autoEnrollCustomer(customerId, promoRepo,
            branchFilter: branchFilter);

        // Fetch all active, non-redeemed enrollments
        final filter = PBFilter()
            .notDeleted()
            .relation('customer', customerId)
            .build();
        final redeemFilter =
            '$filter && isRewardRedeemed = false';

        final records = await _collection.getFullList(
          expand: _expand,
          filter: redeemFilter,
        );

        for (final record in records) {
          final entity = _toEntity(record);

          // Skip the promo being redeemed in this order
          if (entity.id == excludeCustomerPromoId) continue;

          // Skip if promo is not currently active
          if (entity.promo == null || !entity.promo!.isCurrentlyActive) {
            continue;
          }

          // Increment order count
          final newCount = entity.completedOrders + 1;
          final threshold = entity.promo!.requiredOrders;
          final earned = newCount >= threshold;

          await _collection.update(entity.id, body: <String, dynamic>{
            'completedOrders': newCount,
            'isRewardEarned': earned,
          });
        }
      },
      Failure.handle,
    ).run();
  }
}
