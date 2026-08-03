import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/promo_repository.dart';
import '../../domain/promo.dart';

part 'promos_controller.g.dart';

/// Controller for managing the list of promos.
@Riverpod(keepAlive: true)
class PromosController extends _$PromosController {
  PromoRepository get _repository => ref.read(promoRepositoryProvider);

  @override
  Future<List<Promo>> build() async {
    final branchFilter = ref.watch(currentBranchFilterProvider);
    final result = await _repository.fetchAll(filter: branchFilter);

    return result.fold(
      (failure) => throw failure,
      (promos) => promos,
    );
  }

  /// Refreshes the promo list.
  Future<void> refresh() async {
    state = const AsyncLoading();

    final branchFilter = ref.read(currentBranchFilterProvider);
    final result = await _repository.fetchAll(filter: branchFilter);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (promos) => AsyncData(promos),
    );
  }

  /// Creates a new promo.
  Future<Promo?> createPromo(Promo promo) async {
    final result = await _repository.create(promo);
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  /// Updates an existing promo.
  Future<bool> updatePromo(Promo promo) async {
    final result = await _repository.update(promo);
    return result.fold(
      (failure) => false,
      (updated) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes a promo (soft delete).
  Future<bool> deletePromo(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
