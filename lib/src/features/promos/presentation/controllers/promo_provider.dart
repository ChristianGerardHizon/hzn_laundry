import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/promo_repository.dart';
import '../../domain/promo.dart';

part 'promo_provider.g.dart';

/// Provider for a single promo by ID.
@riverpod
Future<Promo?> promo(Ref ref, String id) async {
  final repository = ref.read(promoRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold(
    (failure) => null,
    (promo) => promo,
  );
}
