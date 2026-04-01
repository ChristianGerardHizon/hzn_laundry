import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/customer_promo_repository.dart';
import '../../domain/customer_promo.dart';

part 'redeemable_promos_provider.g.dart';

/// Provider for a customer's redeemable promos (earned, not yet redeemed, promo active).
@riverpod
Future<List<CustomerPromo>> redeemablePromos(
  Ref ref,
  String customerId,
) async {
  final repository = ref.read(customerPromoRepositoryProvider);
  final result = await repository.fetchRedeemable(customerId);

  return result.fold(
    (failure) => [],
    (promos) => promos,
  );
}
