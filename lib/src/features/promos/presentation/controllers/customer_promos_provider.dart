import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/customer_promo_repository.dart';
import '../../domain/customer_promo.dart';

part 'customer_promos_provider.g.dart';

/// Provider for a customer's enrolled promos.
@riverpod
Future<List<CustomerPromo>> customerPromos(
  Ref ref,
  String customerId,
) async {
  final repository = ref.read(customerPromoRepositoryProvider);
  final result = await repository.fetchByCustomer(customerId);

  return result.fold(
    (failure) => [],
    (promos) => promos,
  );
}
