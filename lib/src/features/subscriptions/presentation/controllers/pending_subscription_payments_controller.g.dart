// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_subscription_payments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Super Admin queue of pending subscription payment proofs.

@ProviderFor(PendingSubscriptionPaymentsController)
final pendingSubscriptionPaymentsControllerProvider =
    PendingSubscriptionPaymentsControllerProvider._();

/// Super Admin queue of pending subscription payment proofs.
final class PendingSubscriptionPaymentsControllerProvider
    extends $AsyncNotifierProvider<PendingSubscriptionPaymentsController,
        List<SubscriptionPayment>> {
  /// Super Admin queue of pending subscription payment proofs.
  PendingSubscriptionPaymentsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingSubscriptionPaymentsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$pendingSubscriptionPaymentsControllerHash();

  @$internal
  @override
  PendingSubscriptionPaymentsController create() =>
      PendingSubscriptionPaymentsController();
}

String _$pendingSubscriptionPaymentsControllerHash() =>
    r'28603ca482b52e62660feaf39b829b70eedfda2e';

/// Super Admin queue of pending subscription payment proofs.

abstract class _$PendingSubscriptionPaymentsController
    extends $AsyncNotifier<List<SubscriptionPayment>> {
  FutureOr<List<SubscriptionPayment>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SubscriptionPayment>>,
        List<SubscriptionPayment>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<SubscriptionPayment>>,
            List<SubscriptionPayment>>,
        AsyncValue<List<SubscriptionPayment>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
