import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/subscription_repository.dart';
import '../../domain/subscription_payment.dart';

part 'pending_subscription_payments_controller.g.dart';

/// Super Admin queue of pending subscription payment proofs.
@riverpod
class PendingSubscriptionPaymentsController
    extends _$PendingSubscriptionPaymentsController {
  SubscriptionRepository get _repository =>
      ref.read(subscriptionRepositoryProvider);

  @override
  Future<List<SubscriptionPayment>> build() async {
    final result = await _repository.listPendingPayments();
    return result.fold(
      (failure) => throw failure,
      (payments) => payments,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.listPendingPayments();
      return result.fold(
        (failure) => throw failure,
        (payments) => payments,
      );
    });
  }

  Future<bool> reviewPayment(
    String paymentId, {
    required bool approved,
    String? adminNote,
  }) async {
    final result = await _repository.reviewPayment(
      paymentId,
      approved: approved,
      adminNote: adminNote,
    );
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
