import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/delivery_rate_repository.dart';
import '../../domain/delivery_rate.dart';

part 'delivery_rates_controller.g.dart';

/// Delivery rates of one branch (default first).
@riverpod
class DeliveryRatesController extends _$DeliveryRatesController {
  DeliveryRateRepository get _repository =>
      ref.read(deliveryRateRepositoryProvider);

  @override
  Future<List<DeliveryRate>> build(String branchId) async {
    if (branchId.isEmpty) return const [];
    final result = await _repository.fetchForBranch(branchId);
    return result.fold((failure) => throw failure, (rates) => rates);
  }

  /// Creates (empty id) or updates [rate]. Returns the failure message, or
  /// null on success. The first rate becomes the default on the server.
  Future<String?> save(DeliveryRate rate) async {
    final result = rate.id.isEmpty
        ? await _repository.create(rate)
        : await _repository.update(rate);
    return result.fold(
      (failure) => failure.messageString,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  Future<String?> setDefault(DeliveryRate rate) =>
      save(rate.copyWith(isDefault: true));

  Future<String?> remove(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => failure.messageString,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }
}
